function awww_cycle --description "Cycle wallpapers using awww"
    set WALLPAPER_DIR "$HOME/Pictures/Wallpapers"
    set TRANSITION_TYPE "simple" 
    set TRANSITION_FPS 60
    set TRANSITION_STEP 10

    mkdir -p $WALLPAPER_DIR
    
    # Give Hyprland and awww-daemon 2 seconds to initialize fully on boot
    #sleep 2

    while true
        if pgrep -x "awww-daemon" > /dev/null
            set SELECTED_WALLPAPER (find $WALLPAPER_DIR -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

            if test -n "$SELECTED_WALLPAPER"
                awww img $SELECTED_WALLPAPER \
                    --transition-type $TRANSITION_TYPE \
                    --transition-fps $TRANSITION_FPS \
                    --transition-step $TRANSITION_STEP
            end
        end
        #sleep 15m
    end
end

