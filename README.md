# dotfiles

Personal config for Manjaro Sway machines. Each top-level package mirrors `$HOME`;
`link.sh` symlinks every file in it into place (same layout as GNU stow, no stow needed).

| Package  | Contents |
|----------|----------|
| `shell`  | bash, zsh, vim, dircolors |
| `git`    | identity, global ignore |
| `bin`    | personal scripts (`~/bin`) |
| `sway`   | sway keybindings and theme, waybar, foot, mako, wob, swappy, rofi-rbw, wallpaper |
| `tools`  | helix, nvim, htop, gh, chromium/electron flags |
| `vscode` | settings (Gruvbox with custom Go token colors), keybindings, tasks |

## New machine

```sh
git clone git@github.com:Sundbassen/dotfiles.git ~/private/dotfiles
~/private/dotfiles/bootstrap.sh
```

Bootstrap installs packages, links everything, seeds the two untracked local files and
prints what is left to do by hand (keys, logins).

## Local, untracked files

- `~/.config/dotfiles.env` — secrets and machine paths, template in `dotfiles.env.example`
- `~/.config/sway/config.d/99-outputs.conf` — monitor layout, template next to it
- `~/.bashrc.local` — work-specific aliases and functions, sourced last if present

Manjaro's own sway defaults in `/etc/sway` are not copied here; the `sway` package only
holds what sits on top of them. Same for waybar: `config.jsonc` and `style.css` include the
templates in `/usr/share/sway/templates/waybar` and only hold overrides.

## Day to day

Edit files in `$HOME` as usual, they are links into this repo. Then commit here.
New file: put it in the right package and run `./link.sh <package>`.
