#!/usr/bin/env python3
"""Exercise Umbriel helpers with fake compositor/backlight commands, never a session."""

import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile

SOURCE = Path(os.environ.get("TREV_DESKTOP_DOTFILES") or Path(__file__).resolve().parents[1]).resolve()
HELPERS = SOURCE / "umbriel/.local/bin"
STATE = "umbriel-idle-brightness.state"
LOCK = "umbriel-idle-brightness.lock"
OUTPUTS = [{"name": "eDP-1", "enabled": True, "powered": True}]
MOCK = r'''
import json
import os
from pathlib import Path
import sys

root = Path(os.environ["UMBRIEL_TEST_ROOT"])
name, args = Path(sys.argv[0]).name, sys.argv[1:]
with (root / "calls").open("a") as output:
    output.write(json.dumps([name, *args]) + "\n")
if name == "noctalia":
    assert args == ["dmenu", "--prompt", "Workspace layout"], args
    (root / "choices").write_text(sys.stdin.read())
    sys.stdout.write(os.environ.get("UMBRIEL_TEST_CHOICE", ""))
    sys.exit(int(os.environ.get("UMBRIEL_TEST_MENU_EXIT", "0")))
elif name == "umbriel":
    if args == ["outputs", "--json"]:
        print(os.environ["UMBRIEL_TEST_OUTPUTS"])
    else:
        assert args[:2] == ["msg", "workspace-set-layout"] and len(args) == 3, args
elif name == "ln":
    if os.environ.get("UMBRIEL_TEST_PUBLISH_FAIL"):
        sys.exit(1)
    os.execv(os.environ["UMBRIEL_TEST_REAL_LN"], ["ln", *args])
elif name == "brightnessctl":
    assert args[0] == "--class=backlight", args
    devices = json.loads((root / "backlights").read_text())
    explicit = len(args) > 1 and args[1].startswith("--device=")
    device = args[1].split("=", 1)[1] if explicit else devices["default"]
    operation = args[2:] if explicit else args[1:]
    if device not in devices["values"]:
        print("no such backlight", file=sys.stderr)
        sys.exit(1)
    current, maximum = devices["values"][device]
    if operation == ["--machine-readable", "info"]:
        if os.environ.get("UMBRIEL_TEST_BAD_INFO"):
            print(os.environ["UMBRIEL_TEST_BAD_INFO"])
        else:
            print(f"{device},backlight,{current},{(current * 100 + maximum // 2) // maximum}%,{maximum}")
    else:
        assert explicit and operation[0] == "set" and len(operation) == 2, args
        assert operation[1].isdigit(), operation
        if os.environ.get("UMBRIEL_TEST_WRITE_FAIL"):
            print("backlight write failed", file=sys.stderr)
            sys.exit(1)
        devices["values"][device][0] = int(operation[1])
        (root / "backlights").write_text(json.dumps(devices))
else:
    raise AssertionError((name, args))
'''


