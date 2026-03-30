fx_version 'bodacious'
game 'gta5'

ui_page 'nui/index.html'
client_scripts {
	'@vrp/lib/utils.lua',
	"config/config_client.lua",
	'client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	"config/config_server.lua",
	'server.lua'
}

files {
	'nui/**/*',
	'nui/*',
}
              