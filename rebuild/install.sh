#!/usr/bin/env bash
# =============================================================================
# install.sh — Linux Environment Rebuild Script
# Supports: Arch Linux / CachyOS (and other Arch-based distros)
# Usage:
#   ./install.sh                  # auto-detect machine by hostname
#   ./install.sh --machine laptop # force a specific machine profile
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

banner() {
  echo -e "${BOLD}"
  echo "╔══════════════════════════════════════════════╗"
  echo "║       Linux Environment Rebuild Script       ║"
  echo "╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
}

# ── Config ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO="https://github.com/Caaayo/dotfiles26.git"  # <── change this
DOTFILES_DIR="$HOME/.dotfiles"
MACHINES_DIR="$SCRIPT_DIR/machines"

# ── Choose machine profile ────────────────────────────────────────────────────
choose_machine() {
  echo ""
  echo -e "${BOLD}Which machine are you rebuilding?${NC}"
  echo ""
  echo "  1) laptop   — Arch Linux + Hyprland"
  echo "  2) desktop  — CachyOS (gaming PC)"
  echo ""

  while true; do
    read -rp "Enter 1 or 2: " choice
    case "$choice" in
      1) echo "laptop";  return ;;
      2) echo "desktop"; return ;;
      *) echo "  Please enter 1 or 2." ;;
    esac
  done
}

# ── Load machine config ───────────────────────────────────────────────────────
load_machine_config() {
  local machine="$1"
  local config_file="$MACHINES_DIR/${machine}.conf"

  [[ -f "$config_file" ]] || error "No config found for machine: $machine (expected $config_file)"

  info "Loading machine profile: ${BOLD}$machine${NC}"
  # shellcheck source=/dev/null
  source "$config_file"
}

# ── System update ─────────────────────────────────────────────────────────────
system_update() {
  info "Updating system packages..."
  sudo pacman -Syu --noconfirm
  success "System updated"
}

