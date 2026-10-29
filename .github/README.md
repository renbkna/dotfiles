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
| Packages (pacman first, AUR through paru) | | `.config/dotfiles/packages/`, `.local/bin/dotfiles-packages` |
| System: greetd + noctalia-greeter, Plymouth, THP, nice limit | | `.local/bin/dotfiles-system` |
| Session: Hyprland target, Noctalia service, monthly trash cleanup | | `.config/systemd/user/` |
| Editors: Zed and VSCodium settings and extensions | | `.config/zed/`, `.config/VSCodium/User/`, `.config/dotfiles/vscodium-extensions.txt` |

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

## Install on a new machine

1. Install CachyOS without a desktop, so no edition config sits where this one goes.
2. Check out the dotfiles. The repository is a bare git repo whose work tree is `$HOME`, so
   files stay where the programs expect them.

   ```fish
   git clone --bare https://github.com/renbkna/dotfiles.git ~/.dotfiles
   function dots; git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv; end
   dots checkout            # move any conflicting files aside first if it refuses
   dots config status.showUntrackedFiles no
   dots config core.hooksPath ~/.config/dotfiles/hooks
   ```

3. Run `~/.local/bin/dotfiles-bootstrap`. It installs `packages/common.txt`, applies
   `dotfiles-system` with sudo, enables the user services, clones tyrian-night to
   `~/Projects/tyrian-night` and links its Ghostty themes, its fish greeting, the fish startup
   file for the variant `config.ghostty` names and the Zed theme, installs the VSCodium
   extensions (building Tyrian Night from the checkout), and sets the icon theme for GTK and
   KDE. On the ASUS TUF A15 also run `dotfiles-packages install asus-tuf-a15`.
4. Reboot, log in through the greeter (Hyprland shows a missing `noctalia.lua` until the next
   step), and run `dotfiles-bootstrap` again. Inside the session it applies Noctalia's
   templates, which write `~/.config/hypr/noctalia.lua` and build the icon theme.
5. Restore what no repository holds: the local overrides below, the photo and wallpapers they
   name, SSH keys, `gh auth login`, `~/.config/fish/fish_variables` and browser profiles.
6. On other hardware, adjust the monitors in `.config/hypr/shell/outputs.lua` and the desktop
   widget positions in `.config/noctalia/config.toml` (laid out for 2560x1440).

Rerun `dotfiles-bootstrap` after changing the Ghostty theme; rerunning is always safe.
`dotfiles-packages diff` reports packages installed or removed outside the lists, and
`dotfiles-system --check` reports system configuration that has drifted.

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
