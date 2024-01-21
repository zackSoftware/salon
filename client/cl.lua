QBCore = nil
ESX = nil
local sitting = false
local cam

if(Config.Core == 'qb') then
    QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports["es_extended"]:getSharedObject()
end


function GetClosestCoordsHair()
    local selected = vector3(0.0,0.0,0.0)
    local closestDist = 88888888888888888888888
    local selectedIndex = -1
    for k,v in pairs(Config.Locations['HairChairs']) do
        local Coords = GetEntityCoords(GetPlayerPed(-1))
        if(GetDistanceBetweenCoords(Coords , v.coords) < closestDist) then
            closestDist = GetDistanceBetweenCoords(Coords , v.coords)
            selected = v.coords
            selectedIndex = v.chairID
        end
    end
    return selected , selectedIndex
end

function GetClosestCoordsNail()
    local selected = vector3(0.0,0.0,0.0)
    local closestDist = 88888888888888888888888
    local selectedIndex = -1
    for k,v in pairs(Config.Locations['NailChairs']) do
        local Coords = GetEntityCoords(GetPlayerPed(-1))
        if(GetDistanceBetweenCoords(Coords , v.coords) < closestDist) then
            closestDist = GetDistanceBetweenCoords(Coords , v.coords)
            selected = v.camCoords
            selectedIndex = v.chairID
        end
    end
    return selected , selectedIndex
end



function DisplayHelpText(string)
    BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(string)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end


function showMenu(page , data)
    SendNUIMessage({type = 'show' , page = page , data = data})
    SetNuiFocus(true, true)
end

function showProgress(time , text)
    SendNUIMessage({type = 'progress' , time = time , text = text})
end

RegisterNetEvent('SalonS:SentNotification')
AddEventHandler('SalonS:SentNotification', function(message , time)
    SendNUIMessage({type = 'notification' , message = message , time = time})
end)