# ── Install yay (AUR helper) ──────────────────────────────────────────────────
install_yay() {
  if command -v yay &>/dev/null; then
    success "yay already installed"
    return
  fi

  info "Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel

  local tmp_dir
  tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
  (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp_dir"

  success "yay installed"
}

# ── Install packages ──────────────────────────────────────────────────────────
install_packages() {
  local machine="$1"
  local pkg_files=()

  [[ -f "$SCRIPT_DIR/packages-common.txt" ]]       && pkg_files+=("$SCRIPT_DIR/packages-common.txt")
  [[ -f "$SCRIPT_DIR/packages-${machine}.txt" ]]   && pkg_files+=("$SCRIPT_DIR/packages-${machine}.txt")

  if [[ ${#pkg_files[@]} -eq 0 ]]; then
    warn "No package lists found — skipping package installation"
    return
  fi

  local packages=()
  for file in "${pkg_files[@]}"; do
    # Strip comments and blank lines
    while IFS= read -r line; do
      line="${line%%#*}"   # remove inline comments
      line="${line//[$'\t\r\n']}"
      [[ -n "${line// }" ]] && packages+=("$line")
    done < "$file"
  done

  if [[ ${#packages[@]} -eq 0 ]]; then
    warn "Package lists are empty — skipping"
    return
  fi

  info "Installing ${#packages[@]} packages..."
  yay -S --needed --noconfirm "${packages[@]}"
  success "Packages installed"
}

# ── Clone dotfiles ────────────────────────────────────────────────────────────
clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR" ]]; then
    info "Dotfiles repo already exists — pulling latest..."
    git -C "$DOTFILES_DIR" pull
  else
    info "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
  success "Dotfiles ready at $DOTFILES_DIR"
}

# ── Stow dotfiles ─────────────────────────────────────────────────────────────
# Expects your dotfiles repo to have stow packages as subdirectories, e.g.:
#   ~/.dotfiles/hypr/     → contains .config/hypr/
#   ~/.dotfiles/waybar/   → contains .config/waybar/
#   ~/.dotfiles/fish/     → contains .config/fish/
#   ~/.dotfiles/bash/     → contains .bashrc etc.
stow_dotfiles() {
  if ! command -v stow &>/dev/null; then
    info "Installing stow..."
    sudo pacman -S --needed --noconfirm stow
  fi

  info "Symlinking dotfiles with stow..."

  cd "$DOTFILES_DIR"

  # Stow all subdirectories (each is a stow package)
  for pkg in */; do
    pkg="${pkg%/}"
    # Skip non-directories and hidden folders
    [[ -d "$pkg" ]] || continue
    [[ "$pkg" == .* ]] && continue

    info "  Stowing: $pkg"
    stow --target="$HOME" --restow "$pkg" 2>/dev/null || {
      warn "  Conflict detected in '$pkg' — backing up and retrying..."
      # Back up conflicting files then retry
      stow --target="$HOME" --restow --adopt "$pkg"
      git -C "$DOTFILES_DIR" checkout -- .  # restore repo files after adopt
      stow --target="$HOME" --restow "$pkg"
    }
  done

  success "Dotfiles symlinked"
}

# ── Configure Bash ────────────────────────────────────────────────────────────
setup_bash() {
  info "Configuring Bash..."

  # Ensure .bashrc exists (stow should have linked it, but just in case)
  if [[ ! -f "$HOME/.bashrc" ]]; then
    warn ".bashrc not found — your dotfiles repo may not have a bash/ stow package"
  fi

  # Set bash as a valid login shell if not already
  if ! grep -q "/bin/bash" /etc/shells; then
    echo "/bin/bash" | sudo tee -a /etc/shells
  fi

  success "Bash configured"
}

# ── Configure Fish ────────────────────────────────────────────────────────────
setup_fish() {
  info "Configuring Fish shell..."

  # Install fish if not present
  if ! command -v fish &>/dev/null; then
    info "  Installing fish..."
    yay -S --needed --noconfirm fish
  fi

  # Add fish to valid shells
  if ! grep -q "$(command -v fish)" /etc/shells; then
    command -v fish | sudo tee -a /etc/shells
  fi

  # Install fisher (fish plugin manager) if not present
  if ! fish -c "type fisher" &>/dev/null; then
    info "  Installing fisher (fish plugin manager)..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
  fi

  # If the machine profile sets fish as default shell, apply it
  if [[ "${SET_DEFAULT_SHELL:-}" == "fish" ]]; then
    local fish_path
    fish_path=$(command -v fish)
    if [[ "$SHELL" != "$fish_path" ]]; then
      info "  Setting fish as default shell..."
      chsh -s "$fish_path"
    fi
  fi

  success "Fish configured"
}

# ── Set default shell ─────────────────────────────────────────────────────────
set_default_shell() {
  local target_shell="${SET_DEFAULT_SHELL:-bash}"
  local shell_path
  shell_path=$(command -v "$target_shell" 2>/dev/null) || {
    warn "Shell '$target_shell' not found — keeping current shell"
    return
  }

  if [[ "$SHELL" == "$shell_path" ]]; then
    success "Default shell already set to $target_shell"
    return
  fi

  info "Setting default shell to $target_shell..."
  chsh -s "$shell_path"
  success "Default shell set to $target_shell (takes effect on next login)"
}

# ── SSH key setup ─────────────────────────────────────────────────────────────
setup_ssh() {
  local ssh_dir="$HOME/.ssh"
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  if [[ -f "$ssh_dir/id_ed25519" ]]; then
    success "SSH key already exists — skipping generation"
  else
    info "Generating SSH key..."
    read -rp "  Enter your email for the SSH key: " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$ssh_dir/id_ed25519" -N ""
    success "SSH key generated"
    echo ""
    warn "Add this public key to GitHub/GitLab:"
    echo -e "${BOLD}"
    cat "$ssh_dir/id_ed25519.pub"
    echo -e "${NC}"
    read -rp "  Press Enter once you've added the key..."
  fi

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)" &>/dev/null
  ssh-add "$ssh_dir/id_ed25519" 2>/dev/null || true
}

# ── Git config ────────────────────────────────────────────────────────────────
setup_git() {
  info "Configuring Git..."

  local current_name current_email
  current_name=$(git config --global user.name 2>/dev/null || echo "")
  current_email=$(git config --global user.email 2>/dev/null || echo "")

  if [[ -z "$current_name" ]]; then
    read -rp "  Git user name: " git_name
    git config --global user.name "$git_name"
  fi

  if [[ -z "$current_email" ]]; then
    read -rp "  Git user email: " git_email
    git config --global user.email "$git_email"
  fi

  # Sensible defaults
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  #git config --global core.editor "${GIT_EDITOR:-nvim}"

  success "Git configured"
}

# ── Dev tools ─────────────────────────────────────────────────────────────────
setup_dev_tools() {
  # nvm (Node Version Manager)
  if [[ "${INSTALL_NVM:-false}" == "true" ]]; then
    if [[ ! -d "$HOME/.nvm" ]]; then
      info "Installing nvm..."
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    else
      success "nvm already installed"
    fi
  fi

  # pyenv
  if [[ "${INSTALL_PYENV:-false}" == "true" ]]; then
    if ! command -v pyenv &>/dev/null; then
      info "Installing pyenv..."
      yay -S --needed --noconfirm pyenv
    else
      success "pyenv already installed"
    fi
  fi

  # rustup
  if [[ "${INSTALL_RUST:-false}" == "true" ]]; then
    if ! command -v rustup &>/dev/null; then
      info "Installing rustup..."
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
      success "rustup already installed"
    fi
  fi
}

# ── Machine-specific extras ───────────────────────────────────────────────────
run_machine_extras() {
  # Each machine config can define a machine_extras() function for
  # anything that doesn't fit the standard steps
  if declare -f machine_extras &>/dev/null; then
    info "Running machine-specific extras..."
    machine_extras
  fi
}

# ── Summary ───────────────────────────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${GREEN}${BOLD}═══════════════════════════════════════${NC}"
  echo -e "${GREEN}${BOLD}  Rebuild complete! ✓${NC}"
  echo -e "${GREEN}${BOLD}═══════════════════════════════════════${NC}"
  echo ""
  echo -e "  Machine profile : ${BOLD}${MACHINE}${NC}"
  echo -e "  Dotfiles        : ${BOLD}${DOTFILES_DIR}${NC}"
  echo -e "  Default shell   : ${BOLD}${SET_DEFAULT_SHELL:-bash}${NC}"
  echo ""
  echo -e "  ${YELLOW}Reboot or log out/in to apply all changes.${NC}"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  banner

  # Prompt user to choose machine profile
  MACHINE=$(choose_machine)
  load_machine_config "$MACHINE"

  echo ""
  info "Starting rebuild for: ${BOLD}${MACHINE}${NC}"
  echo ""

  system_update
  install_yay
  install_packages "$MACHINE"
  setup_git
  #setup_ssh
  clone_dotfiles
  stow_dotfiles
  setup_bash
  setup_fish
  set_default_shell
  #setup_dev_tools
  run_machine_extras

  print_summary
}

main
