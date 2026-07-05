function awww_next --description "Force change to a random wallpaper instantly"
    set WALLPAPER_DIR "$HOME/Pictures/Wallpapers"
    set TRANSITION_TYPE "simple" 
    set TRANSITION_FPS 60
    set TRANSITION_STEP 2
    
    # Select a random wallpaper image file
    set SELECTED_WALLPAPER (find $WALLPAPER_DIR -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
    
    if test -n "$SELECTED_WALLPAPER"
        awww img $SELECTED_WALLPAPER \
            --transition-type $TRANSITION_TYPE \
            --transition-fps $TRANSITION_FPS \
            --transition-step $TRANSITION_STEP
    end
end
