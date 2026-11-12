#!/usr/bin/env bash
# Symlink every file in the given packages into $HOME, file by file
# (same layout and semantics as `stow --no-folding`, without needing stow).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"
ALL_PACKAGES=(shell git bin sway tools vscode)

packages=("$@")
[[ ${#packages[@]} -eq 0 ]] && packages=("${ALL_PACKAGES[@]}")

status=0
for pkg in "${packages[@]}"; do
  src_root="$REPO/$pkg"
  [[ -d "$src_root" ]] || { echo "no such package: $pkg" >&2; exit 1; }

  while IFS= read -r -d '' src; do
    rel="${src#"$src_root"/}"
    dst="$TARGET/$rel"
    mkdir -p "$(dirname "$dst")"

    # A symlink inside a package (e.g. brave-flags.conf -> ./chrome-flags.conf)
    # is recreated with the same relative target instead of linking to the link.
    want="$src"
    [[ -L "$src" ]] && want="$(readlink "$src")"

    if [[ -L "$dst" ]]; then
      [[ "$(readlink "$dst")" == "$want" ]] && continue
      echo "conflict: $dst is a link to $(readlink "$dst")" >&2
      status=1
      continue
    fi
    if [[ -e "$dst" ]]; then
      echo "conflict: $dst exists; move it into $pkg/$rel or delete it" >&2
      status=1
      continue
    fi

    ln -s "$want" "$dst"
    echo "linked $rel"
  done < <(find "$src_root" \( -type f -o -type l \) -print0 | sort -z)
done

exit $status
