local QBCore = exports['qb-core']:GetCoreObject()
local RaceId = 0
local Go = false

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
    Wait(1000)
    exports.qbx_core:Notify("3", "success")
    Wait(1000)
    exports.qbx_core:Notify("2", "success")
    Wait(1000)
    exports.qbx_core:Notify("1", "success")
    Wait(1000)
    exports.qbx_core:Notify("Go !", "success")

    local t1 = GetGameTimer() 
    local ped = PlayerPedId()
    local numCourse = tonumber(RaceId)  
    for j = 1, #Config.race[numCourse].checkpoint,1 do           
        local Blip = AddBlipForCoord(Config.race[numCourse].checkpoint[j].x, Config.race[numCourse].checkpoint[j].y, Config.race[numCourse].checkpoint[j].z)    
        SetBlipColour(Blip, 3)
        SetBlipRoute(Blip, true)
        SetBlipRouteColour(Blip, 3)           
        local Blip2
        if ((j+1) < #Config.race[numCourse].checkpoint) then
            Blip2 = AddBlipForCoord(Config.race[numCourse].checkpoint[j+1].x, Config.race[numCourse].checkpoint[j+1].y, Config.race[numCourse].checkpoint[j+1].z)  
        end
        while true do
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(Config.race[numCourse].checkpoint[j]))               
            if dist < 25 then
                RemoveBlip(Blip)
                SetVehicleFixed(GetVehiclePedIsIn(ped,true))
                if ((j+1) < #Config.race[numCourse].checkpoint) then
                    RemoveBlip(Blip2)
                end
                break
            end
            Wait(100)
        end
    end
    local t2 = GetGameTimer() 
    local t3 = t2-t1
    local t = math.floor(t3/1000)    
    local min = math.floor(t/60)
    local sec = t -min*60;
    t3 = t3-t
    local playerName = QBCore.Functions.GetPlayerData().charinfo.firstname .. " " .. QBCore.Functions.GetPlayerData().charinfo.lastname
    local msg = playerName.." a fini la course en "..min..":"..sec.." "..t3
    Wait(1000)
    exports.qbx_core:Notify(msg, "success")
    --..("%02d:%02d"):format(t3.min, t3.sec)
	TriggerServerEvent('gm_race:server:msg',RaceId, playerName,min,sec,t3)
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

AddEventHandler('gm_race:client:prepare', function(id)   
local numCourse = tonumber(id)    
    local ped = PlayerPedId()
    CreateThread(function()
        while true do
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(Config.race[numCourse].start))    
            if dist < 25 then
                DrawText3D(Config.race[numCourse].start.x,Config.race[numCourse].start.y,Config.race[numCourse].start.z+1, "[E] Inscription")
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

AddEventHandler('gm_race:client:start', function(id)
    local numCourse = tonumber(id)  
    RaceId = tonumber(id)      
end)

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

RegisterNetEvent('gm_race:client:msg')
AddEventHandler('gm_race:client:msg', function(msg)
    if (Go) then
        print(msg)
        --TriggerEvent("chatMessage","[Course]", {255, 0, 0}, msg)  
    end    
end)

RegisterNetEvent('gm_race:client:classement')
AddEventHandler('gm_race:client:classement', function(msg)
    PrintTable(msg)
    --TriggerEvent("chatMessage","[Course]", {255, 0, 0}, msg)    
end)

RegisterNetEvent('gm_race:client:endrace')

AddEventHandler('gm_race:client:endrace', function(raceId)
    if (raceId == RaceId) then
        RaceId = 0
        Go = false
    end    
end)
