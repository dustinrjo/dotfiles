# public dotfiles repo

using gnu Stow

## Structure
Each top-level directory represents a "package" (e.g., bash, nvim_omarchy). Stow symlinks the contents of these directories into the home directory (~).

## Installation
```bash
# Install stow
sudo pacman -S stow # Arch
sudo apt install stow # Ubuntu/Debian

# Clone and deploy
git clone [https://github.com/USER/dotfiles.git](https://github.com/USER/dotfiles.git) ~/dotfiles
cd ~/dotfiles
stow bash
stow nvim_omarchy
```

## Adding New Configs
1. Create the mirror path: `mkdir -p ~/dotfiles/name/.config`
2. Move the original: `mv ~/.config/name ~/dotfiles/name/.config/`
3. Link it: `cd ~/dotfiles && stow name`

## Maintenance
Changes made to files in `~` are reflected in `~/dotfiles` because they are symlinks. 
To save changes:
```bash
cd ~/dotfiles
git add .
git commit -m "update config"
git push
```

## Removing Links
```bash
stow -D package_name
```
