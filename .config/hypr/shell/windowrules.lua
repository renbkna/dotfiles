-- Window rules

-- Equibop on the communication special workspace
hl.window_rule({ match = { class = "^equibop$" }, workspace = "special:communication" })

-- Anki floats
hl.window_rule({ match = { class = "^anki$" }, float = true })
hl.window_rule({ match = { class = "^btop-float$" }, float = true })
