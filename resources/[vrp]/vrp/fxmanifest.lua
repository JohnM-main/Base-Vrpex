
client_script "lib/lib.lua"
 fx_version 'adamant'
game 'gta5'

ui_page "web-side/index.html"
server_scripts {
	"lib/utils.lua",
	"base.lua",
	"server-side/*"
}
client_scripts {
	"lib/utils.lua",
	"client-side/*"
}
files {
	"**/**/*",
	"**/*",
	"*"
}

loadscreen "loading/darkside.html"
server_export "AddPriority"
server_export "RemovePriority"
              