if(Config.Core == 'qb') then


    RegisterNUICallback('PurchaseItem' , function(data ,cb)
        QBCore.Functions.TriggerCallback('SaloonS:PurchaseItem', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('closeUI', function(data , cb)
        SetNuiFocus(false ,false)
        if(data.page == 'Business') then
            QBCore.Functions.TriggerCallback('SaloonS:UpdateBusinessData', function(returned)
            
            end , data.businessData)
        end
        
    end)    


    RegisterNUICallback('submitApply' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:SubmitApplyForm', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('withdrawCompany' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:WithdrawComp', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data.amount)
    end)

    RegisterNUICallback('hirePlayer' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:hirePlayer', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error , pData = returned.data})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('confirmBook' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:confirmBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('declineBook' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:declineBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('purchaseItems' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:purchaseItems', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)


    RegisterNUICallback('submitBook' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:SubmitBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterCommand(Config.MenuCommands['BookedList'] , function(source , args)
        QBCore.Functions.TriggerCallback('SaloonS:GetBooked', function(returned)
            showMenu('bookedList' , returned)
        end , data)

    end)

    RegisterNUICallback('checkAppointment' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:checkAppointment', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('addStock' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:addStock', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)
    
    RegisterNUICallback('payAll' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:payAll', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data.amount)
    end)

    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())
            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['MainDesk'][1]) <= 0.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Book Page')

                if(IsControlJustPressed(0, 38)) then
                    showMenu('Main' , Config.Support)
                end
            end

            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['Shop'][1]) <= 0.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Open Shop')

                if(IsControlJustPressed(0, 38)) then
                    local items = {}
                    for k,v in pairs(Config.ShopItems) do
                        table.insert(items , {itemName = k ,itemLabel = v.label , itemImage = v.itemImage , itemPrice = v.price})
                    end
                    showMenu('Shop' , items)
                end
            end

            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['Boss'][1]) <= 2.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Open Boss Menu')

                if(IsControlJustPressed(0, 38)) then
                    QBCore.Functions.TriggerCallback('SaloonS:getBusinessData', function(returned)
                        local items = {}
                        for k,v in pairs(Config.ShopItems) do
                            table.insert(items , {itemName = k ,itemLabel = v.label , itemImage = v.itemImage , itemPrice = v.price})
                        end
                        showMenu('Business' , {b = returned , shopItems = items})

                    end)
                end
            end

            for k,v in pairs(Config.Locations['HairChairs']) do
                if (GetDistanceBetweenCoords(playerCoords, v.coords) <= 1.5) then
                    if(sitting == false) then
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To sit chair')
                    else
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To leave chair')
                    end
                    if(IsControlJustPressed(0, 38)) then
                        if(sitting == false) then
                            QBCore.Functions.TriggerCallback('SaloonS:checkChair', function(returned)
                                if(returned == true) then
                                    sitting = true
                                    TriggerServerEvent('SalonS:MarkChair', v.chairID)
                                    TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_BENCH", v.coords.x , v.coords.y , v.coords.z - 1.2  , 140.0 , 0.5 ,0 ,1) 
                                end
                            end , v.chairID)
                          
                        else
                            sitting = false 
                            TriggerServerEvent('SalonS:UnmarkChair', v.chairID)

                            ClearPedTasks(PlayerPedId())
                        end
                    end
                end
            end
            

            for k,v in pairs(Config.Locations['NailChairs']) do
                if (GetDistanceBetweenCoords(playerCoords, v.coords) <= 1.5) then
                    if(sitting == false) then
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To sit chair')
                    else
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To leave chair')
                    end
                    if(IsControlJustPressed(0, 38)) then
                        if(sitting == false) then
                            QBCore.Functions.TriggerCallback('SaloonS:checkChair', function(returned)
                                if(returned == true) then
                                    sitting = true
                                    TriggerServerEvent('SalonS:MarkChair', v.chairID)
                                    TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_BENCH", v.coords.x , v.coords.y , v.coords.z - 1.3  , v.coords.a , 0.5 ,0 ,1) 
                                end
                            end , v.chairID)
                          
                        else
                            sitting = false 
                            TriggerServerEvent('SalonS:UnmarkChair', v.chairID)

                            ClearPedTasks(PlayerPedId())
                        end
                    end
                end
            end
        end
    end)


    local selectedChair = -1


    RegisterCommand(Config.MenuCommands['HairMenu'] , function(source , args)
        QBCore.Functions.TriggerCallback('SaloonS:checkJob', function(returned)
            closest, selectedChair = GetClosestCoordsHair()
            TriggerServerEvent('SalonS:MakeChair' , index , 'hair')
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", closest.x + 1.5 , closest.y + 1.8, closest.z - 0.29, 0.00, 0.00, 140.00, 50.00, false, 0)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 1, true, true)
            QBCore.Functions.TriggerCallback('SaloonS:getChairUser' , function(user)
                local p = (GetPlayerPed(GetPlayerFromServerId(user)))
                showMenu('ApplyNails' , {type = 'Hair' , max = GetNumberOfPedDrawableVariations(p , 3) , current = 0})
            end ,  selectedChair)
        end)
    end)

    RegisterCommand(Config.MenuCommands['NailsMenu'] , function(source , args)
        closest, selectedChair = GetClosestCoordsNail()
        TriggerServerEvent('SalonS:MakeChair' , index , 'hair')
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", closest.x  , closest.y, closest.z - 1.05, -90.00, 0.00, closest.a, 50.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)

        QBCore.Functions.TriggerCallback('SaloonS:getChairUser' , function(user)
            local p = (GetPlayerPed(GetPlayerFromServerId(user)))
            nailsTable = {}

            for k,v in pairs(Config.Nails) do
                v.max = GetNumberOfPedTextureVariations(p , v.CategoryID , v.ClothID)
                table.insert(nailsTable, v)

            end
            showMenu('ApplyNails' , {type = 'Nails' , max = #Config.Nails , current = 0 , nailsData = nailsTable})
        end ,  selectedChair)

    end)

    RegisterNUICallback('changeHair' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:change', function(returned)
        end, data.num , selectedChair , 'Hair')
    end)

    RegisterNUICallback('changeNail' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:changeN', function(returned)
        end, data.num , data.type , selectedChair , 'Nail')
    end)
    


    RegisterNUICallback('changeHairColor' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:change', function(returned)
        end, tonumber(data.num) , selectedChair , 'HairColor')
    end)

    RegisterNUICallback('changeNailColor' , function(data , cb)
        QBCore.Functions.TriggerCallback('SaloonS:change', function(returned)
        end, tonumber(data.num) , selectedChair , 'NailColor')
    end)

   

    
    

    local currentHair = 0
    local currentHairColor = 0

    local currentNail = 1
    local currentNailColor = 0
    local CatIDNail = 3


    RegisterNetEvent('SalonS:changeHair')
    AddEventHandler('SalonS:changeHair' , function(num)
        currentHair = tonumber(num)
        SetPedComponentVariation(PlayerPedId() , 2 , tonumber(num) , 0)
    end)

    RegisterNetEvent('SalonS:changeHairColor')
    AddEventHandler('SalonS:changeHairColor' , function(color)
        currentHairColor = tonumber(color)

        SetPedHairColor(PlayerPedId(), tonumber(color), tonumber(color))

    end)

    RegisterNetEvent('SalonS:changeNail')
    AddEventHandler('SalonS:changeNail' , function(color , id)
        currentNail = tonumber(color)
        CatIDNail = id
        SetPedComponentVariation(PlayerPedId() , CatIDNail , currentNail , currentNailColor)
    end)

    RegisterNetEvent('SalonS:changeNailColor')
    AddEventHandler('SalonS:changeNailColor' , function(color)
        currentNailColor = tonumber(color)
        SetPedComponentVariation(PlayerPedId() , CatIDNail , currentNail , currentNailColor)
    end)
    

    RegisterNUICallback('saveHair' , function(data , cb)
        SetNuiFocus(false ,false)
        QBCore.Functions.TriggerCallback('SaloonS:saveSkin', function(returned)
        end, selectedChair, 'Hair' , currentHair , currentHairColor)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 1, false, false)
    end)

    RegisterNUICallback('saveNails' , function(data , cb)
        SetNuiFocus(false ,false)
        QBCore.Functions.TriggerCallback('SaloonS:saveSkin', function(returned)
        end, selectedChair, 'Nails' , currentNail , currentNailColor , CatIDNail)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 1, false, false)
    end)


    
