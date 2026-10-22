import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { DatabaseSync } from "node:sqlite";
import test, { type TestContext } from "node:test";
import { fileURLToPath } from "node:url";

const collector = fileURLToPath(new URL("./codex-logs.ts", import.meta.url));
const sessionID = "00000000-0000-0000-0000-000000000001";
const otherID = "00000000-0000-0000-0000-000000000002";

function fixture(t: TestContext) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "codex-log-collector-"));
  t.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  const home = path.join(directory, "home");
  const sqlite = path.join(directory, "sqlite");
  fs.mkdirSync(home);
  fs.mkdirSync(sqlite);
  // The transcript deliberately lives outside CODEX_HOME and its usual date hierarchy.
  const transcript = path.join(directory, "explicit-transcript.jsonl");
  fs.writeFileSync(transcript, JSON.stringify({ ordinal: 0, type: "session_meta" }) + "\n");

  const statePath = path.join(sqlite, "state_5.sqlite");
  const state = new DatabaseSync(statePath);
  state.exec("CREATE TABLE threads (id TEXT PRIMARY KEY, rollout_path TEXT)");
  state.prepare("INSERT INTO threads VALUES (?, ?)").run(sessionID, transcript);
  state.close();

  const logsPath = path.join(sqlite, "logs_2.sqlite");
  const logs = new DatabaseSync(logsPath);
  logs.exec(`CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT, ts INTEGER, ts_nanos INTEGER,
        level TEXT, target TEXT, feedback_log_body TEXT, module_path TEXT,
        file TEXT, line INTEGER, thread_id TEXT, process_uuid TEXT
    )`);
  logs.close();

  function addLog(id: number, threadID: string | null) {
    const database = new DatabaseSync(logsPath);
    database
      .prepare("INSERT INTO logs VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
      .run(
        id,
        id,
        0,
        "ERROR",
        "fixture",
        "fixture diagnostic",
        null,
        null,
        null,
        threadID,
        "fixture",
      );
    database.close();
  }

  function run(args: string[] = [sessionID]) {
    return spawnSync(process.execPath, [collector, ...args], {
      env: { ...process.env, CODEX_HOME: home, CODEX_SQLITE_HOME: sqlite },
      encoding: "utf8",
      timeout: 5000,
      maxBuffer: 4 * 1024 * 1024,
    });
  }

  return { transcript, statePath, logsPath, addLog, run };
}

test("exports once, resumes both cursors, and leaves source databases unchanged", (t) => {
  const f = fixture(t);
  const first = JSON.stringify({ ordinal: 0, payload: { padding: "x".repeat(70 * 1024) } }) + "\n";
  const second = Buffer.from(
    JSON.stringify({ ordinal: 1, payload: { output: "result ✓" } }) + "\n",
  );
  const split = second.indexOf(Buffer.from("✓")) + 1;
  fs.writeFileSync(f.transcript, Buffer.concat([Buffer.from(first), second.subarray(0, split)]));
  f.addLog(1, sessionID);
  f.addLog(2, null);
  f.addLog(3, otherID);
  const stateBefore = fs.readFileSync(f.statePath);
  const logsBefore = fs.readFileSync(f.logsPath);

  const initial = f.run();
  assert.equal(initial.status, 0, initial.stderr);
  const initialRows = initial.stdout
    .trim()
    .split("\n")
    .map((line) => JSON.parse(line));
  const checkpoint = initialRows.at(-1);
  assert.equal(checkpoint.event, "checkpoint");
  assert.deepEqual(checkpoint.cursor, { ordinal: 0, logID: 2 });
  assert.deepEqual(checkpoint.records, { rollout: 1, diagnostic: 2 });
  assert.deepEqual(
    initialRows.filter((row) => row.source === "diagnostic").map((row) => row.record.id),
    [1, 2],
  );
  assert.deepEqual(fs.readFileSync(f.statePath), stateBefore);
  assert.deepEqual(fs.readFileSync(f.logsPath), logsBefore);

  fs.appendFileSync(f.transcript, second.subarray(split));
  f.addLog(4, sessionID);
  const next = f.run([
    sessionID,
    String(checkpoint.cursor.ordinal),
    String(checkpoint.cursor.logID),
  ]);
  assert.equal(next.status, 0, next.stderr);
  const nextRows = next.stdout
    .trim()
    .split("\n")
    .map((line) => JSON.parse(line));
  assert.equal(nextRows.find((row) => row.source === "rollout").record.payload.output, "result ✓");
  const nextCheckpoint = nextRows.at(-1);
  assert.deepEqual(nextCheckpoint.cursor, { ordinal: 1, logID: 4 });
  assert.deepEqual(nextCheckpoint.records, { rollout: 1, diagnostic: 1 });

  const unchanged = f.run([sessionID, "1", "4"]);
  assert.equal(unchanged.status, 0, unchanged.stderr);
  const unchangedRows = unchanged.stdout
    .trim()
    .split("\n")
    .map((line) => JSON.parse(line));
  assert.deepEqual(unchangedRows.at(-1).records, { rollout: 0, diagnostic: 0 });
});

test("rejects invalid arguments before emitting data", (t) => {
  const f = fixture(t);
  for (const args of [
    [],
    ["invalid"],
    [sessionID, "-2"],
    [sessionID, "NaN"],
    [sessionID, "0", "-1"],
  ]) {
    const result = f.run(args);
    assert.equal(result.status, 1);
    assert.equal(result.stdout, "");
    assert.match(result.stderr, /usage:|invalid/);
  }
});

test("fails without a checkpoint for missing sessions or invalid transcript sequences", (t) => {
  const f = fixture(t);
  const missing = f.run([otherID]);
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /session not found/);
  assert.equal(missing.stdout, "");

  for (const content of [
    '{"ordinal":0}\n{"ordinal":0}\n',
    '{"ordinal":1}\n{"ordinal":0}\n',
    '{"type":"response_item"}\n',
    "invalid JSON\n",
  ]) {
    fs.writeFileSync(f.transcript, content);
    const result = f.run();
    assert.equal(result.status, 1);
    assert.doesNotMatch(result.stdout, /"event":"checkpoint"/);
  }

  fs.writeFileSync(f.transcript, '{"ordinal":0}\n');
  const stale = f.run([sessionID, "5"]);
  assert.equal(stale.status, 1);
  assert.match(stale.stderr, /cursor is ahead/);
  assert.doesNotMatch(stale.stdout, /"event":"checkpoint"/);
});

test("does not recreate a missing diagnostic database or emit a success checkpoint", (t) => {
  const f = fixture(t);
  fs.unlinkSync(f.logsPath);
  const result = f.run();
  assert.equal(result.status, 1);
  assert.equal(fs.existsSync(f.logsPath), false);
  assert.doesNotMatch(result.stdout, /"event":"checkpoint"/);
});
