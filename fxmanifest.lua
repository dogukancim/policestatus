fx_version 'cerulean'
game 'gta5'

description 'Police Status Script'
author 'dogukancim'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

exports {
    'OpenMenu',
    'StatusCount',
    'StatusNames'
}
