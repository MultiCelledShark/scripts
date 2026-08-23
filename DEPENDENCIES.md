# Dependencies

Installation requirements for scripts in this repository. Most scripts target a **Linux desktop** (primarily **X11**) and assume tooling like **dwm + dwmblocks**, paths such as `~/pics`, and `DISPLAY=:0`. They may need configuration tweaks on Wayland or other setups.

---

## Quick install

### Arch Linux

```bash
# Core UI / menus / notifications
sudo pacman -S dmenu libnotify st ttf-liberation fzf bat jq bc curl wget xclip

# Images / screenshots / wallpapers
sudo pacman -S imagemagick scrot slop xdotool feh python-pywal gimp darktable perl-image-exiftool sqlite

# Audio / video
sudo pacman -S ffmpeg pulseaudio-utils alsa-utils xdpyinfo mpv playerctl mpc mpd pulsemixer

# System monitoring / desktop
sudo pacman -S lm_sensors sysstat htop xorg-xrandr xorg-xdpyinfo xorg-xephyr slock

# Python
sudo pacman -S python python-opencv
```

**Optional / alternatives (Arch repos or AUR):**

```bash
sudo pacman -S dunst wmenu neovim networkmanager
# AUR examples: ueberzugpp, nsxiv, cliphist, dysk, sowm, playerctl-loop
```

### Debian / Ubuntu

```bash
sudo apt install bash dmenu libnotify-bin stterm fonts-liberation fzf bat jq bc curl wget xclip \
  imagemagick scrot slop xdotool feh gimp darktable libimage-exiftool-perl sqlite3 \
  ffmpeg pulseaudio-utils alsa-utils x11-utils mpv playerctl mpc mpd \
  lm-sensors sysstat htop x11-xserver-utils xserver-xephyr slock \
  python3 python3-opencv neovim
```

`pywal` on Debian/Ubuntu is often installed via pip:

```bash
pip install pywal
```

---

## By category

Install only what you need for the scripts you plan to use.

