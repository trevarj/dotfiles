#!/usr/bin/env python3
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


HELPER = Path(__file__).resolve().parents[1] / "wallpapers/.local/bin/wallpaper-random"


def main():
    imagemagick = shutil.which("magick") or shutil.which("convert")
    if imagemagick is None:
        raise SystemExit("ImageMagick (magick or convert) is required")

    with tempfile.TemporaryDirectory(prefix="wallpaper-random-") as temporary:
        root = Path(temporary).resolve()
        home = root / "home"
        pool = home / "Pictures/Wallpapers"
        nested = pool / "nested"
        nested.mkdir(parents=True)
        assets = home / "themes"
        first = assets / "first/background image.png"
        second = assets / "second/background image.png"
        for image, color in ((first, "red"), (second, "blue")):
            image.parent.mkdir(parents=True)
            subprocess.run(
                [imagemagick, "-size", "4x3", f"xc:{color}", str(image)],
                check=True,
                capture_output=True,
            )
        theme_current = assets / "current"
        theme_current.symlink_to("first", target_is_directory=True)
        (nested / "first.PNG").symlink_to(theme_current / first.name)
        (pool / "first-alias.jpg").symlink_to(first)
        (pool / "second.webp").symlink_to(second)
        single = root / "single"
        single.mkdir()
        (single / "only.png").symlink_to(first)
        empty = root / "empty"
        empty.mkdir()
        broken = root / "broken"
        broken.mkdir()
        (broken / "broken.png").write_bytes(b"not an image\n")

        cache_storage = root / "cache assets"
        cache_storage.mkdir()
        cache_alias = root / "cache link"
        cache_alias.symlink_to(cache_storage, target_is_directory=True)
        cache = cache_storage / "wallpaper"
        links = (cache / "current.png", cache / "current-blurred.png")
        display = root / "display"
        display.mkdir()
        log = root / "awww.jsonl"
        bin_dir = root / "bin"
        bin_dir.mkdir()
        fake_awww = bin_dir / "awww"
        fake_awww.write_text(
            f"#!{sys.executable}\n"
            + '''import json
import os
from pathlib import Path
import sys

args = sys.argv[1:]
with Path(os.environ["WALLPAPER_TEST_LOG"]).open("a") as log:
    log.write(json.dumps(args) + "\\n")
namespace = args[args.index("-n") + 1]
normal = os.environ["WALLPAPER_NORMAL_NAMESPACE"]
overview = os.environ["WALLPAPER_OVERVIEW_NAMESPACE"]
failure = os.environ["WALLPAPER_TEST_FAILURE"]
if args[0] == "query":
    assert namespace == overview
    sys.exit(1 if failure == "missing-overview" else 0)
assert args[0] == "img" and namespace in (normal, overview)
if (namespace == normal and failure == "normal") or (
    namespace == overview and failure in ("overview", "missing-overview")
):
    print("fake awww: image rejected", file=sys.stderr)
    sys.exit(1)
image = Path(args[args.index("--resize") + 2])
assert image.is_file()
state = Path(os.environ["WALLPAPER_TEST_DISPLAY"])
(state / ("normal" if namespace == normal else "overview")).write_text(str(image))
'''
        )
        fake_awww.chmod(0o755)
        env = os.environ.copy()
        env.pop("BASH_ENV", None)
        env.pop("ENV", None)
        env.update(
            HOME=str(home),
            XDG_CACHE_HOME=str(cache_alias),
            PATH=str(bin_dir) + os.pathsep + os.environ.get("PATH", os.defpath),
            WALLPAPER_DIR="Pictures/Wallpapers",
            WALLPAPER_NORMAL_NAMESPACE="test-normal",
            WALLPAPER_OVERVIEW_NAMESPACE="test-overview",
            WALLPAPER_BLUR_RADIUS="0x1",
            WALLPAPER_TEST_LOG=str(log),
            WALLPAPER_TEST_DISPLAY=str(display),
            MAGICK_THREAD_LIMIT="1",
        )

        def invoke(*args, success=True, **overrides):
            log.write_text("")
            result = subprocess.run(
                ["bash", str(HELPER), *args],
                cwd=home,
                env=env | {"WALLPAPER_TEST_FAILURE": ""} | overrides,
                capture_output=True,
                text=True,
            )
            assert (result.returncode == 0) == success, (
                args, overrides, result.returncode, result.stdout, result.stderr
            )
            if not success:
                assert result.stderr.strip(), "failure must report a diagnostic"
            return [json.loads(line) for line in log.read_text().splitlines()]

        def published():
            targets = []
            for link in links:
                assert link.is_symlink(), link
                target = link.readlink()
                assert target.is_absolute() and target == link.resolve(strict=True), target
                assert target.is_file(), target
                targets.append(target)
            assert (display / "normal").read_text() == str(targets[0])
            info = subprocess.run(
                [imagemagick, str(targets[1]), "-format", "%m %wx%h", "info:"],
                check=True,
                capture_output=True,
                text=True,
                env=env,
            ).stdout
            assert info == "PNG 3840x2160", info
            return tuple(targets)

        invoke(WALLPAPER_DIR=str(single), WALLPAPER_TEST_FAILURE="missing-overview")
        previous = published()
        assert previous[0] == first
        assert not (display / "overview").exists()
        for _ in range(6):
            invoke()
            current = published()
            assert current[0] in (first, second)
            assert current[0] != previous[0], "random action repeated the current image"
            assert current[1] != previous[1], "lockscreen retained the previous image"
            previous = current

        assert current[0] == first
        theme_current.unlink()
        theme_current.symlink_to("second", target_is_directory=True)
        assert links[0].resolve(strict=True) == first, "theme replacement retargeted the wallpaper"
        cached = current[1].stat()
        invoke("--refresh")
        assert published() == current
        assert current[1].stat().st_ino == cached.st_ino
        assert current[1].stat().st_mtime_ns == cached.st_mtime_ns

        for _ in range(2):
            invoke(WALLPAPER_DIR=str(single))
            current = published()
            assert current[0] == first

        old_overview = (display / "overview").read_text()
        old_blurred = current[1]
        invoke(WALLPAPER_TEST_FAILURE="missing-overview")
        current = published()
        assert current[0] == second
        assert current[1] != old_blurred, "missing overview left the lockscreen stale"
        assert (display / "overview").read_text() == old_overview

        old_blurred = current[1]
        invoke(success=False, WALLPAPER_TEST_FAILURE="overview")
        current = published()
        assert current[0] == first
        assert current[1] != old_blurred, "overview failure left the lockscreen stale"
        assert (display / "overview").read_text() == old_overview

        invoke(success=False, WALLPAPER_TEST_FAILURE="normal")
        assert published() == current
        cache_entries = set(cache.rglob("*"))
        assert not invoke(success=False, WALLPAPER_DIR=str(broken))
        assert published() == current
        assert set(cache.rglob("*")) == cache_entries, "conversion failure leaked temporary assets"

        old_blurred = current[1]
        invoke("--refresh", WALLPAPER_BLUR_RADIUS="0x2")
        current = published()
        assert current[0] == first and current[1] != old_blurred
        cached = current[1].stat()
        invoke("--refresh", WALLPAPER_BLUR_RADIUS="0x2")
        assert published() == current
        assert current[1].stat().st_ino == cached.st_ino
        assert current[1].stat().st_mtime_ns == cached.st_mtime_ns

        for args, overrides in (
            ((), {"WALLPAPER_DIR": str(empty)}),
            (("--unknown",), {}),
            (("--refresh", "anything"), {}),
        ):
            assert not invoke(*args, success=False, **overrides)
            assert published() == current

        links[0].unlink()
        missing = root / "missing.png"
        links[0].symlink_to(missing)
        assert not invoke("--refresh", success=False)
        assert links[0].is_symlink() and links[0].readlink() == missing
        assert links[1].readlink() == current[1]
        assert (display / "normal").read_text() == str(current[0])
        links[0].unlink()
        links[0].symlink_to(current[0])

        for link in links:
            target = link.readlink()
            for directory in (False, True):
                link.unlink()
                if directory:
                    link.mkdir()
                    sentinel = link / "keep"
                else:
                    sentinel = link
                sentinel.write_bytes(b"keep this user data\n")
                assert not invoke(success=False), "pointer conflicts must fail before rendering"
                assert sentinel.read_bytes() == b"keep this user data\n"
                other = links[1] if link == links[0] else links[0]
                assert other.readlink() == current[1 if link == links[0] else 0]
                assert (display / "normal").read_text() == str(current[0])
                sentinel.unlink()
                if directory:
                    link.rmdir()
                link.symlink_to(target)
        assert published() == current

    print("wallpaper-random: behavior checks passed")


if __name__ == "__main__":
    main()
