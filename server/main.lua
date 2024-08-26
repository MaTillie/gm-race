local QBCore = exports['qb-core']:GetCoreObject()

function Start(id)	
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:start', v.PlayerData.source,id)
    end
end

function Prepare(id)	
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:prepare', v.PlayerData.source,id)
    end
end

function Reset(id)	
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:endrace', v.PlayerData.source,id)
    end
end

QBCore.Commands.Add('gmstartrace', "Lance la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)
	local id = tonumber(args[1])
	Start(id)
end)

QBCore.Commands.Add('gmpreparerace', "Lance les préparatifs de la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local id = tonumber(args[1])
	Prepare(id)
end)


QBCore.Commands.Add('gmclassement', "Classement de la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local src = source
    local id = tonumber(args[1])
    local result = MySQL.query.await('SELECT player, min, sec, ms FROM rankingace WHERE race = ? order by ms desc', { id })
    for i = 1, #result,1 do        
        local dt = result[i].player.."  en: "..result[i].min..":"..result[i].sec.." "..result[i].ms
        
        TriggerClientEvent('gm_race:client:classement', src,dt)
    end     
end)

local function PrintTable(t, indent)
    indent = indent or 0
    local prefix = string.rep(" ", indent)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(prefix .. tostring(k) .. ":")
                PrintTable(v, indent + 2)
            else
                print(prefix .. tostring(k) .. ": " .. tostring(v))
            end
        end
    else
        print(prefix .. tostring(t))
    end
end

RegisterNetEvent('gm_race:server:msg')
AddEventHandler('gm_race:server:msg', function(raceId,playerName,min,sec,t3)	
    local msg = playerName.." a fini la course en "..min..":"..sec.." "..t3
    print(msg)
    local query = 'INSERT INTO `rankingace` (`race`, `player`, `min`, `sec`, `ms`) VALUES (:race, :player, :min, :sec, :ms);'
				local data = {
                    ['@race'] = tonumber(raceId),
					['@player'] = playerName,
					['@min'] = tonumber(min),
                    ['@sec'] = tonumber(sec),
                    ['@ms'] = tonumber(t3),
				}
				exports['oxmysql']:execute(query, data)		

    
	local players = QBCore.Functions.GetQBPlayers()
    
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:msg', v.PlayerData.source,msg)
    end
end)	

RegisterNetEvent('gm_race:server:endrace')
AddEventHandler('gm_race:server:endrace', function(id)	
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:endrace', v.PlayerData.source,id)
    end
end)	