#!/usr/bin/env python3
"""Exercise Mango's initial lid check without accessing logind or real outputs."""

import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile

CONFIG = Path(__file__).resolve().parents[1] / "mango/.config/mango/config.conf"
MOCK = r'''
import json
import os
from pathlib import Path
import sys

root = Path(os.environ["LID_TEST_ROOT"])
name = Path(sys.argv[0]).name
with (root / "calls").open("a") as output:
    output.write(json.dumps([name, *sys.argv[1:]]) + "\n")
if name == "busctl":
    print(os.environ["LID_TEST_STATE"])
'''


def main():
    startup = [line.split("=", 1)[1] for line in CONFIG.read_text().splitlines()
               if line.startswith("exec_once=") and "LidClosed" in line]
    assert len(startup) == 1, "expected one initial lid-state command"
    with tempfile.TemporaryDirectory(prefix="mango-lid-") as temporary:
        root = Path(temporary)
        bindir = root / "bin"
        bindir.mkdir()
        mock = bindir / "mock.py"
        mock.write_text("#!" + sys.executable + "\n" + MOCK)
        mock.chmod(0o755)
        for name in ("busctl", "mmsg"):
            (bindir / name).symlink_to("mock.py")
        for state in ("b false", "b true"):
            (root / "calls").write_text("")
            subprocess.run(shlex.split(startup[0]), env=os.environ | {
                "PATH": str(bindir) + ":" + os.environ["PATH"],
                "LID_TEST_ROOT": str(root), "LID_TEST_STATE": state,
            }, check=True, timeout=10)
            calls = [json.loads(line) for line in (root / "calls").read_text().splitlines()]
            expected = [["busctl", "get-property", "org.freedesktop.login1",
                         "/org/freedesktop/login1", "org.freedesktop/login1.Manager",
                         "LidClosed"]]
            if state == "b true":
                expected.append(["mmsg", "dispatch", "disable_monitor,eDP-1"])
            assert calls == expected, (state, calls)
    print("mango-lid: closed lid disables eDP-1; open lid leaves outputs unchanged")


if __name__ == "__main__":
    main()