| Category | Minimum packages |
|---|---|
| **audio-video/** | `ffmpeg`, `pactl` or `pacmd`, `amixer`, `xdpyinfo`, `dmenu`, `notify-send` |
| **images-photos-wallpapers/** | `imagemagick`, `fzf`, `ueberzugpp`, `xclip`, `dmenu`, `notify-send`, `wal`, `python3`, `python-opencv` |
| **shortcuts-menus/** | `dmenu`, `notify-send`, `xclip`, `jq`, `curl`, `bc`, `mpc` + `mpd`, `nvim` |
| **statusbar/** | `sensors`, `sysstat`, `playerctl`, `amixer`, `curl`, `imagemagick`, `jq` |
| **shell/** | `xrandr`, `notify-send`, `sensors`, `sysstat`, `bat`, `Xephyr` |

---

## Core runtime

Used by most scripts.

| Dependency | Used by |
|---|---|
| **bash** | Most scripts |
| **sh** | `audioswitch`, `musicplaying`, `fzfub` |
| **coreutils** (`date`, `mkdir`, `mv`, `find`, `stat`, etc.) | Widespread |
| **awk**, **sed**, **grep** | Widespread |

---

## Menus, notifications, terminals

| Dependency | Used by | Notes |
|---|---|---|
| **dmenu** | Most menu scripts | Primary picker UI |
| **wmenu** | `photomenu`, `phototransfer` | Optional dmenu replacement |
| **notify-send** (`libnotify`) | Most interactive scripts | Desktop notifications |
| **dunstify** | `imgmgk`, `photomenu` | Optional; falls back to `notify-send` |
| **st** (suckless terminal) | `fzfub-*`, `imgcliphist`, `photomenu`, clipboard menus | Hardcoded font/geometry |
| **Liberation Mono** font | Same as above | Used in `st -f 'Liberation Mono:...'` |

**Environment variables often expected:** `TERMINAL`, `EDITOR`, `DISPLAY`

---

## Clipboard and preview tooling

| Dependency | Used by |
|---|---|
| **xclip** | `screenshot`, `imgcliphist`, `txtcliphist`, `define`, clipboard menus |
| **wl-paste** | `define` | Optional Wayland fallback |
| **fzf** | `fzfub`, wallpaper/image pickers |
| **ueberzugpp** | `fzfub`, `fzfubrefresh`, clipboard history menus |
| **uuidgen** | `fzfub` |
| **bat** | `fzfub` (text preview fallback), `shell/stats` |
| **cliphist** | `fzfub` (mode `c`), referenced in clipboard scripts |
| **file** | `imgcliphist`, `img-text-clipboard-history` |
| **wget** | `imgcliphist`, `random_wallpaper`, clipboard menus |

---

## Image, photo, and wallpaper

| Dependency | Used by |
|---|---|
| **ImageMagick** (`magick`, `mogrify`, `composite`, `import`) | `imgmgk`, `screenshot`, `photomenu`, `aurora`, `random_wallpaper` |
| **scrot** | `minimal-screenshot` | Alternative to `import` |
| **slop** | `screenshot` | Optional region picker for color mode |
| **xdotool** | `screenshot` | Window capture mode |
| **nsxiv** | `wallpapermenu`, `photomenu` | Optional; falls back to dmenu |
| **pywal** (`wal`) | `wallpapermenu`, `fzfub-wallpapermenu` |
| **feh** | `random_wallpaper` |
| **gimp** | `photomenu`, `fzfub` bindings |
| **darktable** | `photomenu`, `phototransfer` |
| **darktable-cli** | `photomenu` (`dttg`) |
| **exiftool** | `photomenu` |
| **sqlite3** | `photomenu` (reads Darktable DB) |
| **python3** | `focusdetect.py`, `photomenu` |
| **python-opencv** (`cv2`) | `focusdetect.py` |

### In-repo scripts to put on `$PATH`

These scripts call each other and should be available in your shell:

- `fzfub`
- `fzfubrefresh`
- `imgmgk`
- `imgcliphist` (called by `screenshot`)
- `wallpapermenu` (called by `fzfub`)
- `focusdetect.py`

### Expected paths and files

- `~/pics/` — photos and wallpapers
- `~/pics/watermark.png` — watermark image for `imgmgk` / `photomenu`
- `~/scripts/pywal16` — pywal post-run hook
- `/mnt/sdcard/` — SD card mount for `photomenu` / `phototransfer`

---

## Audio and video

| Dependency | Used by |
|---|---|
| **ffmpeg** | `record`, `editrec`, `guitarrec` |
| **PulseAudio tools** (`pactl`) | `audioswitch`, `guitarrec` |
| **pacmd** | `old-audioswitch` |
| **amixer** | `record`, `stats`, `musicplaying` |
| **xdpyinfo** | `record` |
| **X11 screen grab** (ffmpeg `-f x11grab`) | `record` |
| **ALSA capture** (ffmpeg `-f alsa`) | `record` |
| **mpv** | `mpv`, `aurora`, `musicplaying` |
| **playerctl** | `musicplaying` |
| **playerctl-loop** | `musicplaying` | Custom/helper script, not a standard package |
| **mpc** + **mpd** | `musicpicker` |
| **pulsemixer** | `musicplaying` |

**Manual config required:**

- `old-audioswitch` — set PulseAudio sink names before use
- `guitarrec` — uses hardcoded Pulse source/sink IDs

---

## System, status bar, and desktop integration

| Dependency | Used by | Notes |
|---|---|---|
| **xrandr** | `dimmer`, `random_wallpaper` | |
| **dwmblocks** | `timer`, `disks`, `musicplaying`, `aurora`, `record`, `guitarrec` | Sends refresh signals via `pkill -RTMIN+*` |
| **sensors** (`lm-sensors`) | `stats`, `systemstats` | |
| **iostat** (`sysstat`) | `stats`, `systemstats` | |
| **free** | `stats`, `systemstats` | Usually in `procps` |
| **htop** | `systemstats` | |
| **nvidia-smi** | `systemstats` | Optional; NVIDIA GPU temps |
| **dysk** | `disks` | Optional disk info popup |
| **systemctl** | `sys`, `musicplaying`, photo transfer | |
| **slock** | `sys` | |
| **shutdown** | `sys` | Usually in `systemd` or `sysvinit` |
| **curl** | `define`, `aurora`, `random_wallpaper` | |
| **jq** | `audioswitch`, `define` | |
| **bc** | `temp`, `random_wallpaper` | |
| **nmcli** (NetworkManager) | `random_wallpaper` | |
| **xfconf-query** | `random_wallpaper` | XFCE only |
| **Xephyr** | `xephyr` | |
| **sowm** | `xephyr` | Test WM inside Xephyr |

**Arch-specific:** `shell/stats` reads `/var/lib/pacman/local` for the “last update” date.

---

## Editors and misc utilities

| Dependency | Used by |
|---|---|
| **neovim** (`nvim`) | `notes` |
| **setsid** | `notes`, `aurora`, statusbar click handlers | Usually in `util-linux` |

---

## Non-package setup

1. Add repo scripts to `$PATH` (or symlink into `~/.local/bin`).
2. Configure **PulseAudio sink names** in `old-audioswitch`.
3. Set **`TERMINAL`** and **`EDITOR`** environment variables.
4. Create expected directories: `~/pics`, `~/notes`, `~/.cache/hist`, `~/Screenshots`.
5. For status bar scripts: wire them into **dwmblocks** and handle `BLOCK_BUTTON` clicks.
6. For `photomenu` / `phototransfer`: mount SD card at `/mnt/sdcard`.
7. Several scripts hardcode **`DISPLAY=:0`** — adjust if your display differs.
8. `musicplaying` expects a **`playerctl-loop`** helper running in the background.

---

## Package name reference

| Tool | Arch package | Debian/Ubuntu package |
|---|---|---|
| notify-send | `libnotify` | `libnotify-bin` |
| st | `st` | `stterm` |
| Liberation Mono | `ttf-liberation` | `fonts-liberation` |
| ImageMagick | `imagemagick` | `imagemagick` |
| exiftool | `perl-image-exiftool` | `libimage-exiftool-perl` |
| pywal | `python-pywal` | `pip install pywal` |
| OpenCV (Python) | `python-opencv` | `python3-opencv` |
| PulseAudio CLI | `pulseaudio-utils` | `pulseaudio-utils` |
| xdpyinfo | `xdpyinfo` (`xorg-xdpyinfo`) | `x11-utils` |
| xrandr | `xorg-xrandr` | `x11-xserver-utils` |
| Xephyr | `xorg-xephyr` | `xserver-xephyr` |
| sensors | `lm_sensors` | `lm-sensors` |
| iostat | `sysstat` | `sysstat` |
