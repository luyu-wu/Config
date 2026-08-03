hl.monitor({ output = "", mode = "1920x1080", position = "auto", scale = 1 })

-- eDP-1 (laptop screen)
hl.monitor({
    output   = "eDP-1",
    mode     = "2256x1504@60",
    position = "0x0",
    --bitdepth = 8,
   	--disabled = true,
    scale    = 1,
})

hl.monitor({
    output   = "DP-3",
    mode     = "3840x2160@120.00Hz",
    position = "0x0",--"-792x-2160",
    --bitdepth = 8,
    --disabled = true,
    scale    = 1,
})
