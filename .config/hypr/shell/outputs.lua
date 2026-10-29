hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@143.999", position = "4608x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "2560x1440@165.003", position = "7168x288", scale = 1.25, vrr = 0 })
hl.monitor({ output = "DP-1", mode = "2560x1440@180.002", position = "4608x0", scale = 1, vrr = 0, bitdepth = 10 })

-- The AOC always holds workspace 1, whichever port it is on. `desc:` matches the start of the
-- monitor's description, so the model name is enough without its serial number.
hl.workspace_rule({ workspace = "1", monitor = "desc:AOC Q27G3XMN", persistent = true, default = true })