end

RegisterNetEvent('showProgress:Sa')
AddEventHandler('showProgress:Sa' , function(time , text)
    showProgress(time , text)
end)

local did = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k,v in pairs(Config.Required) do
            local playerCoord = GetEntityCoords(PlayerPedId())
            if(GetDistanceBetweenCoords(playerCoord , v.ProcessCoords) < 3.0) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Collect '..k)
                if(IsControlJustPressed(0,38)) then
                    
                    TriggerServerEvent('SalonS:CollectItem' , k)

                end
            end

            if(v.ItemsRequired ~= false) then
                for key , value in pairs(v.ItemsRequired) do
                    if(GetDistanceBetweenCoords(playerCoord , value.coords) < 3.0) then
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To Process '..value.name)
                        if(IsControlJustPressed(0,38)) then
                            if(did == false) then
                                showProgress(10000 , 'Processing '..value.name)
                                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                                Citizen.Wait(10000)
                                did = false
                                ClearPedTasks(PlayerPedId())
                                TriggerServerEvent('SalonS:ProcessItem' , value.name , k)
                            end
                        end 
                    end
                end
            end
        end
    end
end)

RegisterCommand('showReq' , function()
    TriggerEvent('SalonS:OpenRequiredItemsShop')
end)

RegisterNetEvent('SalonS:OpenRequiredItemsShop')
AddEventHandler('SalonS:OpenRequiredItemsShop' , function()
    SetNuiFocus(true ,true)
    SendNUIMessage({type = 'show' , page = 'RequiredItems' , data = Config.RequiredItemsNpc['Items']})
end)

Citizen.CreateThread(function()
    local npcSettings = Config.RequiredItemsNpc['Npc']
    local modelHash = GetHashKey(npcSettings.Model)

    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    created_ped = CreatePed(0, modelHash , npcSettings.Coords.x ,npcSettings.Coords.y , npcSettings.Coords.z - 1 , npcSettings.Coords.a, false)
	FreezeEntityPosition(created_ped, true)
	SetEntityInvincible(created_ped, true)
	SetBlockingOfNonTemporaryEvents(created_ped, true)

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        if (GetDistanceBetweenCoords(playerCoords, npcSettings.Coords) <= 1.5) then
            DisplayHelpText('Press ~INPUT_CONTEXT~ To Open Required Items Shop')
    
            if(IsControlJustPressed(0, 38)) then
              TriggerEvent('SalonS:OpenRequiredItemsShop')
            end
        end
    end

end)

