#!/usr/bin/env python3
"""Exercise svc's Niri panel cutover without touching the live session."""

import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time

SVC = Path(__file__).resolve().parents[1] / "bin/.local/bin/svc"

MOCK = r'''
import json
import os
from pathlib import Path
import subprocess
import sys

root = Path(os.environ["SVC_TEST_ROOT"])
name = Path(sys.argv[0]).name
args = sys.argv[1:]
with (root / "calls").open("a") as output:
    output.write(json.dumps([name, *args]) + "\n")
if name == "herd":
    sys.exit(0 if os.environ["SVC_TEST_SUPERVISOR"] == "shepherd" else 1)
if name == "niri":
    assert args == ["msg", "action", "spawn", "--", "topbar"], args
    env = os.environ | {"NIRI_ENV": "from-niri"}
    subprocess.Popen([sys.executable, str(root / "panel.py")], env=env,
                     start_new_session=True, stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
else:
    assert name == "systemctl" and args[:1] == ["--user"], (name, args)
'''

PANEL = r'''
import ctypes
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

root = Path(os.environ["SVC_TEST_ROOT"])
ctypes.CDLL(None).prctl(15, b".topbar-wrapped", 0, 0, 0)
lock = (root / "runtime/topbar.lock").open("a+")
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
child = subprocess.Popen(["sleep", "60"])
with (root / "panels").open("a") as output:
    output.write(json.dumps([os.getpid(), child.pid, os.environ.get("NIRI_ENV")]) + "\n")
signal.signal(signal.SIGTERM, lambda *_: (time.sleep(0.2), sys.exit(0)))
while True:
    time.sleep(1)
'''


def main():
    with tempfile.TemporaryDirectory(prefix="svc-") as temporary:
        root = Path(temporary)
        (root / "runtime").mkdir()
        (root / "bin").mkdir()
        (root / "calls").touch()
        (root / "panels").touch()
        (root / "bin/mock.py").write_text("#!" + sys.executable + "\n" + MOCK)
        (root / "bin/mock.py").chmod(0o755)
        (root / "panel.py").write_text(PANEL)
        for name in ("herd", "systemctl", "niri"):
            (root / "bin" / name).symlink_to("mock.py")
        env = os.environ | {
            "PATH": str(root / "bin") + ":" + os.environ["PATH"],
            "SVC_TEST_ROOT": str(root),
            "SVC_TEST_SUPERVISOR": "systemd",
            "XDG_RUNTIME_DIR": str(root / "runtime"),
            "WAYLAND_DISPLAY": "wayland-test",
        }

        def invoke(*args, supervisor="systemd"):
            subprocess.run(["sh", str(SVC), *args], env=env | {"SVC_TEST_SUPERVISOR": supervisor},
                           check=True, timeout=10)

        def calls():
            return [json.loads(line) for line in (root / "calls").read_text().splitlines()]

        def panels(count):
            deadline = time.monotonic() + 5
            while True:
                records = [json.loads(line) for line in (root / "panels").read_text().splitlines()]
                if len(records) >= count:
                    return records
                assert time.monotonic() < deadline, "panel did not start"
                time.sleep(0.01)

        def alive(pid):
            try:
                return "State:\tZ" not in Path(f"/proc/{pid}/status").read_text()
            except FileNotFoundError:
                return False

        decoy = None
        try:
            invoke("session-start")
            first = panels(1)[0]
            assert first[2] == "from-niri", first
            assert b"NIRI_ENV=from-niri" in Path(f"/proc/{first[1]}/environ").read_bytes()
            assert [call for call in calls() if call[0] == "systemctl" and call[2] == "start"] == [
                ["systemctl", "--user", "start", unit]
                for unit in ("hypridle", "awww-normal", "awww-overview")
            ], calls()
            assert len([call for call in calls() if call[0] == "niri"]) == 1
            # A same-named CLI process does not own the lock and must not be killed.
            decoy = subprocess.Popen(
                [sys.executable, "-c",
                 "import ctypes,time; ctypes.CDLL(None).prctl(15,b'topbar',0,0,0); time.sleep(60)"],
                start_new_session=True)
            deadline = time.monotonic() + 5
            while Path(f"/proc/{decoy.pid}/comm").read_text().strip() != "topbar":
                assert time.monotonic() < deadline, "CLI decoy did not start"
                time.sleep(0.01)

            invoke("restart", "topbar")
            second = panels(2)[1]
            assert second[0] != first[0] and second[2] == "from-niri", (first, second)
            assert not alive(first[0]) and alive(first[1]), "panel's application was killed"
            assert alive(decoy.pid), "same-named client was killed"
            assert len([call for call in calls() if call[0] == "niri"]) == 2
            assert not any("topbar" in call for call in calls() if call[0] == "systemctl"), calls()
            invoke("restart", "awww-normal")
            assert calls()[-1] == ["systemctl", "--user", "restart", "awww-normal"]

            os.kill(second[0], signal.SIGTERM)
            deadline = time.monotonic() + 5
            while alive(second[0]):
                assert time.monotonic() < deadline, "Nix panel did not exit"
                time.sleep(0.01)

            (root / "calls").write_text("")
            invoke("session-start", supervisor="shepherd")
            guix = panels(3)[2]
            assert guix[2] == "from-niri", guix
            assert b"NIRI_ENV=from-niri" in Path(f"/proc/{guix[1]}/environ").read_bytes()
            assert [call for call in calls() if call[:2] == ["herd", "start"]] == [
                ["herd", "start", unit]
                for unit in ("hypridle", "awww-normal", "awww-overview")
            ], calls()
            assert ["herd", "eval", "root", '(setenv "WAYLAND_DISPLAY" "wayland-test")'] in calls()
            assert len([call for call in calls() if call[0] == "niri"]) == 1
            assert calls().index(["herd", "eval", "root",
                                  '(setenv "WAYLAND_DISPLAY" "wayland-test")']) < calls().index(
                                      ["niri", "msg", "action", "spawn", "--", "topbar"])
            invoke("restart", "topbar", supervisor="shepherd")
            guix_restarted = panels(4)[3]
            assert guix_restarted[0] != guix[0] and guix_restarted[2] == "from-niri"
            assert b"NIRI_ENV=from-niri" in Path(f"/proc/{guix_restarted[1]}/environ").read_bytes()
            assert not alive(guix[0]) and alive(guix[1]), "Guix panel's application was killed"
            assert alive(decoy.pid), "Guix restart killed a same-named client"
            assert len([call for call in calls() if call[0] == "niri"]) == 2
            assert not any("topbar" in call for call in calls() if call[0] == "herd"), calls()
            invoke("restart", "awww-normal", supervisor="shepherd")
            assert calls()[-1] == ["herd", "restart", "awww-normal"]
        finally:
            if decoy is not None:
                decoy.terminate()
                decoy.wait(timeout=5)
            for panel, child, _ in [json.loads(line) for line in (root / "panels").read_text().splitlines()]:
                for pid in (panel, child):
                    if alive(pid):
                        os.kill(pid, signal.SIGTERM)
    print("svc: Niri panel restart preserves app children; other services unchanged")


if __name__ == "__main__":
    main()
