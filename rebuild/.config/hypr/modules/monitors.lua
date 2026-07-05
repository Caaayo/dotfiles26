------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "1.33",
})

hl.workspace_rule({workspace = "1", persistent = true})
hl.workspace_rule({workspace = "2", persistent = true})
hl.workspace_rule({workspace = "3", persistent = true})
hl.workspace_rule({workspace = "4", persistent = true})
hl.workspace_rule({workspace = "5", persistent = true})
hl.workspace_rule({workspace = "6", persistent = true})
hl.workspace_rule({workspace = "7", persistent = true})
hl.workspace_rule({workspace = "8", persistent = true})
hl.workspace_rule({workspace = "9", persistent = true})
hl.workspace_rule({workspace = "10", persistent = true})
