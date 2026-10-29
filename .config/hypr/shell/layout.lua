-- Layout and layer rules

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 4,
		border_size = 1,
		resize_on_border = false,
	},
	decoration = {
		rounding = 16,
		blur = {
			passes = 2,
		},
	},
})

-- Noctalia animates its own surfaces
hl.layer_rule({ match = { namespace = "^noctalia-.*" }, no_anim = true })

-- Glass: blur behind Noctalia's translucent surfaces. ignore_alpha keeps fully transparent
-- regions (the bar strip between capsules, text-only desktop widgets) unblurred.
hl.layer_rule({
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher|.*panel)$",
	},
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
hl.layer_rule({
	match = { namespace = "^noctalia-desktop-widget-(sticker|label|media_player)-.+$" },
	ignore_alpha = 0.5,
	blur = true,
})

-- The bar and desktop widgets only ever sit over the wallpaper
hl.layer_rule({ match = { namespace = "^noctalia-(bar-.+|desktop-widget-.+)$" }, xray = true })
