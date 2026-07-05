function update --wraps='sudo pacman -Syu'
    if command -q yay
        yay -Syu
    else
        sudo pacman -Syu
    end
end
