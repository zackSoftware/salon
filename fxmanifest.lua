fx_version 'cerulean'
games { 'rdr3', 'gta5' }

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
	'config.lua'
}

client_scripts {
    'client/*',
	'framework/client.lua',
    'scripts/client.lua',
}

server_script	'@oxmysql/lib/MySQL.lua'

server_scripts {
    'server/*',
	'framework/server.lua',
    'scripts/server.lua',
}

ui_page 'interface/dist/index.html'

files {
    'interface/dist/index.html',
    'interface/dist/assets/*'
}

escrow_ignore {
  'config.lua'
}