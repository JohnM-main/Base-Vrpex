cfg = {}

cfg.geral = {
    tempoMin = 10
}

cfg.types = {
    ["Consertar"] = {
        anim = "WORLD_HUMAN_WELDING",
        dict = nil,
        prop = nil,
        reduzir = 1,
    },

    ["Varrer"] = {
        anim = "amb@world_human_janitor@male@idle_a",
        dict = "idle_a",
        prop = { "prop_tool_broom", 49, 28422 },
        reduzir = 1,
    },
}

cfg.locations = {
    [1] = { type = "Consertar", coords = vec3(1664.76,2501.32,45.57), heading = 2.44, minBlip = 0.0},
    [2] = { type = "Consertar", coords = vec3(1622.97,2507.82,45.57), heading = 101.15, minBlip = 0.0},
    [3] = { type = "Consertar", coords = vec3(1706.32,2481.38,45.57), heading = 223.69, minBlip = 0.0},
    [4] = { type = "Consertar", coords = vec3(1699.78,2474.98,45.57), heading = 227.57, minBlip = 0.0},
    [5] = { type = "Consertar", coords = vec3(1679.88,2480.59,45.57), heading = 133.06, minBlip = 0.0},
    [6] = { type = "Consertar", coords = vec3(1643.79,2491.07,45.57), heading = 192.73, minBlip = 0.0},
    [7] = { type = "Consertar", coords = vec3(1610.12,2539.85,45.57), heading = 131.28, minBlip = 0.0},
    [8] = { type = "Consertar", coords = vec3(1609.3,2566.87,45.57), heading = 49.95, minBlip = 0.0},
    [9] = { type = "Consertar", coords = vec3(1623.94,2577.3,45.57), heading = 266.28, minBlip = 0.0},
    [10] = { type = "Consertar", coords = vec3(1630.0,2563.93,45.57), heading = 1.59, minBlip = 0.0},
    [11] = { type = "Consertar", coords = vec3(1652.58,2563.86,45.57), heading = 0.35, minBlip = 0.0},
    [12] = { type = "Consertar", coords = vec3(1760.09,2519.11,45.57), heading = 258.51, minBlip = 0.0},
    [13] = { type = "Consertar", coords = vec3(1737.34,2505.04,45.57), heading = 163.18, minBlip = 0.0},

    
    [100] = { type = "Varrer", coords = vec3(1692.41,2517.85,45.57), heading = 104.55, minBlip = 0.7},
    [101] = { type = "Varrer", coords = vec3(1677.82,2497.18,45.57), heading = 2.24, minBlip = 0.7},
    [102] = { type = "Varrer", coords = vec3(1665.16,2508.15,45.57), heading = 296.11, minBlip = 0.7},
    [103] = { type = "Varrer", coords = vec3(1682.06,2528.18,45.57), heading = 316.99, minBlip = 0.7},
} 