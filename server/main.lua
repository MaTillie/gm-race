local QBCore = exports['qb-core']:GetCoreObject()

function Start(id,numRace,precision,repair,route,raceData)	
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:start', v.PlayerData.source,id,numRace,precision,repair,route,raceData)
    end
end

function Prepare(id)	
    local result = MySQL.query.await('SELECT id, label,checkpoint FROM gm_race_races where id=?',{id})
    if result then
        for i = 1, #result,1 do 
            local raceData = json.decode(result[1].checkpoint)
            local label = result[1].label
            local coord = vec3 (0,0,0)
            for i, checkpoint in ipairs(raceData) do
                coord = checkpoint
                break
            end
        
            local players = QBCore.Functions.GetQBPlayers()
            for _, v in pairs(players) do
                TriggerClientEvent('gm_race:client:prepare', v.PlayerData.source,id,label,coord)
            end
        end
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
    local raceData = {}
    local label = ""
    local precision = 25
    local repair = false
    local route = true
    local track = {}

    local result = MySQL.query.await('SELECT label,`precision`,repair,checkpoint FROM gm_race_races where id=? ',{id})
    if result then
        for i = 1, #result,1 do 
            local json = require("json") 
            raceData = json.decode(result[1].checkpoint)
            label = result[i].label
            precision = result[i].precision
            repair = result[i].repair == 1
            route = result[i].route == 1
        end
    end
    

    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    local result1 = MySQL.query.await('SELECT MAX(numRace) as max FROM rankingace WHERE race=?', { id })
    local numRace = 0
    if result1 then
        for i = 1, #result1,1 do 
            if result1[i].max then
                numRace = result1[i].max + 1
            end
        end
    end
    
	Start(id,numRace,precision,repair,route,raceData)
end)

QBCore.Commands.Add('gmpreparerace', "Lance les préparatifs de la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local id = tonumber(args[1])
	Prepare(id)
end)


QBCore.Commands.Add('gmclassement', "Classement de la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local src = source
    local id = tonumber(args[1])
    print("id ".. id)
    local r = MySQL.query.await('SELECT MAX(numRace) as max FROM rankingace WHERE race=?', { id })
    local numRace = 0
    if r then
        for i = 1, #r,1 do 
            if r[i].max then
                numRace = r[i].max 
            end
        end
    end
    print("max ".. numRace)
    local result = MySQL.query.await('SELECT player, min, sec, ms FROM rankingace WHERE race=? and numRace=? order by ms desc', { id,numRace })
    
    
    for i = 1, #result,1 do        
        local dt = "["..#result-i+1 .."]".. result[i].player.."  en: "..result[i].min..":"..result[i].sec.." ("..result[i].ms..")"
        TriggerClientEvent('gm_race:client:classement', src,dt)      
        Wait(500)  
    end  
end)

QBCore.Commands.Add('gmclassementgeneral', "Classement de la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local src = source
    local id = tonumber(args[1])

    local result = MySQL.query.await('SELECT player, min, sec, ms FROM rankingace WHERE race=? order by ms desc', { id })
    for i = 1, #result,1 do        
        local dt = "["..#result-i+1 .."]".. result[i].player.."  en: "..result[i].min..":"..result[i].sec.." ("..result[i].ms..")"        
        TriggerClientEvent('gm_race:client:classement', src,dt)
        Wait(500)
    end     
end)


QBCore.Commands.Add('gmraces', "Liste des courses", {}, true, function(source, args)	
	local src = source
    local id = tonumber(args[1])

    local result = MySQL.query.await('SELECT id, label FROM gm_race_races order by id',{})
    for i = 1, #result,1 do        
        local dt = "["..result[i].id.."] : "..result[i].label
        
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
AddEventHandler('gm_race:server:msg', function(raceId,numRace,playerName,min,sec,t3)	
    local msg = playerName.." a fini la course en "..min..":"..sec.." "..t3
    local query = 'INSERT INTO `rankingace` (`race`,`numRace`, `player`, `min`, `sec`, `ms`) VALUES (:race, :numRace, :player, :min, :sec, :ms);'
				local data = {
                    ['@race'] = tonumber(raceId),
                    ['@numRace'] = tonumber(numRace),
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

QBCore.Commands.Add('gmenderace', "Termine la course", {{name = 'id', help = 'Numéro de course'}}, true, function(source, args)	
	local id = tonumber(args[1])
	local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        TriggerClientEvent('gm_race:client:endrace', v.PlayerData.source,id)
    end
end)


QBCore.Commands.Add('gmcreaterace', "creation d'une course", {{name = 'nom', help = 'Nom de la course'},{name = 'precision', help = 'Distance de validation des checkpoints'}}, true, function(source, args)	
	local src = source
    local precision = tonumber(args[2])
    local flg = true

    if (precision<1 or precision>200) then
        TriggerClientEvent('gm_race:client:msg', src,"precision invalide")        
        flg = false
    end

    if(#args[1]==0)then
        TriggerClientEvent('gm_race:client:msg', src,"Renseigner le nom")   
        flg = false 
    end

    if(#args[1]>250)then
        TriggerClientEvent('gm_race:client:msg', src,"Nom trop long")   
        flg = false 
    end

    if flg then
        local newRace = {}
        newRace.precision = precision
        newRace.nom = args[1]        
        TriggerClientEvent('gm_race:client:newRace', src,args[1],precision)
    end

    local result = MySQL.query.await('SELECT player, min, sec, ms FROM rankingace WHERE race = ? order by ms desc', { id })
    for i = 1, #result,1 do        
        local dt = result[i].player.."  en: "..result[i].min..":"..result[i].sec.." ("..result[i].ms..")"
        
        TriggerClientEvent('gm_race:client:classement', src,dt)
    end     
end)

QBCore.Commands.Add('gmadd', "Ajoute un checkpoint à la course", {}, true, function(source, args)	
    local player = source
    local ped = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(ped)
        
    TriggerClientEvent('gm_race:client:addCheckpoint', player,playerCoords)   
end)

QBCore.Commands.Add('gmsaverace', "Sauvegarde la course en cours de création", {}, true, function(source, args)	
    local src = source
    TriggerClientEvent('gm_race:client:saveRace', src, "")  
    
end)

RegisterNetEvent('gm_race:server:saveRace')
AddEventHandler('gm_race:server:saveRace', function(newRace)	
    local src = source 
    local json = require("json") 
    local raceJson = json.encode(newRace.checkpoint)

	local query = 'INSERT INTO `gm_race_races` (`precision`, `label`, `checkpoint`) VALUES (:precision, :label,:checkpoint);'
    local data = {
        ['@precision'] = newRace.precision,
        ['@label'] = newRace.label,
        ['@checkpoint'] = raceJson,
    }
    exports['oxmysql']:execute(query, data)		
    
    local dt = "Course "..newRace.label.." sauvegardée"
    TriggerClientEvent('gm_race:client:msg', src,dt)  
end)	
