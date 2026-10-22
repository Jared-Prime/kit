import fs from "node:fs";
import path from "node:path";
import { DatabaseSync } from "node:sqlite";

// Run once inside the sandbox and redirect stdout on the host.
// Codex 0.163.0's database filenames and transcript format are internal APIs.
const args = process.argv.slice(2);
const [id, ordinal = "-1", logID = "0"] = args;

if (args.length < 1 || args.length > 3) {
  throw Error("usage: node codex-logs.ts SESSION_UUID [AFTER_ORDINAL [AFTER_LOG_ID]]");
}
if (!id || !/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(id)) {
  throw Error("invalid session UUID");
}

const cursor = {
  logID: Number(logID),
  ordinal: Number(ordinal),
};

if (!Number.isSafeInteger(cursor.logID) || cursor.logID < 0) throw Error(`invalid cursor log id`);
if (!Number.isSafeInteger(cursor.ordinal) || cursor.ordinal < -1)
  throw Error(`invalid cursor ordinal`);

const { CODEX_HOME, CODEX_SQLITE_HOME } = process.env;

const home = {
  sqlite: CODEX_SQLITE_HOME || CODEX_HOME || "/home/agent/.codex",
  codex: CODEX_HOME || "/home/agent/.codex",
};

const state = path.join(home.sqlite, "state_5.sqlite");
const logs = path.join(home.sqlite, "logs_2.sqlite");

function emit(record: Record<string, unknown>) {
  console.log(
    JSON.stringify({
      collected: new Date().toISOString(),
      ...record,
    }),
  );
}

function transcriptPath(): string {
  const database = new DatabaseSync(state, { readOnly: true });
  try {
    database.exec("PRAGMA busy_timeout = 2000");
    const thread = database
      .prepare(`
            SELECT rollout_path FROM threads WHERE id = ?
        `)
      .get(id);

    if (!thread) throw Error("session not found in state database");
    if (typeof thread.rollout_path !== "string" || !path.isAbsolute(thread.rollout_path)) {
      throw Error("session has no absolute transcript path");
    }
    return thread.rollout_path;
  } finally {
    database.close();
  }
}

function collectRollout(file: string): number {
  const initialOrdinal = cursor.ordinal;
  const fd = fs.openSync(file, "r");
  let lastOrdinal = -1;
  let records = 0;

  try {
    // Capture a fixed file size, so an active session cannot extend this read indefinitely.
    const size = fs.fstatSync(fd).size;
    const buffer = Buffer.alloc(64 * 1024);
    let offset = 0;
    let pending: Buffer = Buffer.alloc(0);

    while (offset < size) {
      const count = fs.readSync(fd, buffer, 0, Math.min(buffer.length, size - offset), offset);
      if (!count) throw Error("transcript was truncated during collection; retry");
      offset += count;
      pending = Buffer.concat([pending, buffer.subarray(0, count)]);

      let end: number;
      while ((end = pending.indexOf(10)) !== -1) {
        const line = pending.subarray(0, end).toString("utf8");
        pending = pending.subarray(end + 1);
        if (!line.trim()) continue;

        const record = JSON.parse(line) as Record<string, unknown> | null;
        const position = record?.ordinal;
        if (
          typeof position !== "number" ||
          !Number.isSafeInteger(position) ||
          position <= lastOrdinal
        ) {
          throw Error("transcript ordinals are missing or not strictly increasing");
        }
        lastOrdinal = position;
        if (position > cursor.ordinal) {
          emit({ source: "rollout", file, record });
          cursor.ordinal = position;
          records++;
        }
      }
      if (pending.length > 32 * 1024 * 1024) {
        throw Error("incomplete transcript record exceeds 32 MiB");
      }
    }
    // Ignore an unterminated final line; the next capture will retry it using the same cursor.
    if (lastOrdinal < initialOrdinal) {
      throw Error("transcript cursor is ahead of this file; check for a reset");
    }
    return records;
  } finally {
    fs.closeSync(fd);
  }
}

function collectDiagnostics(): number {
  const database = new DatabaseSync(logs, { readOnly: true });
  let records = 0;
  try {
    database.exec("PRAGMA busy_timeout = 2000");
    const rows = database
      .prepare(`
            SELECT id, ts, ts_nanos, level, target, feedback_log_body,
                   module_path, file, line, thread_id, process_uuid
            FROM logs
            WHERE id > ? AND (thread_id = ? OR thread_id IS NULL)
            ORDER BY id
        `)
      .iterate(cursor.logID, id);

    for (const record of rows) {
      if (typeof record.id !== "number" || !Number.isSafeInteger(record.id)) {
        throw Error("diagnostic log id is not a safe integer");
      }
      emit({ source: "diagnostic", file: logs, record });
      cursor.logID = record.id;
      records++;
    }
    return records;
  } finally {
    database.close();
  }
}

const transcript = transcriptPath();
emit({ source: "collector", event: "start", session_id: id, transcript, cursor: { ...cursor } });

const records = {
  rollout: collectRollout(transcript),
  diagnostic: collectDiagnostics(),
};

// Consumers should save this checkpoint only after the command exits successfully.
emit({ source: "collector", event: "checkpoint", session_id: id, cursor, records });
