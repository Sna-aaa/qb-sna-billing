fx_version 'adamant'

game 'gta5'

author 'Sna'

description 'Billing script for QBCore'

shared_scripts {
	'config.lua',
    '@qb-core/shared/locale.lua',
	'locales/*.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}