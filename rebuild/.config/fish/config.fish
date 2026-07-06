source /usr/share/cachyos-fish-config/cachyos-config.fish

# ── Exports  ────────────────────────────────────────────────────────────────────
export LD_PRELOAD="/usr/lib/libextest.so"
export VISUAL="nvim"

# ── Searching Packages  ────────────────────────────────────────────────────────────────────
# Search for packages using the best available tool:
# pacseek (TUI) → yay (AUR + official) → pacman (official only)
function search
    if command -q pacseek
        pacseek $argv
    else if command -q yay
        yay --sortby votes $argv
    else
        pacman -Ss $argv
    end
end

# ── Installing  Packages  ────────────────────────────────────────────────────────────────────
# Install packages using the best available tool:
# yay (AUR + official) → pacman (official only)
function install
    if command -q yay
        yay -S $argv
    else
        sudo pacman -S $argv
    end
end

# ── Updating/Upgrading System  ────────────────────────────────────────────────────────────────────
# Update + upgrade all packages using the best available tool:
# yay (AUR + official) → pacman (official only)
function update
    if command -q yay
        yay -Syu
    else
        sudo pacman -Syu
    end
end

funcsave update
alias upgrade=update

# ── venv ───────────────────────────────────────────────────────────────────────────────
alias venv="source ./.venv/bin/activate.fish"

# ── Neovim ───────────────────────────────────────────────────────────────────────────────
alias envim="nvim ~/.config/nvim/"   # edit

# ── Fish Config ───────────────────────────────────────────────────────────────────────────────
# Locally
alias efish="nvim ~/.config/fish/config.fish"   # edit
alias sfish="source ~/.config/fish/config.fish" # source/reload
alias vfish="bat ~/.config/fish/config.fish"    # view (read-only)

# Globally
alias egfish="nvim /usr/share/cachyos-fish-config/cachyos-config.fish"   # edit
alias sgfish="source /usr/share/cachyos-fish-config/cachyos-config.fish" # source/reload
alias vgfish="bat /usr/share/cachyos-fish-config/cachyos-config.fish"    # view (read-only)

# ── DotFiles26 ───────────────────────────────────────────────────────────────────────────────
# Locally
alias vdot="yazi ~/Documents/dotfiles26/"   # edit
alias dot="cd ~/Documents/dotfiles26/ && ls"   # edit

# ── Rules ───────────────────────────────────────────────────────────────────────────────
function mkrule
    sudoedit /etc/udev/rules.d/$argv[1].rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
end

alias rules="sudo udevadm control --reload-rules && sudo udevadm trigger"

# ── Hypr ───────────────────────────────────────────────────────────────────────────────
alias ehypr="nvim ~/.config/hypr"   # edit
alias ehyprm="nvim ~/.config/hypr/modules"   # edit
alias ehyprk="nvim ~/.config/hypr/modules/keybinds.lua"   # edit

# ── Ferris Sweep ───────────────────────────────────────────────────────────────────────────────
alias esweep='nvim ~/qmk_firmware/keyboards/ferris/keymaps/suditMiryoku/keymap.c'
alias sweepcompile='qmk compile -kb ferris/0_2/base -km suditMiryoku'
alias sweepflash='dfu-util -d 0483:df11 -a 0 -s 0x08000000:leave -D ~/qmk_firmware/ferris_0_2_base_suditMiryoku.bin'
alias sweepfull='sweepcompile && sweepflash'

# ── iRacing Lab ───────────────────────────────────────────────────────────────────────────────
alias iracing='cd ~/Documents/iracing-lab && venv'

# ── Copy Config Files ───────────────────────────────────────────────────────────────────────────────
alias copyhypr='cp -r ~/.config/hypr/ ~/Documents/dotfiles26/rebuild/.config/'
alias copynvim='cp -r ~/.config/nvim/ ~/Documents/dotfiles26/rebuild/.config/'
alias copyfish='cp -r ~/.config/fish/ ~/Documents/dotfiles26/rebuild/.config/'
alias copyyazi='cp -r ~/.config/yazi/ ~/Documents/dotfiles26/rebuild/.config/'

# ── Yazi ───────────────────────────────────────────────────────────────────────────────
alias y.='yazi .'
alias y='yazi'

