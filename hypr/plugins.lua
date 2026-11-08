local darkMode = _G.darkMode
bar_bg_breeze = "rgb(dee0e2)"
tc_breeze = "rgb(404040)"
ia_icon_color = "rgb(c4c4c4)"
if darkMode then
	bar_bg_breeze = "rgb(292c31)"
	tc_breeze = "rgb(e0e0e0)"
	ia_icon_color = "rgb(5d5d5d)"
end

hl.config({
    plugin = {
        hyprbars = {
            bar_height                 = 32,
            bar_part_of_window         = true,
            bar_buttons_alignment      = "left",
            bar_button_padding         = 10,
            bar_blur                   = false,
            bar_padding                = 12	,
            bar_text_font              = "SF Pro",
            --bar_text_weight			   = 800,
            bar_text_size			   = 14,
            bar_precedence_over_border = true,

            -- Light Mode
            bar_color                  = bar_bg_breeze,

            col                        = {
                -- Light Mode
                text = tc_breeze
            },

            icon_on_hover              = true,
			-- Light Mode #e4e4e4
            inactive_button_color      = ia_icon_color,
            on_double_click            = "hyprctl dispatch 'hl.dsp.window.fullscreen_state({internal = 1, client = 0})'"
        },
    },
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(fe5154)",
    fg_color = "rgb(000000)",
    size = 16,
    icon = "󰖭",
    action = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(f7c000)",
    fg_color = "rgb(000000)",
    size = 16,
    icon = "",
    action = "hyprctl dispatch 'hl.dsp.window.float()'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(2dbf4d)",
    fg_color = "rgb(000000)",
    size = 16,
    icon = "󰘖",
    action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
 })
