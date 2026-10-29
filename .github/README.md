# dotfiles

Hyprland + Noctalia desktop on CachyOS: a monochrome shell that takes its palette from the
wallpaper, frosted glass on every shell surface, and Material 3 motion. Editors and terminals
use the [Tyrian Night](https://github.com/renbkna/tyrian-night) theme.

| Part | Version tested | Config |
|---|---|---|
| Hyprland (Lua config) | 0.57 | `.config/hypr/` |
| Noctalia shell | 5.4 | `.config/noctalia/config.toml` |
| Ghostty | 1.4 | `.config/ghostty/config.ghostty` |
| fish + Starship + fastfetch | fish 4.9 | `.config/fish/`, `.config/fastfetch/` |
| Qt: qt6ct-kde + Darkly | Darkly 0.5 | `.config/qt6ct/`, `.config/darklyrc` |
| Icons: Papirus-Dark, folders follow the palette | Papirus 20260801 | `.local/bin/papirus-noctalia-folders` |

## Design

- **Colour:** Noctalia generates an `m3-monochrome` palette from the wallpaper and writes it
  to GTK, Qt (KColorScheme), Hyprland borders and Discord through its templates. A user
  template gives Papirus folders the Papirus colour nearest the palette's primary, so a
  neutral palette keeps them grey; GTK, Qt and KDE all name the resulting
  `Papirus-Dark-Noctalia` theme, which `.config/qt6ct/qt6ct.conf` defines. Coding tools
  (Ghostty, Zed, VS Code, fish, the Starship prompt and the fastfetch greeting) keep Tyrian
  Night on purpose.
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

Then log into Hyprland, open a terminal and run `~/.local/bin/dotfiles-bootstrap`. It clones
tyrian-night to `~/Projects/tyrian-night` and links its Ghostty themes, its fish greeting and
the fish startup file for the variant `config.ghostty` names (which wires the matching fish
colours, Starship prompt and fastfetch colours). It sets the icon theme for GTK (dconf) and KDE
(`kdeglobals`), and applies Noctalia's templates, which write the `~/.config/hypr/noctalia.lua`
that `hyprland.lua` requires for border colours and build the icon theme. Rerun it after
changing the Ghostty theme; rerunning is always safe.

Optionally, create the machine-specific files below.

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
qt6ct-kde, Darkly, Papirus icon theme, Python 3.9+, kwriteconfig6 (kconfig), the Bibata
Modern Ice cursor and the Myna font.
Keybinds launch Ghostty, Zed (`zeditor`), Helium, Nautilus and Equibop.
