--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({ workspace = "1", match = { class = "(?i)firefox"}})
hl.window_rule({ workspace = "8", match = { class = "(?i)discord"}})
hl.window_rule({ workspace = "9", match = { class = "(?i)steam"}})
hl.window_rule({ workspace = "9", match = { class = "(?i)azeron.*"}})
hl.window_rule({ workspace = "10", match = { class = "(?i)steam_app_.*"}})
hl.window_rule({ workspace = "10", match = { class = "(?i).*xiv.*" } })

