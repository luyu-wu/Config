hl.config({
    general = {
        gaps_in          = 12,
        gaps_out         = 16,
        gaps_workspaces  = 0,
        border_size      = 1,
        col              = {
            active_border   = "rgb(90a0b0)",
            inactive_border = "rgb(a0b0c0)",
        },
        resize_on_border = true,
    },

    layout = {
        single_window_aspect_ratio = { 4, 3 },
    },

    dwindle = {
        preserve_split = true,
    },

    scrolling = {
        column_width = 0.4,
    },

    input = {
        touchpad       = {
            scroll_factor        = 0.2,
            clickfinger_behavior = true,
            disable_while_typing = false,
            tap_and_drag         = true,
            natural_scroll       = true,
            drag_lock            = false,
        },
        sensitivity    = 0.4,
        accel_profile  = "flat",
        repeat_rate    = 50,
        force_no_accel = true,
        repeat_delay   = 200,
        -- follow_mouse  = 2,
    },

    cursor = {
        enable_hyprcursor = true,
        inactive_timeout  = 0,
        zoom_factor       = 1,
        use_cpu_buffer    = false,
        no_warps          = true,
    },

    gestures = {
        workspace_swipe_distance       = 700,
        workspace_swipe_cancel_ratio   = 0.1,
        workspace_swipe_direction_lock = false,
    },

    binds = {
        scroll_event_delay               = 0,
        hide_special_on_workspace_change = true,
    },

    misc = {
        disable_autoreload         = false,
        allow_session_lock_restore = true,
        focus_on_activate          = true,
        animate_manual_resizes     = false,
        vrr                        = 1,
        initial_workspace_tracking = 0,
        middle_click_paste         = false,
        font_family                = "SF Pro",
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        force_default_wallpaper    = 0,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    xwayland = {
        enabled              = true,
        force_zero_scaling   = true,
        use_nearest_neighbor = true,
    },

    decoration = {
        rounding     = 8,

        shadow       = {
            enabled        = true,
            range          = 24,
            render_power   = 4,
            color          = "rgba(00000040)",
            color_inactive = "rgba(00000025)",
        },

        dim_inactive = false,
        dim_strength = 0,
        dim_special  = 0.3,
        dim_around   = 0.6,


        blur = {
            enabled        = true,
            special        = false,
            popups         = false,
            input_methods  = false,
            xray           = true,
            ignore_opacity = false,
            size           = 6,
            passes         = 3,
            contrast       = 1,
            brightness     = 1,
            vibrancy       = 0,
            noise          = 0.02,
        },
    },

    render = {
        new_render_scheduling = true,
    },

    debug = {
        error_position = 1,
        overlay = false,
        damage_blink=false
    }
})
