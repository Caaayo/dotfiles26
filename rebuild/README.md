# Linux Environment Rebuild Script

Instantly rebuild any of your machines from scratch.

## File Structure

```
rebuild/
├── install.sh                  # Main script — run this
├── packages-common.txt         # Packages installed on every machine
├── packages-laptop.txt         # Laptop-only packages
├── packages-desktop.txt        # Desktop (CachyOS)-only packages
├── machines/
│   ├── laptop.conf             # Laptop profile (shell, services, extras)
│   └── desktop.conf            # Desktop profile (shell, services, extras)
└── README.md
```

## First-Time Setup

1. **Edit `install.sh`** — update the `DOTFILES_REPO` variable at the top:
   ```bash
   DOTFILES_REPO="https://github.com/YOUR_USERNAME/YOUR_DOTFILES_REPO.git"
   ```

2. **Update hostnames** — in `install.sh`, find the `detect_machine()` function and
   update the hostname patterns to match your actual machine hostnames:
   ```bash
   hostname  # run this on each machine to find out
   ```

3. **Structure your dotfiles repo for stow** — each subdirectory is a "package"
   that mirrors your home directory. Example:
   ```
   ~/.dotfiles/
   ├── hypr/
   │   └── .config/
   │       └── hypr/
   │           ├── hyprland.conf
   │           └── ...
   ├── waybar/
   │   └── .config/
   │       └── waybar/
   │           ├── config
   │           └── style.css
   ├── fish/
   │   └── .config/
   │       └── fish/
   │           └── config.fish
   └── bash/
       ├── .bashrc
       └── .bash_profile
   ```

4. **Customize your package lists** — add/remove packages in `packages-common.txt`,
   `packages-laptop.txt`, and `packages-desktop.txt` to match what you actually use.

## Usage

```bash
# Make executable (one-time)
chmod +x install.sh

# Run — you'll be prompted to choose laptop or desktop
./install.sh
```

## Adding a New Machine

1. Create `packages-MACHINENAME.txt` with any extra packages
2. Create `machines/MACHINENAME.conf` — copy an existing one as a template
3. Add the hostname pattern to `detect_machine()` in `install.sh`

## Updating Packages

Just edit the `.txt` files and commit. Next time you run `install.sh` on that machine,
it picks up the changes. Packages already installed are skipped (`--needed` flag).

## How Stow Works

Stow creates symlinks so editing a file in `~/.config/hypr/` is actually editing
`~/.dotfiles/hypr/.config/hypr/` — your repo stays automatically in sync.

```bash
# To manually stow a single package after adding it to your dotfiles repo:
cd ~/.dotfiles
stow --target="$HOME" --restow hypr
```

## Quick Reference

| Task | Command |
|------|---------|
| Full rebuild | `./install.sh` |
| Force machine profile | `./install.sh --machine desktop` |
| Re-stow dotfiles only | `cd ~/.dotfiles && stow --target=$HOME --restow */` |
| Update all packages | `yay -Syu` |
