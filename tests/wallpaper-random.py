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
        notification_log = root / "notifications.jsonl"
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
        fake_notify = bin_dir / "notify-send"
        fake_notify.write_text(
            f"#!{sys.executable}\n"
            + '''import json
import os
from pathlib import Path
import sys

args = sys.argv[1:]
with Path(os.environ["WALLPAPER_TEST_NOTIFICATIONS"]).open("a") as log:
    log.write(json.dumps(args) + "\\n")
starting = "--print-id" in args
if os.environ["WALLPAPER_TEST_FAILURE"] == ("notify-start" if starting else "notify-complete"):
    sys.exit(1)
if starting:
    print(42)
'''
        )
        fake_notify.chmod(0o755)
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
            WALLPAPER_TEST_NOTIFICATIONS=str(notification_log),
            WALLPAPER_TEST_DISPLAY=str(display),
            MAGICK_THREAD_LIMIT="1",
        )

        def invoke(*args, success=True, **overrides):
            log.write_text("")
            notification_log.write_text("")
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

        def notifications():
            return [json.loads(line) for line in notification_log.read_text().splitlines()]

        def rendered_notification():
            start, complete = notifications()
            assert "--print-id" in start
            assert "--replace-id=42" in complete
            for args, maximum in ((start, 60000), (complete, 5000)):
                timeout = next(arg.split("=", 1)[1] for arg in args if arg.startswith("--expire-time="))
                assert 0 < int(timeout) <= maximum, args

        def published():
            targets = []
            for link in links:
                assert link.is_symlink(), link
                target = link.readlink()
                assert target.is_absolute() and target == link.resolve(strict=True), target
                assert target.is_file(), target
                targets.append(target)
            normal = Path((display / "normal").read_text())
            assert normal.is_absolute() and normal.is_file(), normal
            assert normal == targets[0], "normal display did not use the original image"
            info = subprocess.run(
                [imagemagick, str(targets[1]), "-format", "%m %wx%h", "info:"],
                check=True,
                capture_output=True,
                text=True,
                env=env,
            ).stdout
            assert info == "PNG 3840x2160", info
            return tuple(targets)

        def pixel(image):
            return subprocess.run(
                [imagemagick, str(image), "-crop", "1x1+0+0", "+repage", "-depth", "8", "RGB:-"],
                check=True,
                capture_output=True,
                env=env,
            ).stdout

        invoke(WALLPAPER_DIR=str(single), WALLPAPER_TEST_FAILURE="missing-overview")
        rendered_notification()
        previous = published()
        assert previous[0] == first
        assert not (cache / "tinted").exists(), "normal display created a tinted cache"
        assert not (display / "overview").exists()
        for _ in range(6):
            invoke()
            current = published()
            assert current[0] in (first, second)
            assert current[0] != previous[0], "random action repeated the current image"
            assert current[1] != previous[1], "lockscreen retained the previous image"
            previous = current

        assert current[0] == first
        invoke("--file", str(pool / "second.webp"))
        current = published()
        assert current[0] == second, "explicit selection did not resolve a pool symlink"
        invoke("--file", "Pictures/Wallpapers/nested/first.PNG")
        current = published()
        assert current[0] == first, "relative selection with a nested pool entry failed"
        assert (display / "overview").read_text() == str(current[1])

        invalid_extension = pool / "notes.txt"
        invalid_extension.write_text("not a wallpaper\n")
        for selection in (
            str(first),  # The target exists, but the entry is outside the pool.
            str(pool / "../../themes/first/background image.png"),
            str(invalid_extension),
            str(pool / "missing.png"),
            "",
        ):
            assert not invoke("--file", selection, success=False)
            assert published() == current

        invoke("--file", str(pool / "second.webp"), success=False,
               WALLPAPER_TEST_FAILURE="normal")
        assert published() == current, "failed display changed the selected image"

        theme_current.unlink()
        theme_current.symlink_to("second", target_is_directory=True)
        assert links[0].resolve(strict=True) == first, "theme replacement retargeted the wallpaper"
        cached = current[1].stat()
        invoke("--refresh")
        assert not notifications(), "cache hit sent a rendering notification"
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
        assert len(notifications()) == 1 and "--print-id" in notifications()[0]
        assert published() == current
        assert set(cache.rglob("*")) == cache_entries, "conversion failure leaked temporary assets"

        old_blurred = current[1]
        invoke("--refresh", WALLPAPER_BLUR_RADIUS="0x2")
        current = published()
        assert current[0] == first and current[1] != old_blurred
        assert not old_blurred.exists(), "replaced lockscreen blur remains cached"
        cached = current[1].stat()
        invoke("--refresh", WALLPAPER_BLUR_RADIUS="0x2")
        assert published() == current
        assert current[1].stat().st_ino == cached.st_ino
        assert current[1].stat().st_mtime_ns == cached.st_mtime_ns
        env["WALLPAPER_BLUR_RADIUS"] = "0x2"

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

        source = current[0]
        assert pixel(current[1]) == pixel(source), "blur did not derive from the original image"
        original_blur = current[1].stat()
        tinted_cache = cache / "tinted"
        tinted_cache.mkdir()
        legacy_tint = tinted_cache / ("a" * 64 + ".png")
        stale_blur = cache / "blurred" / ("b" * 64 + ".png")
        shutil.copyfile(source, legacy_tint)
        shutil.copyfile(current[1], stale_blur)
        user_tint = tinted_cache / "keep.png"
        user_blur = cache / "blurred" / "keep.png"
        user_tint.write_bytes(b"user tint cache")
        user_blur.write_bytes(b"user blur cache")
        outside_cache = cache_storage / "unrelated.png"
        outside_cache.write_bytes(b"unrelated XDG contents")
        linked_image = tinted_cache / ("c" * 64 + ".png")
        linked_image.symlink_to(outside_cache)

        invoke("--refresh", success=False, WALLPAPER_TEST_FAILURE="normal")
        assert legacy_tint.is_file() and stale_blur.is_file(), "failure pruned the cache"
        assert published() == current

        invoke("--refresh")
        assert not legacy_tint.exists() and not stale_blur.exists(), "stale generated images remain"
        assert published() == current
        assert (current[1].stat().st_ino, current[1].stat().st_mtime_ns) == (
            original_blur.st_ino, original_blur.st_mtime_ns
        ), "cleanup removed the active blur"
        assert pixel(source) == bytes((255, 0, 0)), "source wallpaper was modified"
        assert pixel(current[1]) == pixel(source), "blur did not derive from the source"
        assert user_tint.read_bytes() == b"user tint cache"
        assert user_blur.read_bytes() == b"user blur cache"
        assert linked_image.is_symlink() and outside_cache.read_bytes() == b"unrelated XDG contents"

        linked_image.unlink()
        user_tint.unlink()
        tinted_cache.rmdir()
        outside_dir = cache_storage / "user images"
        outside_dir.mkdir()
        outside_image = outside_dir / ("d" * 64 + ".png")
        outside_image.write_bytes(b"source image outside the cache")
        tinted_cache.symlink_to(outside_dir, target_is_directory=True)
        invoke("--refresh")
        assert outside_image.read_bytes() == b"source image outside the cache"
        assert tinted_cache.is_symlink()

        for failure in ("notify-start", "notify-complete"):
            current[1].unlink()
            invoke("--refresh", WALLPAPER_TEST_FAILURE=failure)
            assert published() == current
            assert pixel(current[1]) == pixel(source), "notification failure prevented rendering"
            if failure == "notify-start":
                assert len(notifications()) == 1 and "--print-id" in notifications()[0]
            else:
                rendered_notification()

        # The picker passes pool entries with spaces; invalid images preserve pointers.
        spaced = pool / "selected wallpaper.png"
        spaced.symlink_to(first)
        invoke("--file", str(spaced))
        selected = published()
        assert selected[0] == first
        broken_entry = pool / "broken image.png"
        broken_entry.symlink_to(broken / "broken.png")
        assert not invoke("--file", str(broken_entry), success=False)
        assert published() == selected

    print("wallpaper-random: behavior checks passed")


if __name__ == "__main__":
    main()
