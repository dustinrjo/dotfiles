# public dotfiles repo

Using GNU Stow. Targets Omarchy 4 on Linux and macOS.

## Structure

Each top-level directory is a stow "package" whose contents mirror the layout of
`~`. Stow symlinks them into the home directory.

| Package | Platform | Contents |
| --- | --- | --- |
| `nvim_omarchy` | both | `~/.config/nvim` (LazyVim + Omarchy 4 defaults, plus personal tweaks) |
| `bash_omarchy` | Linux | `~/.bashrc` |
| `zsh_mac` | macOS | `~/.zshrc` |
| `homebrew_mac` | macOS | `~/.Brewfile` |
| `iterm2` | macOS | colour scheme, imported manually — not stowed |

`bootstrap.sh` sets up a fresh machine end to end; `install.sh` just does the
stowing and is safe to re-run.

## Installation

### Fresh machine (the one-liner)

`bootstrap.sh` does the whole thing: system update, installs stow, clones this
repo, links it into `$HOME`, and installs the Neovim plugins.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dustinrjo/dotfiles/master/bootstrap.sh)
```

**It is for a machine whose current shell and editor config you do not care
about** — it discards the existing `~/.bashrc` and `~/.config/nvim` contents in
favour of this repo's. It prints exactly what it is about to discard and asks
before doing it (`--yes` skips the prompt).

```
--skip-update   Don't run the system update
--skip-nvim     Don't run the initial 'Lazy! sync'
-y, --yes       Don't prompt before discarding existing config
```

`DOTFILES_REPO` and `DOTFILES_DIR` override the repo and clone location.

### Manual

If you'd rather do it by hand, or you're on a machine with config worth keeping:

#### Omarchy (and other Arch systems)

On a clean Omarchy install the pacman sync databases are not populated yet, so
`pacman -S stow` fails with "target not found". Sync through Omarchy first:

```bash
omarchy update        # snapshot, keyrings, db sync, upgrade, migrations
sudo pacman -S stow
```

Do **not** reach for `sudo pacman -Syu`. Omarchy's `00-omarchy-update-guard`
pre-transaction hook aborts any pacman command carrying both `-S` and `-u`, and
tells you to use `omarchy update` instead. Plain `sudo pacman -S <pkg>` has no
`-u` and is never blocked.

#### Ubuntu/Debian

```bash
sudo apt install stow
```

#### macOS

```bash
brew install stow
```

#### Deploy

```bash
git clone https://github.com/dustinrjo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` picks the right packages for the platform. To do it by hand:

```bash
stow nvim_omarchy
stow bash_omarchy     # Linux only
```

### First run on a machine that already has these configs

Stow refuses to overwrite real files. A fresh Omarchy install already ships a
real `~/.bashrc` and a populated `~/.config/nvim`, so the first `stow` will
report conflicts. Either move the originals aside, or let stow absorb them:

```bash
./install.sh --adopt   # or: stow --adopt nvim_omarchy
git diff               # review — then `git checkout -- .` to keep the repo's version
```

`--adopt` moves the existing files *into* the repo and then links them, so always
check `git diff` afterwards to see which side won. This is exactly what
`bootstrap.sh` automates.

## Omarchy shell plugins

The lock screen lives in its own repo, not here: it is a Quickshell plugin, and
Omarchy installs and updates those itself.

| Plugin | Repo |
| --- | --- |
| `oedo.lock` — lock screen | https://github.com/dustinrjo/omarchy-lock-oedo |

`bootstrap.sh` installs them on a fresh machine. To do it by hand:

```bash
omarchy plugin add https://github.com/dustinrjo/omarchy-lock-oedo.git --enable
omarchy plugin update oedo.lock          # later, to pull changes
omarchy plugin enable omarchy.lock       # switch back to the stock lock screen
```

They are deliberately not stow packages. `omarchy plugin update` only works on
a real git checkout, and `omarchy plugin add` refuses a symlinked target, so
stowing one would trade away updates for nothing. See the plugin repo's README
for the full toggle and update instructions.

Nor is `~/.config/omarchy/shell.json` tracked here, even though it records
which plugins are enabled: Omarchy's update migrations rewrite it with
`jq ... > tmp && mv tmp shell.json`, and that `mv` would replace a stow symlink
with a regular file, silently detaching it from this repo. `--enable` makes
tracking it unnecessary.

## Omarchy 4 notes

Things that changed from Omarchy 3 and that this repo now accounts for:

- **`~/.bashrc` must source `env-bootstrap` first.** Omarchy moved from
  `~/.local/share/omarchy` to `/usr/share/omarchy`, and `OMARCHY_PATH` is set by
  `/usr/share/omarchy/default/bash/env-bootstrap`. A `.bashrc` that sources
  `~/.local/share/omarchy/default/bash/rc` silently loses every Omarchy alias and
  the PATH setup.
- **Don't track `~/.config/nvim/lua/plugins/theme.lua`.** Omarchy manages it as a
  symlink to `~/.local/state/omarchy/current/theme/neovim.lua`, so it follows the
  active theme. Stowing a copy replaces the symlink and pins the colorscheme,
  breaking `omarchy theme set` for Neovim. It is in `.gitignore` for this reason —
  set your colorscheme with `omarchy theme set`, not in this repo.
- **No `hypr` package.** Hyprland config is Lua now (`hyprland.lua`,
  `bindings.lua`, `monitors.lua`, …) and hyprlock is gone, replaced by
  `omarchy-system-lock`. The files Omarchy ships in `~/.config/hypr` are
  comment-only override stubs loaded *after* Omarchy's defaults, so package
  updates can improve the defaults without rewriting them. Nothing there is
  customized yet; committing pristine stubs would just freeze them. If you do
  customize one, add a `hypr_omarchy` package containing only that file:

  ```bash
  mkdir -p ~/dotfiles/hypr_omarchy/.config/hypr
  mv ~/.config/hypr/monitors.lua ~/dotfiles/hypr_omarchy/.config/hypr/
  cd ~/dotfiles && stow hypr_omarchy
  ```

## Adding New Configs

1. Create the mirror path: `mkdir -p ~/dotfiles/name/.config`
2. Move the original: `mv ~/.config/name ~/dotfiles/name/.config/`
3. Link it: `cd ~/dotfiles && stow name`

Before moving a whole directory, check it for symlinks Omarchy owns
(`find <dir> -type l`) and leave those in place.

## Maintenance

Changes made to files in `~` are reflected in `~/dotfiles` because they are
symlinks. To save changes:

```bash
cd ~/dotfiles
git add .
git commit -m "update config"
git push
```

This includes writes made by tools, not just your own edits — Lazy rewrites
`lazy-lock.json` through the symlink whenever it installs or updates a plugin,
so `git status` after a `:Lazy sync` is normal and worth committing.

After Omarchy or LazyVim updates change the tracked defaults, re-run
`git diff` before committing so an upstream improvement isn't reverted.

### Syncing another machine

Once a machine is bootstrapped, pulling is all it takes — the symlinks already
point into the repo, so updated files are live immediately:

```bash
cd ~/dotfiles && git pull
```

Two caveats:

- **New files need a re-stow.** A pull that adds a file to a package doesn't
  create its symlink. Run `./install.sh` again (it uses `--restow`, so it is
  safe to repeat) to link anything new.
- **Restart the shell** after `~/.bashrc` changes: `exec bash`.

Don't re-run `bootstrap.sh` on an already-bootstrapped machine to pick up
changes. It's for first-time setup and will discard uncommitted local config.

## Removing Links

```bash
stow -D package_name
```
