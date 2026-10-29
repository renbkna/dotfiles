# dotfiles

Hyprland + Noctalia on CachyOS: a monochrome shell coloured from the wallpaper, frosted glass,
Material 3 motion. Editors and terminals use [Tyrian Night](https://github.com/renbkna/tyrian-night).

| Part | Tested | Config |
|---|---|---|
| Hyprland (Lua) | 0.57 | `.config/hypr/` |
| Noctalia | 5.4 | `.config/noctalia/` |
| Ghostty | 1.4 | `.config/ghostty/` |
| fish, Starship, fastfetch, atuin, fzf | fish 4.9 | `.config/fish/`, `.config/fastfetch/`, `.config/atuin/` |
| Qt: qt6ct-kde + Darkly | Darkly 0.5 | `.config/qt6ct/`, `.config/darklyrc` |
| Icons: Papirus-Dark, folders follow the palette | Papirus 20260801 | `.local/bin/papirus-noctalia-folders` |
| Packages | | `.config/dotfiles/packages/`, `.local/bin/dotfiles-packages` |
| System: greetd, Plymouth, THP | | `.local/bin/dotfiles-system` |
| Session services | | `.config/systemd/user/` |
| Editors | | `.config/zed/`, `.config/VSCodium/User/` |

## Design

- **Colour:** Noctalia's `m3-monochrome` palette reaches GTK, Qt, Hyprland borders, Discord and
  the Papirus folder colour through its templates. Coding tools keep Tyrian Night.
- **Glass:** one blur, in Hyprland (`.config/hypr/shell/layout.lua`); Noctalia surfaces and
  Ghostty are translucent over it.
- **Motion and layout:** set in `.config/hypr/hyprland.lua` and `.config/noctalia/config.toml`.

## Install on a new machine

1. Install CachyOS without a desktop.
2. Check out the bare repo (work tree `$HOME`):

   ```fish
   git clone --bare https://github.com/renbkna/dotfiles.git ~/.dotfiles
   function dots; git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv; end
   dots checkout            # move conflicting files aside if it refuses
   dots config status.showUntrackedFiles no
   dots config core.hooksPath ~/.config/dotfiles/hooks
   ```

3. Run `~/.local/bin/dotfiles-bootstrap` (its header lists what it does).
4. Reboot, log in through the greeter and run it again; Hyprland reports a missing
   `noctalia.lua` until then.
5. Restore what no repo holds: the local override below and what it names, SSH keys,
   `gh auth login`, `~/.config/fish/fish_variables`, browser profiles.
6. On other hardware, adjust `.config/hypr/shell/outputs.lua` and the widget positions in
   `.config/noctalia/config.toml`.

Rerun the bootstrap after changing the Ghostty theme. `dotfiles-packages diff` and
`dotfiles-system --check` report drift.

## Local override (never committed)

`~/.config/noctalia/local.toml` holds the note and caption text and the photo and wallpaper
paths; it overrides `config.toml`.

```toml
[desktop_widgets.widget.mem_a.settings]
image_path = "/home/you/Pictures/photo.png"   # 548x408, so it is not resampled

[desktop_widgets.widget.note_1.settings]
title = "Note"
description = "•  first line"
```

The pre-commit hook in `.config/dotfiles/hooks/` refuses commits that include a local or secret
file, a value from the override, coordinates or an API-key pattern.
