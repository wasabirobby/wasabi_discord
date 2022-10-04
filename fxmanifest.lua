fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Wasabi Extended Discord Wrapper'
version '1.0.3'

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
