# dotfiles

Hyprland + Noctalia desktop on CachyOS: a monochrome shell that takes its palette from the
wallpaper, frosted glass on every shell surface, and Material 3 motion. Editors and terminals
use the [Tyrian Night](https://github.com/renbkna/tyrian-night) theme.

| Part | Version tested | Config |
|---|---|---|
| Hyprland (Lua config) | 0.57 | `.config/hypr/` |
| Noctalia shell | 5.4 | `.config/noctalia/config.toml` |
| Ghostty | 1.3 | `.config/ghostty/config` |
| fish + Starship + fastfetch | | `.config/fish/`, `.config/starship.toml`, `.config/fastfetch/` |
| Qt: qt6ct-kde + Darkly | Darkly 0.5 | `.config/qt6ct/`, `.config/darklyrc` |
| Icons: Papirus-Dark with grey folders | Papirus 20260801 | `.local/bin/papirus-grey-folders` |

## Design

- **Colour:** Noctalia generates an `m3-monochrome` palette from the wallpaper and writes it
  to GTK, Qt (KColorScheme), Hyprland borders and Discord through its templates. Coding tools
  (Ghostty, Zed, VS Code, fish) keep Tyrian Night on purpose.
- **Glass:** one blur, defined in Hyprland. Shell surfaces (bar capsules, panels, dock,
  notifications, desktop cards) are tinted to 0.8 and blurred by the layer rules in
  `.config/hypr/shell/layout.lua`. App content stays opaque; Qt menus and toolbars are 80%.
- **Motion:** Material 3 curves in `.config/hypr/hyprland.lua`: entrances decelerate over
  400 ms, exits accelerate away in 200 ms, everything else uses the standard curve.
- **Desktop:** photo and caption top right, note bottom right, clock, date and media player
  bottom left, laid out for a 2560x1440 monitor with 96 px margins and 32 px gaps.

## Install

The repository is a bare git repo whose work tree is `$HOME`, so files stay where the
programs expect them and nothing is symlinked.

```fish
git clone --bare https://github.com/renbkna/dotfiles.git ~/.dotfiles
function dots; git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv; end
dots checkout            # move any conflicting files aside first if it refuses
dots config status.showUntrackedFiles no
dots config core.hooksPath ~/.config/dotfiles/hooks
```

Then:

1. Enable Noctalia's `hyprland` template (already in `config.toml`) and run
   `noctalia msg templates-apply`. It generates `~/.config/hypr/noctalia.lua`, which
   `hyprland.lua` requires for border colours.
2. Install the Tyrian Night terminal themes from tyrian-night for Ghostty and fish.
3. Optional: create the machine-specific files below.

## Local overrides (never committed)

| File | Holds |
|---|---|
| `~/.config/noctalia/local.toml` | Note and caption text, the photo path, wallpaper paths. Sorts after `config.toml`, so its keys win. |
| `~/.config/hypr/shell/local.lua` | Rules that name a monitor by description, which includes its serial number. Loaded only if present. |

Example `local.toml`:

```toml
[desktop_widgets.widget.mem_a.settings]
image_path = "/home/you/Pictures/photo.png"   # export at 548x408 so it is not resampled

[desktop_widgets.widget.note_1.settings]
title = "Note"
description = "•  first line"
```

The pre-commit hook in `.config/dotfiles/hooks/` refuses any commit that stages a local or
secret file, or that contains a value from the local override files, coordinates or an
API-key pattern.

## Requirements

Hyprland 0.57+, Noctalia 5.4+, Ghostty, fish, Starship, fastfetch, eza, zoxide, direnv,
qt6ct-kde, Darkly, Papirus icon theme, the Bibata Modern Ice cursor and the Myna font.
Keybinds launch Ghostty, Zed (`zeditor`), Helium, Nautilus and Equibop.
