"""Behavior checks for guided-review scripts.

Run with: python3 -m unittest discover -s .tests
Requires jq; GitHub and git commands are replaced with local fakes.
"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "skills" / "guided-review" / "scripts"


def pr(number, team="reviewers", conclusion="SUCCESS"):
    return {
        "number": number,
        "url": f"https://example.test/pr/{number}",
        "title": f"Change {number}",
        "headRefName": f"feature-{number}",
        "updatedAt": "2026-10-14T00:00:00Z",
        "mergeable": "MERGEABLE",
        "reviewDecision": "REVIEW_REQUIRED",
        "reviewRequests": [
            {"__typename": "Team", "slug": team},
            {"__typename": "User", "login": "alice"},
        ],
        "reviews": [{"author": {"login": "bob"}}],
        "statusCheckRollup": [
            {
                "__typename": "CheckRun",
                "status": "COMPLETED",
                "conclusion": conclusion,
            }
        ],
    }


def json_stream(output):
    decoder = json.JSONDecoder()
    values = []
    while output.strip():
        stripped = output.lstrip()
        value, offset = decoder.raw_decode(stripped)
        values.append(value)
        output = stripped[offset:]
    return values


class GuidedReviewScriptsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.bin = self.work / "bin"
        self.bin.mkdir()
        gh = self.bin / "gh"
        gh.write_text('#!/usr/bin/env bash\nprintf "%s\\n" "$MOCK_PRS"\n')
        gh.chmod(0o755)

        self.env = os.environ.copy()
        self.env.update(
            {
                "PATH": f"{self.bin}{os.pathsep}{self.env.get('PATH', '')}",
                "GH_REPO": "example/repo",
                "GH_USER": "alice",
                "GH_TEAM": "reviewers",
            }
        )

    def run_script(self, name):
        return subprocess.run(
            ["bash", str(SCRIPTS / name)],
            cwd=ROOT,
            env=self.env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_request_emits_one_pr_with_combined_users(self):
        self.env["MOCK_PRS"] = json.dumps([pr(7)])

        result = self.run_script("request.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        shaped = json_stream(result.stdout)
        self.assertEqual(len(shaped), 1, shaped)
        self.assertEqual(shaped[0]["users"], ["alice", "bob"])
        self.assertEqual(shaped[0]["teams"], ["reviewers"])
        self.assertTrue(shaped[0]["success"])

    def test_available_lists_only_matching_pr_with_successful_checks(self):
        self.env["MOCK_PRS"] = json.dumps(
            [pr(7), pr(8, team="another-team"), pr(9, conclusion="CANCELLED")]
        )

        result = self.run_script("available.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout.splitlines(),
            ["- [ ] [PR7](https://example.test/pr/7): Change 7 - `feature-7`"],
        )

    def test_checkout_fetches_selected_head_into_a_local_branch(self):
        git = self.bin / "git"
        git.write_text(
            '#!/usr/bin/env bash\n'
            'printf "%s\\n" "$*" >> "$MOCK_GIT_LOG"\n'
            'if [[ $1 == clone ]]; then mkdir -p "${@: -1}"; fi\n'
        )
        git.chmod(0o755)
        log = self.work / "git.log"
        self.env.update(
            {
                "HOME": str(self.work),
                "GH_HEAD": "feature/topic",
                "SSH_URL": "git@example.test:example/repo.git",
                "MOCK_GIT_LOG": str(log),
            }
        )

        result = self.run_script("checkout.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        calls = log.read_text().splitlines()
        self.assertIn(
            "fetch --depth 1 origin feature/topic:refs/remotes/origin/feature/topic",
            calls,
        )
        self.assertIn("switch -c feature/topic origin/feature/topic", calls)


if __name__ == "__main__":
    unittest.main()
