-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Wasabi Extended Discord Wrapper'
version '1.0.5'

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
