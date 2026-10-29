#!/usr/bin/env fish

set -l test_root (mktemp -d); or exit 1

function cleanup --on-event fish_exit --inherit-variable test_root
    command rm -rf "$test_root"
end

set -gx HOME "$test_root/home"
set -gx XDG_STATE_HOME "$test_root/state"
mkdir -p "$HOME"

source (status dirname)/../functions/v.fish

function yt-dlp --inherit-variable test_root
    printf '%s\n' $argv >"$test_root/yt.args"
    if string match -q '*fail.example*' -- $argv[-1]
        return 7
    end
    return 0
end

function gallery-dl --inherit-variable test_root
    if contains -- -E $argv
        if string match -q '*instagram.com*' -- $argv[-1]
            return 0
        else if string match -q '*probe-fail.example*' -- $argv[-1]
            return 70
        end
        return 64
    end

    printf '%s\n' $argv >"$test_root/gallery.args"
    if string match -q '*fail.example*' -- $argv[-1]
        return 7
    end
    return 0
end

function expect_arg
    contains -- "$argv[2]" (string split \n <"$argv[1]"); or begin
        echo "missing argument: $argv[2]" >&2
        exit 1
    end
end

v audio https://example.com/watch "$test_root/music" >/dev/null; or exit 1
expect_arg "$test_root/yt.args" -x
expect_arg "$test_root/yt.args" "$test_root/state/v/audio.txt"
expect_arg "$test_root/yt.args" "$test_root/music"

v audio https://example.com/watch >/dev/null; or exit 1
expect_arg "$test_root/yt.args" "$HOME/Videos/v"

v https://www.instagram.com/stories/example/123/ "$test_root/social" >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" "$test_root/state/v/gallery.sqlite3"
expect_arg "$test_root/gallery.args" "$test_root/social"
expect_arg "$test_root/gallery.args" archive-event=file,skip

v https://www.instagram.com/stories/example/123/ >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" "$HOME/Videos/v"

v https://www.youtube.com/watch?v=example "$test_root/video" >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" ytdl:https://www.youtube.com/watch?v=example
expect_arg "$test_root/gallery.args" "$test_root/state/v/gallery.sqlite3"
expect_arg "$test_root/gallery.args" 'directory=["{extractor}"]'

v https://www.youtube.com/watch?v=example >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" "$HOME/Videos/v"

contains -- --cookies (string split \n <"$test_root/yt.args"); and begin
    echo "cookies should be optional" >&2
    exit 1
end

command rm -f "$test_root/gallery.args"
command rm -f "$test_root/yt.args"
v https://fail.example/video >/dev/null 2>&1
test $status -eq 7; or exit 1
test -e "$test_root/gallery.args"; or begin
    echo "failed route should retain its diagnostic arguments" >&2
    exit 1
end
expect_arg "$test_root/gallery.args" ytdl:https://fail.example/video
not test -e "$test_root/yt.args"; or begin
    echo "default downloads must not bypass the gallery-dl authority" >&2
    exit 1
end

command rm -f "$test_root/gallery.args"
v https://probe-fail.example/video >/dev/null 2>&1
test $status -eq 70; or exit 1
not test -e "$test_root/gallery.args"; or begin
    echo "probe failures must not select a download route" >&2
    exit 1
end

v reposts https://www.tiktok.com/@example "$test_root/reposts" >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" https://www.tiktok.com/@example/reposts
expect_arg "$test_root/gallery.args" extractor.tiktok.user.include=reposts
expect_arg "$test_root/gallery.args" "$test_root/reposts"

v reposts https://www.tiktok.com/@example >/dev/null; or exit 1
expect_arg "$test_root/gallery.args" "$HOME/Videos/v/tiktok-reposts"

set -gx XDG_STATE_HOME ""
v audio https://example.com/empty-xdg >/dev/null; or exit 1
expect_arg "$test_root/yt.args" "$HOME/.local/state/v/audio.txt"

exit 0
