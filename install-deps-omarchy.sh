#!/usr/bin/env bash
# Install missing dependencies for these scripts on Omarchy (Arch + Hyprland).
# Omarchy already ships many tools; this script skips what is installed and
# warns about scripts that conflict with Omarchy's Wayland/Hyprland defaults.

set -euo pipefail

WITH_AUR=0
WITH_X11_LEGACY=0
WITH_PHOTO=0
DRY_RUN=0

usage() {
	cat <<'EOF'
Usage: install-deps-omarchy.sh [options]

Install packages these scripts need that Omarchy does not ship by default.

Options:
  --with-aur          Also install AUR packages (ueberzugpp, cliphist, dysk)
  --with-x11-legacy   Install X11 tools for unported scripts (not recommended)
  --with-photo        Install heavy photo workflow packages (darktable, gimp, exiftool)
  --dry-run           Print what would be installed, do not install
  -h, --help          Show this help

Omarchy already includes: fzf, bat, jq, imagemagick, mpv, playerctl, pamixer,
neovim, wl-clipboard, grim/slurp/satty, hyprpicker, mako, brightnessctl,
swaybg, imv, pinta, spotify, btop, pipewire-pulse (pactl), and yay.

Many scripts still assume X11 + dmenu + dwmblocks + xclip. See DEPENDENCIES.md
for the full conflict list and porting notes.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--with-aur) WITH_AUR=1 ;;
		--with-x11-legacy) WITH_X11_LEGACY=1 ;;
		--with-photo) WITH_PHOTO=1 ;;
		--dry-run) DRY_RUN=1 ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
	esac
	shift
done

if ! command -v pacman >/dev/null; then
	echo "Error: pacman not found. This script is for Arch/Omarchy." >&2
	exit 1
fi

# Omarchy base manifest (install/omarchy-base.packages) + pipewire-pulse.
# Listed for documentation; used only to explain skips, not as a hard blocklist.
OMARCHY_PREINSTALLED=(
	alsa-utils bat brightnessctl btop fzf grim hyprpicker imagemagick imv jq
	mako mpv neovim omarchy-walker pamixer pinta playerctl satty slurp spotify
	swaybg wl-clipboard wireplumber pipewire-pulse
)

# Core gaps for scripts that can run with minimal changes on Omarchy.
CORE_PACKAGES=(
	dmenu          # menus; Walker is not a dmenu pipe replacement
	bc             # temp, random_wallpaper
	curl           # define, aurora
	wget           # imgcliphist, random_wallpaper
	ffmpeg         # audio-video/* (often pulled by gpu-screen-recorder, but not guaranteed)
	lm_sensors     # stats, systemstats
	sysstat        # iostat in stats scripts
	sqlite           # photomenu (darktable DB)
)

PHOTO_PACKAGES=(
	darktable
	gimp
	perl-image-exiftool
	python-opencv
)

X11_LEGACY_PACKAGES=(
	xclip          # clipboard scripts; prefer porting to wl-clipboard on Wayland
	st             # fzfub menus hardcode st
	ttf-liberation # font used by st -f in several scripts
	scrot slop xdotool xorg-xdpyinfo xorg-xrandr xorg-xephyr
	feh            # random_wallpaper; conflicts with swaybg workflow
	slock          # sys; Omarchy uses hyprlock
	htop           # systemstats click handler; Omarchy ships btop instead
)

OPTIONAL_PACKAGES=(
	mpd mpc          # musicpicker; Omarchy defaults to Spotify
	pulsemixer       # musicplaying statusbar click
	wmenu            # photomenu optional dmenu replacement
)

AUR_PACKAGES=(
	ueberzugpp
	cliphist
	dysk
)

