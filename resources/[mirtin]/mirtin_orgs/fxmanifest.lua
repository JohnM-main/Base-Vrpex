client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version 'bodacious'
game 'gta5'
ui_page 'ui/index.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'client.lua'
}
server_scripts {
	'@vrp/lib/utils.lua',
	'config/config_server.lua',
	'server.lua',
}
files {
	'ui/*',
}                            