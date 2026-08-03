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
            --bar_color                  = "rgb(dee0e2)",
            -- Dark Mode
            bar_color                  = "rgb(292c31)",

            col                        = {
                -- Light Mode
                --text = "rgb(606060)",
                -- Dark Mode
                text = "rgb(e0e0e0)",
            },

            icon_on_hover              = true,
            inactive_button_color      = "rgb(c5c5c5)",
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
    action = "hyprctl dispatch 'hl.dsp.window.fullscreen_state({internal = 1, client = 0})'"
})
