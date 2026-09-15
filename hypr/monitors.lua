hl.monitor({ output = "", mode = "1920x1080", position = "auto", scale = 1 })

-- eDP-1 (laptop screen)
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1280@60",--"2256x1504@60",
    position = "0x0",
    --mirror = "DP-3",
    --bitdepth = 8,
   	--disabled = true,
    scale    = 1,
})

hl.monitor({
    output   = "desc:Acer Technologies X32 V2 1538000E83900",
    mode     = "3840x2160@120.00Hz",
    --mode     = "1920x1080@144.00Hz",
	vrr = 1,
    position = "-960x-2160",--"-792x-2160",
    --bitdepth = 8,
    --disabled = true,
    scale    = 1,
})
