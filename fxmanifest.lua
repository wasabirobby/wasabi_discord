fx_version 'cerulean'

game 'gta5'

description 'Wasabi Extended Discord Wrapper'

lua54 'yes'

version '1.0.0'

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
