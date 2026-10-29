function v --description "Download media without repeats"
    set -l default_outdir "$HOME/Videos/v"
    set -l cookie_file "$HOME/.config/fish/functions/.v.cookies.txt"
    set -l output_template "%(extractor)s/%(title).140s [%(id)s].%(ext)s"

    if test (count $argv) -eq 0
        set argv help
    end

    set -l mode smart

    switch $argv[1]
        case -h --help help
            echo "Usage:"
            echo "  v <url> [folder]              gallery-dl if supported, else yt-dlp"
            echo "  v audio <url> [folder]        audio only (alias: a)"
            echo "  v reposts <profile> [folder]  TikTok reposts (alias: r)"
            echo "  v where                       print the default folder"
            echo
            echo "Completed downloads are skipped automatically."
            return 0

        case where
            if test (count $argv) -ne 1
                echo "Usage: v where" >&2
                return 2
            end
            echo "$default_outdir"
            return 0

        case a audio
            set mode audio
            set -e argv[1]

        case r rp repost reposts
            set mode reposts
            set -e argv[1]
    end

    if test (count $argv) -lt 1; or test (count $argv) -gt 2
        echo "Usage: v [audio|reposts] <url> [folder]" >&2
        return 2
    end

    set -l url "$argv[1]"
    if not string match -qr '^https?://' -- "$url"
        echo "v: expected an http(s) URL" >&2
        return 2
    end

    set -l outdir "$default_outdir"
    set -l custom_outdir 0
    if test (count $argv) -eq 2
        set outdir (string replace -r '^~(?=/|$)' "$HOME" -- "$argv[2]")
        set custom_outdir 1
    end

    if test "$mode" = reposts; and test "$custom_outdir" -eq 0
        set outdir "$outdir/tiktok-reposts"
    end

    set -l state_dir "$HOME/.local/state/v"
    if set -q XDG_STATE_HOME; and test -n "$XDG_STATE_HOME"
        set state_dir "$XDG_STATE_HOME/v"
    end

    mkdir -p "$outdir" "$state_dir"; or return 1

    if test "$mode" = smart
        gallery-dl -E -- "$url" >/dev/null 2>&1
        set -l probe_status $status

        switch $probe_status
            case 0
                set mode gallery
            case 64
                set mode video
                set url "ytdl:$url"
            case '*'
                gallery-dl -E -- "$url" >/dev/null
                return $probe_status
        end
    end

    set -l cookie_args
    set -l runtime_cookie_file

    if test -r "$cookie_file"
        set runtime_cookie_file (mktemp); or return 1
        cp "$cookie_file" "$runtime_cookie_file"; or begin
            command rm -f "$runtime_cookie_file"
            return 1
        end
        chmod 600 "$runtime_cookie_file"; or begin
            command rm -f "$runtime_cookie_file"
            return 1
        end
        set cookie_args --cookies "$runtime_cookie_file"
    end

    echo "v: $mode -> $outdir"
    set -l code 0

    switch $mode
        case video
            gallery-dl \
                --download-archive "$state_dir/gallery.sqlite3" \
                -d "$outdir" \
                -f '{title[b:140]} [{id}].{extension}' \
                -o 'directory=["{extractor}"]' \
                -o extractor.ytdl.cmdline-args=--no-playlist \
                -o archive-event=file,skip \
                $cookie_args \
                -- "$url"
            set code $status

        case audio
            yt-dlp \
                --ignore-config \
                --no-playlist \
                --download-archive "$state_dir/audio.txt" \
                -P "$outdir" \
                -o "$output_template" \
                -f ba/b \
                -x \
                --audio-format best \
                --embed-metadata \
                --embed-thumbnail \
                $cookie_args \
                -- "$url"
            set code $status

        case gallery
            gallery-dl \
                --download-archive "$state_dir/gallery.sqlite3" \
                -D "$outdir" \
                -o archive-event=file,skip \
                $cookie_args \
                -- "$url"
            set code $status

        case reposts
            if string match -qr 'tiktok\.com/@[^/?#]+/?$' -- "$url"
                set url (string replace -r '/?$' '/reposts' -- "$url")
            end

            gallery-dl \
                --download-archive "$state_dir/gallery.sqlite3" \
                -D "$outdir" \
                -o archive-event=file,skip \
                $cookie_args \
                -- "$url"
            set code $status
    end

    if test -n "$runtime_cookie_file"
        command rm -f "$runtime_cookie_file"
    end

    return $code
end
