local QBCore = exports['qb-core']:GetCoreObject()
local RaceId = 0
local NumItRace = 0
local Go = false
local NewRaceL = {}
local CreateMod = false
local Fin = false
local CurrentRace = {}
local BlipsCreation = {}

local function PrintTable(t, indent)
    indent = indent or 0
    local prefix = string.rep(" ", indent)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(prefix .. tostring(k) .. ":")
                exports.qbx_core:Notify(prefix .. tostring(k) .. ":")
                PrintTable(v, indent + 2)
            else
                print(prefix .. tostring(k) .. ": " .. tostring(v))
                exports.qbx_core:Notify(prefix .. tostring(k) .. ": " .. tostring(v))
            end
        end
    else
        print(prefix .. tostring(t))
        exports.qbx_core:Notify(prefix .. tostring(t))
    end
end

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


local function Race(id)
    local depart
    for i, checkpoint in ipairs(CurrentRace.checkpoint) do
        depart = checkpoint
        break
    end    
    exports.qbx_core:Notify("Préparez vous, nombre de tour(s) : "..CurrentRace.tour,"inform",5000,"",'center-right')
    Wait(5000)
    local cpt = 3

    while cpt>0 do
        exports.qbx_core:Notify(cpt,"inform",1000,"",'center-right')
        Wait(1000)
        cpt = cpt-1
    end

    exports.qbx_core:Notify("Go !", "inform",1000,"",'center-right')

    local t1 = GetGameTimer() 
    local tTour 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped,true)

    print(CurrentRace.checkpoint)
    for tr=1 , CurrentRace.tour , 1 do
        tTour =GetGameTimer()  
        for i, checkpoint in ipairs(CurrentRace.checkpoint) do
            local Blip = AddBlipForCoord(checkpoint.x, checkpoint.y, checkpoint.z)    
            SetBlipColour(Blip, 3)

            if CurrentRace.route then
                SetBlipRoute(Blip, true)
                SetBlipRouteColour(Blip, 3)           
            end

            local Blip2
            if ((i+1) < #CurrentRace.checkpoint) then
                Blip2 = AddBlipForCoord(CurrentRace.checkpoint[i+1].x, CurrentRace.checkpoint[i+1].y, CurrentRace.checkpoint[i+1].z)  
            end

            while Go do
                local pos = GetEntityCoords(ped)
                local dist = #(pos - vector3(checkpoint.x,checkpoint.y,checkpoint.z))               
                if dist < CurrentRace.precision then
                    RemoveBlip(Blip)     

                    if CurrentRace.repair then           
                        SetVehicleFixed(veh)
                    end
                    
                    if ((i+1) < #CurrentRace.checkpoint) then
                        RemoveBlip(Blip2)
                    end
                    break
                end
                Wait(100)
            end
        end

        if(Go) then
            local t2 = GetGameTimer() 
            local t3 = t2-tTour
            local t = math.floor(t3/1000)    
            local min = math.floor(t/60)
            local sec = t -min*60;
            t3 = t3-t
            local playerName = QBCore.Functions.GetPlayerData().charinfo.firstname .. " " .. QBCore.Functions.GetPlayerData().charinfo.lastname
            local msg = playerName.." a fini le tour en "..min..":"..sec.." "..t3
            exports.qbx_core:Notify(msg, "success",5000,"",'center-right')
            --..("%02d:%02d"):format(t3.min, t3.sec)
            TriggerServerEvent('gm_race:server:savetour',RaceId, NumItRace,playerName,min,sec,t3,tr) 
        end
    end
    if(Go) then
        local t2 = GetGameTimer() 
        local t3 = t2-t1
        local t = math.floor(t3/1000)    
        local min = math.floor(t/60)
        local sec = t -min*60;
        t3 = t3-t
        local playerName = QBCore.Functions.GetPlayerData().charinfo.firstname .. " " .. QBCore.Functions.GetPlayerData().charinfo.lastname
        local msg = playerName.." a fini la course en "..min..":"..sec.." "..t3
        Wait(1000)
        exports.qbx_core:Notify(msg, "success",20000,"",'center-right')
        --..("%02d:%02d"):format(t3.min, t3.sec)
        TriggerServerEvent('gm_race:server:msg',RaceId, NumItRace,playerName,min,sec,t3)
    else
        exports.qbx_core:Notify("Course intérrompue", "error",10000,"",'center-right')
    end
end


local function WaitStartRace(id)
    local numCourse = tonumber(id)   
    while true do
        if (RaceId == numCourse) then
            break
        end
        Wait(1)
    end
    Race(numCourse)
end

RegisterCommand('ptrace', function(source, args)
    local i = tonumber(args[1])
        for j = 1, #Config.race[i].checkpoint,1 do
            local Blip = AddBlipForCoord(Config.race[i].checkpoint[j].x, Config.race[i].checkpoint[j].y, Config.race[i].checkpoint[j].z)    
            SetBlipColour(Blip, 3)
            DrawMarker(23, Config.race[i].checkpoint[j].x, Config.race[i].checkpoint[j].y, Config.race[i].checkpoint[j].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)                    
                 
        end
    
end)

RegisterNetEvent('gm_race:client:prepare')

AddEventHandler('gm_race:client:prepare', function(id,label,coord)   
    local numCourse = tonumber(id)    
    local ped = PlayerPedId()
    PrintTable(coord,0)
    CreateThread(function()
        while true do
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vec3(coord.x,coord.y,coord.z))    
            if dist < 25 then
                DrawText3D(coord.x,coord.y,coord.z+1, "[E] Inscription "..label)
                if IsControlJustPressed(0, 38) then
                    exports.qbx_core:Notify("Votre participation est enregistrée", "success")
                    Go = true
                    WaitStartRace(numCourse)
                    break
                end
            end
            Wait(1)
        end
    end)
end)
    

RegisterNetEvent('gm_race:client:start')

AddEventHandler('gm_race:client:start', function(id,numRace,precision,repair,route,raceData,tour)        
    NumItRace = tonumber(numRace)  
    RaceId = tonumber(id)      
    CurrentRace.precision = tonumber(precision)
    CurrentRace.repair = repair
    CurrentRace.route = route
    CurrentRace.checkpoint =  raceData
    CurrentRace.tour=tour
end)



RegisterNetEvent('gm_race:client:msg')
AddEventHandler('gm_race:client:msg', function(msg)
    if (Go) then
        print(msg)
        --TriggerEvent("chatMessage","[Course]", {255, 0, 0}, msg)  
    end    

    if (CreateMod or Fin) then
        exports.qbx_core:Notify(msg)
    end
end)

RegisterNetEvent('gm_race:client:classement')
AddEventHandler('gm_race:client:classement', function(t)
    if type(t) == "table" then
        for k, v in pairs(t) do
            exports.qbx_core:Notify(tostring(k) .. ": " .. tostring(v), "inform",10000,"",'center-right')
            wait(500)
        end
    else
        print(tostring(t))
        exports.qbx_core:Notify(tostring(t), "inform",10000,"",'center-right')
    end
end)

RegisterNetEvent('gm_race:client:endrace')

AddEventHandler('gm_race:client:endrace', function(raceId)
    if (raceId == RaceId) then
        RaceId = 0
        Go = false
    end    
end)

RegisterNetEvent('gm_race:client:newRace')
AddEventHandler('gm_race:client:newRace', function(label,precision)
    NewRaceL.label=label 
    NewRaceL.precision=precision 
    CreateMod = true
    Fin = false
    exports.qbx_core:Notify("Mode création activé")
end)

RegisterNetEvent('gm_race:client:addCheckpoint')
AddEventHandler('gm_race:client:addCheckpoint', function(coords)
    if (CreateMod) then
        
        if NewRaceL.checkpoint then
            table.insert(NewRaceL.checkpoint, coords)
        else
            NewRaceL.checkpoint = {}
            table.insert(NewRaceL.checkpoint, coords)
        end

        local Blip = AddBlipForCoord(coords.x, coords.y, coords.z)    
        SetBlipColour(Blip, 3)
        table.insert(BlipsCreation, Blip)

        exports.qbx_core:Notify("Checkpoint ajouté")
    else
        exports.qbx_core:Notify("Le mode création n'est pas activé",'error')
    end
end)

RegisterNetEvent('gm_race:client:saveRace')
AddEventHandler('gm_race:client:saveRace', function(msg)
    TriggerServerEvent('gm_race:server:saveRace',NewRaceL)
    CreateMod = false
    Fin = true
    NewRaceL = {} 

    for i, Blip in ipairs(BlipsCreation) do
        RemoveBlip(Blip)
    end
    
end)