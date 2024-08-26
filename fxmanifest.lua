name "Race"
author "Gaïus Mancini"
description "Generic Race Script By Gaïus Mancini"
fx_version "cerulean"
game "gta5"
dependencies {
	'qb-menu',
    'qb-target',
}
shared_script 'config.lua'
client_script 'client/*.lua'
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
lua54 'yes'