#!/usr/bin/env python3
"""Exercise capture/editor/publication boundaries without a desktop or real images."""

import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile

HELPER = Path(__file__).resolve().parents[1] / "bin/.local/bin/mango-screenshot"
PNG = b"\x89PNG\r\n\x1a\nfixture-image"
MOCK = r'''
import json
import os
from pathlib import Path
import subprocess
import sys

root = Path(os.environ["CAPTURE_TEST_ROOT"])
name, args = Path(sys.argv[0]).name, sys.argv[1:]
scenario = os.environ.get("CAPTURE_TEST_SCENARIO", "")
with (root / "calls").open("a") as output:
    output.write(json.dumps([name, *args]) + "\n")
png = b"\x89PNG\r\n\x1a\nfixture-image"
if name == "date":
    print("2026-01-02_03-04-05_000000001")
elif name == "slurp":
    if scenario == "selection-cancel":
        sys.exit(1)
    print("10,20 300x200")
elif name == "mmsg":
    if scenario == "malformed":
        print("not-json")
    elif scenario == "missing":
        print('{"error":"no focused client"}')
    elif args == ["get", "all-monitors"]:
        print('{"monitors":[{"name":"WL-1","active":true}]}')
    else:
        assert args == ["get", "focusing-client"], args
        print('{"foreign_toplevel_id":"native-handle"}')
elif name == "grim":
    if scenario == "denied":
        sys.exit(1)
    assert args[:2] in (["-g", "10,20 300x200"], ["-o", "WL-1"],
                        ["-T", "native-handle"]), args
    Path(args[-1]).write_bytes(b"" if scenario == "empty" else png)
elif name == "satty":
    assert "--save-after-copy" in args and "--early-exit" in args, args
    assert args[args.index("--actions-on-enter") + 1] == "save-to-clipboard", args
    assert args[args.index("--actions-on-escape") + 1] == "exit", args
    assert Path(args[args.index("--filename") + 1]).read_bytes() == png
    if scenario == "editor-fail":
        sys.exit(1)
    if scenario != "editor-cancel":
        result = png + b"-annotated"
        Path(args[args.index("--output-filename") + 1]).write_bytes(result)
        subprocess.run(args[args.index("--copy-command") + 1].split(), input=result, check=True)
elif name == "wl-copy":
    assert args == ["--type", "image/png"], args
    (root / "clipboard").write_bytes(sys.stdin.buffer.read())
elif name != "notify-send":
    raise AssertionError(name)
'''


def main():
    assert shutil.which("jq"), "jq is required (the same dependency as the helper)"
    bash = shutil.which("bash")
    assert bash, "bash is required (the helper's interpreter)"
    with tempfile.TemporaryDirectory(prefix="mango-screenshot-") as temporary:
        root = Path(temporary)
        bindir = root / "bin"
        bindir.mkdir()
        mock = bindir / "mock.py"
        mock.write_text("#!" + sys.executable + "\n" + MOCK)
        mock.chmod(0o755)
        for name in ("grim", "slurp", "satty", "mmsg", "date", "wl-copy", "notify-send"):
            (bindir / name).symlink_to("mock.py")

        def invoke(mode, scenario="", home=None):
            home = home or root / (mode + "-" + scenario)
            home.mkdir(exist_ok=True)
            (home / "calls").touch()
            env = os.environ | {
                "HOME": str(home), "CAPTURE_TEST_ROOT": str(home),
                "CAPTURE_TEST_SCENARIO": scenario,
                "PATH": str(bindir) + ":" + os.environ["PATH"],
            }
            # Like svc.py's explicit sh, avoid assuming /usr/bin/env exists in a Nix shell.
            result = subprocess.run([bash, str(HELPER), mode], env=env, capture_output=True,
                                    text=True, timeout=10)
            calls = [json.loads(line) for line in (home / "calls").read_text().splitlines()]
            images = list((home / "Pictures/Screenshots").glob("Screenshot_from_*.png"))
            return result, calls, images, home

        for mode in ("region", "output", "window"):
            result, calls, images, home = invoke(mode)
            assert result.returncode == 0, result.stderr
            assert len(images) == 1 and images[0].read_bytes().startswith(PNG), images
            assert images[0].read_bytes() == (home / "clipboard").read_bytes()
            assert stat.S_IMODE(images[0].stat().st_mode) == 0o600
            assert not list(images[0].parent.glob(".mango-screenshot.*"))
            if mode == "window":
                assert [call[1:3] for call in calls if call[0] == "grim"] == [["-T", "native-handle"]]

        for scenario in ("selection-cancel", "editor-cancel"):
            result, calls, images, home = invoke("region", scenario)
            assert result.returncode == 0 and not images, (result, images)
            assert not (home / "clipboard").exists()
            assert not list((home / "Pictures/Screenshots").iterdir())
            if scenario == "selection-cancel":
                assert not any(call[0] in ("grim", "satty") for call in calls), calls

        for mode, scenario in (("window", "missing"), ("output", "missing"),
                               ("window", "malformed"), ("output", "malformed"),
                               ("window", "denied"), ("output", "empty"),
                               ("region", "editor-fail")):
            result, calls, images, home = invoke(mode, scenario)
            assert result.returncode != 0 and not images, (result, images)
            assert not (home / "clipboard").exists()
            assert not list((home / "Pictures/Screenshots").iterdir())
            if scenario in ("missing", "malformed"):
                assert not any(call[0] == "grim" for call in calls), calls
            if scenario == "denied":
                assert len([call for call in calls if call[0] == "grim"]) == 1, calls

        result, _, images, home = invoke("output", "collision")
        assert result.returncode == 0, result.stderr
        original = images[0].read_bytes()
        result, _, images, _ = invoke("output", "collision", home)
        assert result.returncode != 0 and len(images) == 1, (result, images)
        assert images[0].read_bytes() == original
        preserved = list(images[0].parent.glob(".mango-screenshot.*/capture.png"))
        assert len(preserved) == 1 and preserved[0].read_bytes() == PNG, preserved
        assert str(preserved[0]) in result.stderr, result.stderr
        result, calls, images, _ = invoke("invalid")
        assert result.returncode == 2 and not calls and not images
    print("mango-screenshot: modes, cancellation, privacy failures and no-clobber publication")


if __name__ == "__main__":
    main()
