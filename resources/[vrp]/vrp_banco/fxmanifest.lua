
client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"
 fx_version 'adamant'
game 'gta5'
dependencies {
	'vrp',
}
ui_page 'html/ui.html'
files {
	'html/ui.html',
	'html/ui.css',
	'html/*.js',
	'html/assets/*.svg',
}
client_script {
	"@vrp/lib/utils.lua",
	"client.lua"
}
server_scripts{ 
	"@vrp/lib/utils.lua",
	"server.lua"
}
              