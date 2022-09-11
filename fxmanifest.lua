fx_version 'cerulean'

game 'gta5'

description 'Wasabi Discord API'

lua54 'yes'

version '0.0.1'

client_scripts {
  'client/*.lua'
}

server_scripts {
  'config.lua',
  'server/*.lua'
}

shared_script '@ox_lib/init.lua'

dependencies {
  'ox_lib'
}