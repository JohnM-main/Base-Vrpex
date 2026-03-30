local cfg = {}

cfg.static_menu_types = {
    ["policia_equipamentos"] = {
        title = "Equipamentos",
        permissions = {"perm.policia"}
    },

    ["policia_equipamentosstic"] = {
        title = "Equipamentos",
        permissions = {"perm.stic"}
    },


    ["unizk_equipamentos"] = {
        title = "Hospital",
        permissions = {"perm.unizk"}
    },

    ["bennys_equipamentos"] = {
        title = "Mecanico",
        permissions = {"perm.bennys"}
    },

    ["sportrace_equipamentos"] = {
        title = "Mecanico",
        permissions = {"perm.sportrace"}
    }
}

cfg.static_menus = {
    {"unizk_equipamentos", -432.31,-318.69,34.92},
    {"policia_equipamentos", 482.7,-995.2,30.69},
    {"policia_equipamentosstic", 624.01,-21.44,82.77},
    {"bennys_equipamentos", -206.27,-1342.88,34.91}, 
    {"sportrace_equipamentos", 842.44,-968.48,26.5},
    
}

return cfg
