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
| System: greetd + noctalia-greeter, Plymouth, THP | | `.local/bin/dotfiles-system` |
| Session: Hyprland target, Noctalia service, monthly trash cleanup | | `.config/systemd/user/` |
| Editors: Zed and VSCodium settings and extensions | | `.config/zed/`, `.config/VSCodium/User/`, `.config/dotfiles/vscodium-extensions.txt` |

## Design

- **Colour:** Noctalia generates an `m3-monochrome` palette from the wallpaper and writes it
  to GTK, Qt (KColorScheme), Hyprland borders and Discord through its templates. A user
  template gives Papirus folders the Papirus colour nearest the palette's primary, so a
  neutral palette keeps them grey. `.config/qt6ct/qt6ct.conf` names that theme; the script
  builds it under that name and the bootstrap points GTK and KDE at it. Coding tools (Ghostty,
  Zed, VS Code, fish, the Starship prompt and the fastfetch greeting) keep Tyrian Night on
  purpose.
- **Glass:** one blur, defined in Hyprland. Bar capsules and desktop cards are tinted to 0.8,
  panels use Noctalia's soft transparency, and the dock and notifications keep Noctalia's
  defaults; the layer rules in `.config/hypr/shell/layout.lua` blur all of them. Ghostty is
  translucent (0.82) over the same blur; other app content stays opaque, and Qt menus and
  toolbars are 80%.
- **Motion:** Material 3 curves; `.config/hypr/hyprland.lua` sets which animation uses which.
- **Desktop:** photo and caption top right, note bottom right, clock, date and media player
  bottom left, laid out for a 2560x1440 monitor in `.config/noctalia/config.toml`.

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

3. Run `~/.local/bin/dotfiles-bootstrap`. It installs this machine's package lists
   (`packages/common.txt`, plus any list whose `# machine:` header names this board), applies
   `dotfiles-system` with sudo, enables the user services, installs the Myna 2.0 font from its
   pinned release, clones tyrian-night to `~/Projects/tyrian-night` and links its Ghostty
   themes, its fish greeting, the fish startup file for the variant `config.ghostty` names and
   the Zed theme, installs the VSCodium extensions (building Tyrian Night from the checkout),
   and sets the icon theme for GTK and KDE.
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
