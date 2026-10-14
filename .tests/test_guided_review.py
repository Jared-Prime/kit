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


def pr(
    number,
    base="main",
    team="reviewers",
    conclusion="success",
    draft=False,
    status_state=None,
    requested_user="alice",
    reviewer="bob",
):
    return {
        "number": number,
        "draft": draft,
        "html_url": f"https://example.test/pr/{number}",
        "title": f"Change {number}",
        "head": {"ref": f"feature-{number}", "sha": f"sha-{number}"},
        "base": {"ref": base},
        "updated_at": "2026-10-14T00:00:00Z",
        "mergeable": True,
        "requested_teams": [{"slug": team}],
        "requested_reviewers": [] if requested_user is None else [{"login": requested_user}],
        "reviews": [] if reviewer is None else [{"user": {"login": reviewer}}],
        "check_runs": [{"status": "completed", "conclusion": conclusion}],
        "statuses": [] if status_state is None else [{"state": status_state}],
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
        gh.write_text((ROOT / ".tests" / "fake_gh.py").read_text())
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

    def test_context_uses_https_clone_url(self):
        gh = self.bin / "gh"
        gh.write_text(
            '#!/usr/bin/env bash\n'
            'case "$*" in\n'
            '  "api user --jq .login") printf "alice\\n" ;;\n'
            '  "api repos/example/repo --jq .clone_url") '
            'printf "https://github.com/example/repo.git\\n" ;;\n'
            '  "api user/teams --paginate") '
            'printf \'[{"slug":"reviewers","organization":{"login":"example"}}]\\n\' ;;\n'
            '  *) exit 1 ;;\n'
            'esac\n'
        )

        result = self.run_script("context.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("CLONE_URL = 'https://github.com/example/repo.git'", result.stdout)

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
            [
                pr(7),
                pr(8, team="another-team", requested_user="carol"),
                pr(9, conclusion="cancelled"),
                pr(10, draft=True),
                pr(11, status_state="failure"),
            ]
        )

        result = self.run_script("available.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout.splitlines(),
            ["- [ ] [PR7](https://example.test/pr/7): Change 7 - `feature-7`"],
        )

    def test_available_includes_direct_request_but_not_past_reviewer(self):
        self.env["MOCK_PRS"] = json.dumps(
            [
                pr(12, team="another-team"),
                pr(13, team="another-team", requested_user=None, reviewer="alice"),
            ]
        )

        result = self.run_script("available.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout.splitlines(),
            ["- [ ] [PR12](https://example.test/pr/12): Change 12 - `feature-12`"],
        )

    def test_checkout_fetches_pr_ref_with_full_history(self):
        self.env["MOCK_PRS"] = json.dumps([pr(7, base="release/2026")])
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
                "PR_NUMBER": "7",
                "CLONE_URL": "https://github.com/example/repo.git",
                "MOCK_GIT_LOG": str(log),
            }
        )

        result = self.run_script("checkout.sh")

        self.assertEqual(result.returncode, 0, result.stderr)
        calls = log.read_text().splitlines()
        self.assertIn(
            f"clone --single-branch -b release/2026 https://github.com/example/repo.git {self.work}/review/7",
            calls,
        )
        self.assertIn(
            "fetch origin refs/pull/7/head:refs/remotes/origin/pr/7",
            calls,
        )
        self.assertIn("switch -c review/7 origin/pr/7", calls)
        self.assertIn("merge-base release/2026 HEAD", calls)

    def test_checkout_aborts_before_git_when_directory_exists(self):
        (self.work / "review" / "7").mkdir(parents=True)
        git = self.bin / "git"
        git.write_text('#!/usr/bin/env bash\nprintf "called\\n" > "$MOCK_GIT_LOG"\n')
        git.chmod(0o755)
        log = self.work / "git.log"
        self.env.update(
            {
                "HOME": str(self.work),
                "PR_NUMBER": "7",
                "CLONE_URL": "https://github.com/example/repo.git",
                "MOCK_GIT_LOG": str(log),
            }
        )

        result = self.run_script("checkout.sh")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("already exists", result.stderr)
        self.assertFalse(log.exists(), "checkout should stop before calling git")


if __name__ == "__main__":
    unittest.main()