def main():
    bash = shutil.which("bash")
    real_ln = shutil.which("ln")
    for name in ("jq", "flock", "stat", "mktemp", "rm"):
        assert shutil.which(name), f"{name} is required (the helper's runtime dependency)"
    assert bash and real_ln, "bash and coreutils ln are required"
    for name in ("umbriel-layout-picker", "umbriel-idle-brightness"):
        assert (HELPERS / name).is_file(), f"helper missing from selected source: {HELPERS / name}"

    with tempfile.TemporaryDirectory(prefix="umbriel-") as temporary:
        root = Path(temporary)
        bindir = root / "bin"
        bindir.mkdir()
        mock = bindir / "mock.py"
        mock.write_text("#!" + sys.executable + "\n" + MOCK)
        mock.chmod(0o755)
        for name in ("noctalia", "umbriel", "brightnessctl", "ln"):
            (bindir / name).symlink_to("mock.py")

        def case(name):
            directory = root / name
            directory.mkdir()
            (directory / "runtime").mkdir(mode=0o700)
            (directory / "calls").touch()
            (directory / "backlights").write_text(json.dumps({
                "default": "amdgpu_bl1",
                "values": {"amdgpu_bl1": [64764, 65535], "other_backlight": [500, 1000]},
            }))
            return directory

        def calls(directory):
            return [json.loads(line) for line in (directory / "calls").read_text().splitlines()]

        def writes(directory):
            return [call for call in calls(directory) if call[0] == "brightnessctl" and "set" in call]

        def invoke(directory, *args, helper="umbriel-idle-brightness", **overrides):
            env = os.environ | {
                "PATH": str(bindir) + os.pathsep + os.environ["PATH"],
                "XDG_RUNTIME_DIR": str(directory / "runtime"),
                "UMBRIEL_TEST_ROOT": str(directory),
                "UMBRIEL_TEST_REAL_LN": real_ln,
                "UMBRIEL_TEST_OUTPUTS": json.dumps(OUTPUTS),
            } | overrides
            return subprocess.run([bash, str(HELPERS / helper), *args], env=env, cwd=directory,
                                  capture_output=True, text=True, timeout=10)

        def saved_state(directory, content):
            path = directory / "runtime" / STATE
            path.write_text(content)
            path.chmod(0o600)
            return path

        def successful(result):
            assert result.returncode == 0, (result.returncode, result.stdout, result.stderr)

        def failed(result):
            assert result.returncode != 0 and result.stderr, result

        for label in ("Scrolling", "Dwindle", "Master", "Stacking"):
            directory = case("layout-" + label)
            successful(invoke(directory, helper="umbriel-layout-picker", UMBRIEL_TEST_CHOICE=label + "\n"))
            assert (directory / "choices").read_text() == "Scrolling\nDwindle\nMaster\nStacking\n"
            assert calls(directory) == [["noctalia", "dmenu", "--prompt", "Workspace layout"],
                                        ["umbriel", "msg", "workspace-set-layout", label.lower()]]
        for index, (choice, status) in enumerate((("", "0"), ("Scrolling", "1"),
                                                 ("scrolling", "0"), ("Master ", "0"),
                                                 ("Scrolling\nMaster", "0"),
                                                 ("$(touch should-not-exist)", "0"))):
            directory = case(f"layout-reject-{index}")
            result = invoke(directory, helper="umbriel-layout-picker",
                            UMBRIEL_TEST_CHOICE=choice, UMBRIEL_TEST_MENU_EXIT=status)
            if not choice or status != "0":
                successful(result)
            else:
                failed(result)
            assert len(calls(directory)) == 1, calls(directory)
            assert not (directory / "should-not-exist").exists()

        directory = case("save-repeat-restore")
        successful(invoke(directory, "dim"))
        state = directory / "runtime" / STATE
        original = state.read_bytes()
        assert original == b"amdgpu_bl1 64764\n", original
        for path in (state, state.with_name(LOCK)):
            assert stat.S_IMODE(path.stat().st_mode) == 0o600
        assert [call for call in calls(directory) if call[0] == "brightnessctl"] == [
            ["brightnessctl", "--class=backlight", "--machine-readable", "info"],
            ["brightnessctl", "--class=backlight", "--device=amdgpu_bl1", "set", "10"],
        ]
        devices = json.loads((directory / "backlights").read_text())
        devices["default"] = "other_backlight"
        (directory / "backlights").write_text(json.dumps(devices))
        (directory / "calls").write_text("")
        successful(invoke(directory, "dim"))
        assert state.read_bytes() == original
        assert [call for call in calls(directory) if call[0] == "brightnessctl"][0] == [
            "brightnessctl", "--class=backlight", "--device=amdgpu_bl1", "--machine-readable", "info"]
        (directory / "calls").write_text("")
        successful(invoke(directory, "restore", UMBRIEL_TEST_OUTPUTS=json.dumps([
            {"name": "eDP-1", "enabled": True, "powered": False}])))
        assert not state.exists()
        assert not any(call[0] == "umbriel" for call in calls(directory))
        assert writes(directory) == [["brightnessctl", "--class=backlight", "--device=amdgpu_bl1", "set", "64764"]]
        devices = json.loads((directory / "backlights").read_text())
        assert devices["values"] == {"amdgpu_bl1": [64764, 65535], "other_backlight": [500, 1000]}
        (directory / "calls").write_text("")
        successful(invoke(directory, "restore"))
        assert not calls(directory)

        for index, outputs in enumerate(([], [{"name": "DP-1", "enabled": True, "powered": True}],
                                          [{"name": "eDP-1", "enabled": False, "powered": True}],
                                          [{"name": "eDP-1", "enabled": True, "powered": False}],
                                          [{"name": "eDP-1", "enabled": True, "powered": "true"}])):
            directory = case(f"skip-{index}")
            successful(invoke(directory, "dim", UMBRIEL_TEST_OUTPUTS=json.dumps(outputs)))
            assert calls(directory) == [["umbriel", "outputs", "--json"]]
            assert not (directory / "runtime" / STATE).exists()
        for index, outputs in enumerate(("not-json", '{"ok":[]}')):
            directory = case(f"bad-outputs-{index}")
            failed(invoke(directory, "dim", UMBRIEL_TEST_OUTPUTS=outputs))
            assert not writes(directory) and not (directory / "runtime" / STATE).exists()

        directory = case("write-failure-recovery")
        failed(invoke(directory, "dim", UMBRIEL_TEST_WRITE_FAIL="1"))
        state = directory / "runtime" / STATE
        assert state.read_bytes() == original
        successful(invoke(directory, "dim"))
        assert state.read_bytes() == original
        failed(invoke(directory, "restore", UMBRIEL_TEST_WRITE_FAIL="1"))
        assert state.read_bytes() == original
        successful(invoke(directory, "restore"))
        assert not state.exists()
        assert json.loads((directory / "backlights").read_text())["values"]["amdgpu_bl1"][0] == 64764

        for index, content in enumerate(("", "garbage\n", "amdgpu_bl1 10%\n", "* 42\n",
                                          "amdgpu_bl1 -1\n", "amdgpu_bl1 42\nextra\n",
                                          "amdgpu_bl1 42\0\n", "amdgpu_bl1 42")):
            directory = case(f"malformed-state-{index}")
            state = saved_state(directory, content)
            failed(invoke(directory, "restore"))
            assert state.read_text() == content and not calls(directory)

        directory = case("missing-saved-device")
        state = saved_state(directory, "removed_backlight 123\n")
        failed(invoke(directory, "restore"))
        assert state.read_text() == "removed_backlight 123\n" and not writes(directory)
        assert calls(directory) == [["brightnessctl", "--class=backlight", "--device=removed_backlight",
                                     "--machine-readable", "info"]]
        directory = case("mismatched-saved-device")
        state = saved_state(directory, "amdgpu_bl1 64764\n")
        failed(invoke(directory, "restore", UMBRIEL_TEST_BAD_INFO="other_backlight,backlight,500,50%,1000"))
        assert state.read_bytes() == original and not writes(directory)
        directory = case("out-of-range-saved-value")
        state = saved_state(directory, "amdgpu_bl1 70000\n")
        failed(invoke(directory, "restore"))
        assert state.read_text() == "amdgpu_bl1 70000\n" and not writes(directory)

        for index, info in enumerate(("amdgpu_bl1,backlight,64764,65535,99%", "*,backlight,10,1%,1000",
                                      "amdgpu_bl1,leds,10,1%,1000", "amdgpu_bl1,backlight,10,1%,1000\nextra",
                                      "amdgpu_bl1,backlight,0,0%,0", "amdgpu_bl1,backlight,1001,100%,1000",
                                      "amdgpu_bl1,backlight,10,101%,1000")):
            directory = case(f"bad-info-{index}")
            failed(invoke(directory, "dim", UMBRIEL_TEST_BAD_INFO=info))
            assert not writes(directory) and not (directory / "runtime" / STATE).exists()
        directory = case("state-publication-failure")
        failed(invoke(directory, "dim", UMBRIEL_TEST_PUBLISH_FAIL="1"))
        assert not writes(directory) and not (directory / "runtime" / STATE).exists()
        assert not list((directory / "runtime").glob("." + STATE + ".*"))

        for mode in ("dim", "restore"):
            for name in (STATE, LOCK):
                for kind in ("symlink", "dangling", "directory", "hardlink"):
                    directory = case(f"unsafe-{mode}-{name}-{kind}")
                    target = directory / "unrelated"
                    if kind != "dangling":
                        target.write_text("do not change\n")
                        target.chmod(0o600)
                    path = directory / "runtime" / name
                    if kind in ("symlink", "dangling"):
                        path.symlink_to(target)
                    elif kind == "directory":
                        path.mkdir(mode=0o700)
                    else:
                        os.link(target, path)
                    failed(invoke(directory, mode))
                    assert not calls(directory) and os.path.lexists(path)
                    if kind == "dangling":
                        assert not target.exists()
                    else:
                        assert target.read_text() == "do not change\n"
        directory = case("nonempty-lock")
        lock = directory / "runtime" / LOCK
        lock.write_text("unrelated\n")
        lock.chmod(0o600)
        failed(invoke(directory, "dim"))
        assert lock.read_text() == "unrelated\n" and not calls(directory)
        directory = case("public-runtime")
        (directory / "runtime").chmod(0o755)
        failed(invoke(directory, "dim"))
        assert not calls(directory)
        directory = case("runtime-link")
        link = directory / "runtime-link"
        link.symlink_to(directory / "runtime", target_is_directory=True)
        failed(invoke(directory, "dim", XDG_RUNTIME_DIR=str(link)))
        failed(invoke(directory, "dim", XDG_RUNTIME_DIR=str(link) + "/"))
        failed(invoke(directory, "dim", XDG_RUNTIME_DIR=""))
        assert not calls(directory)
        for args in ((), ("invalid",), ("dim", "restore")):
            result = invoke(directory, *args)
            assert result.returncode == 2 and result.stderr and not calls(directory)

    print("umbriel: layout allowlist; private atomic brightness save, skip, restore and failure recovery")


if __name__ == "__main__":
    main()
