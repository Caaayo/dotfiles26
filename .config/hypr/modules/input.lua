---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,us",
        kb_variant = ",dvorak",
        kb_model   = "",
        kb_options = "grp:alt_space_toggle", -- ALT+SPACE to toggle
        kb_rules   = "",

        resolve_binds_by_sym = true,
        repeat_rate = 30,
        repeat_delay = 300,

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
            scroll_factor = 0.2
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

