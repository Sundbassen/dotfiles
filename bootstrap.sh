#!/usr/bin/env bash
# New-machine setup for Manjaro Sway. Safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACMAN_PKGS=(
  foot waybar mako wob swappy rofi cliphist wl-clipboard wtype playerctl wf-recorder
  rbw rofi-rbw helix vim htop btop zsh fzf jq github-cli act wireguard-tools
)
AUR_PKGS=(oh-my-zsh visual-studio-code-bin)
VSCODE_EXTENSIONS=(jdinhlife.gruvbox golang.go esbenp.prettier-vscode James-Yu.latex-workshop)

mapfile -t THEME_PKGS < "$REPO/sway/.config/sway/matcha-blue/packages"
sudo pacman -S --needed "${PACMAN_PKGS[@]}" "${THEME_PKGS[@]}"
if command -v yay >/dev/null; then
  yay -S --needed "${AUR_PKGS[@]}"
else
  echo "yay not found, install AUR packages by hand: ${AUR_PKGS[*]}"
fi

"$REPO/link.sh"

if command -v code >/dev/null; then
  for ext in "${VSCODE_EXTENSIONS[@]}"; do code --install-extension "$ext" --force >/dev/null; done
fi

mkdir -p "$HOME/Screenshots" "$HOME/.config/zsh/config.d"

outputs="$HOME/.config/sway/config.d/99-outputs.conf"
[[ -e "$outputs" ]] || cp "$outputs.example" "$outputs"

env_file="$HOME/.config/dotfiles.env"
[[ -e "$env_file" ]] || cp "$REPO/dotfiles.env.example" "$env_file"

src="$HOME/private/pkg-track/pkg-track.sh"
[[ -e "$src" && ! -e "$HOME/bin/pkg-track" ]] && ln -s "$src" "$HOME/bin/pkg-track"

cat <<EOF

Done. Remaining manual steps:
  1. Edit $env_file and $outputs
  2. Place ~/.ssh/id_ed25519 and the WireGuard conf; optionally ~/.bashrc.local
  3. gh auth login; rbw register (personal API key, needed on bitwarden.com), then rbw login
  4. Not packaged: fnm (https://github.com/Schniz/fnm), volta (https://volta.sh)
  5. Log out and back in so .profile and environment.d take effect
EOF