if(Config.Core == 'esx') then


    RegisterNUICallback('PurchaseItem' , function(data ,cb)
        ESX.TriggerServerCallback('SaloonS:PurchaseItem', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('closeUI', function(data , cb)
        SetNuiFocus(false ,false)
        if(data.page == 'Business') then
            ESX.TriggerServerCallback('SaloonS:UpdateBusinessData', function(returned)
            
            end , data.businessData)
        end
        
    end)    


    RegisterNUICallback('submitApply' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:SubmitApplyForm', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('withdrawCompany' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:WithdrawComp', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data.amount)
    end)

    RegisterNUICallback('hirePlayer' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:hirePlayer', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error , pData = returned.data})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('confirmBook' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:confirmBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('declineBook' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:declineBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('purchaseItems' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:purchaseItems', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)


    RegisterNUICallback('submitBook' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:SubmitBook', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterCommand(Config.MenuCommands['BookedList'] , function(source , args)
        ESX.TriggerServerCallback('SaloonS:GetBooked', function(returned)
            showMenu('bookedList' , returned)
        end , data)

    end)

    RegisterNUICallback('checkAppointment' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:checkAppointment', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)

    RegisterNUICallback('addStock' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:addStock', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data)
    end)
    
    RegisterNUICallback('payAll' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:payAll', function(returned)
            if(returned.error) then
                cb({error = true, message = returned.error})
            else
                cb(true)
            end
        end , data.amount)
    end)

    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())
            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['MainDesk'][1]) <= 0.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Book Page')

                if(IsControlJustPressed(0, 38)) then
                    showMenu('Main' , Config.Support)
                end
            end

            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['Shop'][1]) <= 0.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Open Shop')

                if(IsControlJustPressed(0, 38)) then
                    local items = {}
                    for k,v in pairs(Config.ShopItems) do
                        table.insert(items , {itemName = k ,itemLabel = v.label , itemImage = v.itemImage , itemPrice = v.price})
                    end
                    showMenu('Shop' , items)
                end
            end

            if (GetDistanceBetweenCoords(playerCoords, Config.Locations['Boss'][1]) <= 2.5) then
                DisplayHelpText('Press ~INPUT_CONTEXT~ To Open Boss Menu')

                if(IsControlJustPressed(0, 38)) then
                    ESX.TriggerServerCallback('SaloonS:getBusinessData', function(returned)
                        local items = {}
                        for k,v in pairs(Config.ShopItems) do
                            table.insert(items , {itemName = k ,itemLabel = v.label , itemImage = v.itemImage , itemPrice = v.price})
                        end
                        showMenu('Business' , {b = returned , shopItems = items})

                    end)
                end
            end

            for k,v in pairs(Config.Locations['HairChairs']) do
                if (GetDistanceBetweenCoords(playerCoords, v.coords) <= 1.5) then
                    if(sitting == false) then
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To sit chair')
                    else
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To leave chair')
                    end
                    if(IsControlJustPressed(0, 38)) then
                        if(sitting == false) then
                            ESX.TriggerServerCallback('SaloonS:checkChair', function(returned)
                                if(returned == true) then
                                    sitting = true
                                    TriggerServerEvent('SalonS:MarkChair', v.chairID)
                                    TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_BENCH", v.coords.x , v.coords.y , v.coords.z - 1.2  , 140.0 , 0.5 ,0 ,1) 
                                end
                            end , v.chairID)
                          
                        else
                            sitting = false 
                            TriggerServerEvent('SalonS:UnmarkChair', v.chairID)

                            ClearPedTasks(PlayerPedId())
                        end
                    end
                end
            end
            

            for k,v in pairs(Config.Locations['NailChairs']) do
                if (GetDistanceBetweenCoords(playerCoords, v.coords) <= 1.5) then
                    if(sitting == false) then
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To sit chair')
                    else
                        DisplayHelpText('Press ~INPUT_CONTEXT~ To leave chair')
                    end
                    if(IsControlJustPressed(0, 38)) then
                        if(sitting == false) then
                            ESX.TriggerServerCallback('SaloonS:checkChair', function(returned)
                                if(returned == true) then
                                    sitting = true
                                    TriggerServerEvent('SalonS:MarkChair', v.chairID)
                                    TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_BENCH", v.coords.x , v.coords.y , v.coords.z - 1.3  , v.coords.a , 0.5 ,0 ,1) 
                                end
                            end , v.chairID)
                          
                        else
                            sitting = false 
                            TriggerServerEvent('SalonS:UnmarkChair', v.chairID)

                            ClearPedTasks(PlayerPedId())
                        end
                    end
                end
            end
        end
    end)


    local selectedChair = -1


    RegisterCommand(Config.MenuCommands['HairMenu'] , function(source , args)
        ESX.TriggerServerCallback('SaloonS:checkJob', function(returned)
            closest, selectedChair = GetClosestCoordsHair()
            TriggerServerEvent('SalonS:MakeChair' , index , 'hair')
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", closest.x + 1.5 , closest.y + 1.8, closest.z - 0.29, 0.00, 0.00, 140.00, 50.00, false, 0)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 1, true, true)
            ESX.TriggerServerCallback('SaloonS:getChairUser' , function(user)
                local p = (GetPlayerPed(GetPlayerFromServerId(user)))
                showMenu('ApplyNails' , {type = 'Hair' , max = GetNumberOfPedDrawableVariations(p , 3) , current = 0})
            end ,  selectedChair)
        end)
    end)

    RegisterCommand(Config.MenuCommands['NailsMenu'] , function(source , args)
        closest, selectedChair = GetClosestCoordsNail()
        TriggerServerEvent('SalonS:MakeChair' , index , 'hair')
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", closest.x  , closest.y, closest.z - 1.05, -90.00, 0.00, closest.a, 50.00, false, 0)
        -- SetCamActive(cam, true)
        -- RenderScriptCams(true, false, 1, true, true)

        ESX.TriggerServerCallback('SaloonS:getChairUser' , function(user)
            local p = (GetPlayerPed(GetPlayerFromServerId(user)))
            nailsTable = {}

            for k,v in pairs(Config.Nails) do
                v.max = GetNumberOfPedTextureVariations(p , v.CategoryID , v.ClothID)
                table.insert(nailsTable, v)

            end
            showMenu('ApplyNails' , {type = 'Nails' , max = #Config.Nails , current = 0 , nailsData = nailsTable})
        end ,  selectedChair)

    end)

  
    RegisterNUICallback('changeHair' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:change', function(returned)
        end, data.num , selectedChair , 'Hair')
    end)

    RegisterNUICallback('changeNail' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:changeN', function(returned)
        end, data.num , data.type , selectedChair , 'Nail')
    end)
    


    RegisterNUICallback('changeHairColor' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:change', function(returned)
        end, tonumber(data.num) , selectedChair , 'HairColor')
    end)

    RegisterNUICallback('changeNailColor' , function(data , cb)
        ESX.TriggerServerCallback('SaloonS:change', function(returned)
        end, tonumber(data.num) , selectedChair , 'NailColor')
    end)

   

    
    

    local currentHair = 0
    local currentHairColor = 0

    local currentNail = 1
    local currentNailColor = 0
    local CatIDNail = 3


    RegisterNetEvent('SalonS:changeHair')
    AddEventHandler('SalonS:changeHair' , function(num)
        currentHair = tonumber(num)
        SetPedComponentVariation(PlayerPedId() , 2 , tonumber(num) , 0)
        
    end)

    RegisterNetEvent('SalonS:changeHairColor')
    AddEventHandler('SalonS:changeHairColor' , function(color)
        currentHairColor = tonumber(color)

        SetPedHairColor(PlayerPedId(), tonumber(color), tonumber(color))

    end)

    RegisterNetEvent('SalonS:changeNail')
    AddEventHandler('SalonS:changeNail' , function(color , id)
        currentNail = tonumber(color)
        CatIDNail = id
        SetPedComponentVariation(PlayerPedId() , CatIDNail , currentNail , currentNailColor)
    end)

    RegisterNetEvent('SalonS:changeNailColor')
    AddEventHandler('SalonS:changeNailColor' , function(color)
        currentNailColor = tonumber(color)
        SetPedComponentVariation(PlayerPedId() , CatIDNail , currentNail , currentNailColor)
    end)
    

    RegisterNUICallback('saveHair' , function(data , cb)
        SetNuiFocus(false ,false)
        ESX.TriggerServerCallback('SaloonS:saveSkin', function(returned)
        end, selectedChair, 'Hair' , currentHair , currentHairColor)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 1, false, false)
    end)

    RegisterNUICallback('saveNails' , function(data , cb)
        SetNuiFocus(false ,false)
        ESX.TriggerServerCallback('SaloonS:saveSkin', function(returned)
        end, selectedChair, 'Nails' , currentNail , currentNailColor , CatIDNail)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 1, false, false)
    end)



    RegisterNetEvent('SalonS:changeHairColor')
    AddEventHandler('SalonS:changeHairColor' , function(color)
        TriggerEvent('skinchanger:change', 'hair_color_1', tonumber(color)) 
        TriggerEvent('skinchanger:change', 'hair_color_2', tonumber(color)) 
    end)

end