warn_conflicts() {
	cat <<'EOF'

=== Omarchy compatibility notes ===

Already covered by Omarchy (do not reinstall unless you want duplicates):
  - Menus/launcher: omarchy-walker (not a drop-in for "echo ... | dmenu")
  - Notifications: mako (notify-send works; skip dunst)
  - Clipboard: wl-clipboard (not xclip)
  - Screenshots: grim + slurp + satty + hyprpicker (not import/scrot)
  - Wallpapers: swaybg (not feh/pywal)
  - Screen brightness: brightnessctl / hyprsunset (not xrandr --brightness)
  - Screen recording: gpu-screen-recorder + omarchy capture scripts
  - Status bar: waybar (not dwmblocks)
  - Image viewer: imv (nsxiv is optional AUR alternative)
  - Editor: neovim; image touch-ups: pinta (gimp is optional)
  - Audio: pipewire + pamixer + playerctl + spotify

Likely conflicts / scripts that need porting on Omarchy:
  - statusbar/*     -> wired for dwmblocks signals and BLOCK_BUTTON
  - record          -> x11grab + alsa; use Omarchy screen recording instead
  - screenshot/*    -> ImageMagick import + xclip; use grim/slurp/satty
  - dimmer          -> xrandr; use brightnessctl or hyprsunset
  - random_wallpaper-> feh + xrandr + xfconf; use swaybg + Omarchy theming
  - wallpapermenu   -> pywal; fights Omarchy/aether theme management
  - fzfub* menus    -> hardcode st + DISPLAY=:0
  - clipboard menus -> xclip; switch to wl-copy / wl-paste
  - sys             -> slock; Omarchy uses hyprlock
  - musicpicker     -> mpc/mpd; Omarchy ships Spotify instead

Scripts that mostly work after installing dmenu + curl/wget/bc:
  - audioswitch, define, temp, notes, mpv, sys (except slock), txtcliphist (needs xclip or port)
  - editrec, guitarrec (after Pulse sink/source IDs are configured)

EOF
}

pkg_installed() {
	pacman -Q "$1" &>/dev/null
}

filter_missing() {
	local missing=()
	for pkg in "$@"; do
		pkg_installed "$pkg" || missing+=("$pkg")
	done
	((${#missing[@]})) && printf '%s\n' "${missing[@]}"
}

install_pacman() {
	local -a pkgs=("$@")
	local -a missing=()
	mapfile -t missing < <(filter_missing "${pkgs[@]}")
	if ((${#missing[@]} == 0)); then
		echo "All requested pacman packages already installed."
		return 0
	fi
	echo "Pacman install: ${missing[*]}"
	if ((DRY_RUN)); then
		return 0
	fi
	sudo pacman -S --needed --noconfirm "${missing[@]}"
}

install_aur() {
	if ! command -v yay >/dev/null; then
		echo "Error: yay not found. Omarchy normally ships yay; install an AUR helper first." >&2
		exit 1
	fi
	local -a pkgs=("$@")
	local -a missing=()
	for pkg in "${pkgs[@]}"; do
		pkg_installed "$pkg" || missing+=("$pkg")
	done
	if ((${#missing[@]} == 0)); then
		echo "All requested AUR packages already installed."
		return 0
	fi
	echo "AUR install: ${missing[*]}"
	if ((DRY_RUN)); then
		return 0
	fi
	yay -S --needed --noconfirm "${missing[@]}"
}

main() {
	warn_conflicts

	echo "Checking core packages..."
	install_pacman "${CORE_PACKAGES[@]}"

	if ((WITH_PHOTO)); then
		echo "Checking photo workflow packages..."
		install_pacman "${PHOTO_PACKAGES[@]}"
	fi

	if ((WITH_X11_LEGACY)); then
		echo "Checking X11 legacy packages (for unported scripts)..."
		install_pacman "${X11_LEGACY_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"
	else
		echo "Skipping X11 legacy stack (pass --with-x11-legacy to install xclip, st, scrot, feh, etc.)."
	fi

	if ((WITH_AUR)); then
		echo "Checking AUR packages..."
		install_aur "${AUR_PACKAGES[@]}"
	else
		echo "Skipping AUR packages (pass --with-aur for ueberzugpp, cliphist, dysk)."
	fi

	cat <<'EOF'

Done. Recommended Omarchy env tweaks (add to ~/.bashrc or Hyprland env):
  export TERMINAL=alacritty   # or foot on newer Omarchy
  export EDITOR=nvim

For clipboard scripts, consider symlinks or small wrappers:
  wl-copy as a partial xclip replacement will not work for all xclip flags;
  porting scripts to wl-clipboard is the reliable fix on Wayland.

See DEPENDENCIES.md -> "Omarchy" for script-by-script status.
EOF
}

main
