function cd --description 'Built-in cd wrapper that automatically runs ls'
    builtin cd $argv; and ls
end

