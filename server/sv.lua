
QBCore = nil
ESX = nil
local Framework = require 'framework.server'
if(Config.Core == 'qb') then
    QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports["es_extended"]:getSharedObject()
end

local Chairs = {}

function checkJob(xPlayer,checkboss)
    if(Config.Core == 'qb') then
        local Player = xPlayer
        local jobName = Player.PlayerData.job.name
        if(jobName == 'salon') then
            if(checkboss ~= true) then
                return true
            else
                if(Player.PlayerData.job.isboss == true) then
                    return true
                end
            end
        end
        return false
    else
        local player = xPlayer
        local pJob = player.getJob()
        if(pJob.name == 'salon') then
            if(checkboss ~= true) then
                return true
            else
                if(pJob.grade == 4) then
                    return true
                end
            end
        end
        return false
    end
end

Citizen.CreateThread(function()
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
    local jsonFileData = json.decode(loadFile)
    for k,v in pairs(Config.ShopItems) do
        if(not string.find(loadFile , k)) then
            table.insert(jsonFileData , {quan = 0 , itemName = k })
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json", json.encode(jsonFileData), -1)
end)

function updateStats(price) 
    exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
        if(result[1] == nil) then
            return print('[Salon] Please insert the db file')
        else
            local monthName = os.date("%B")
            local oldData = json.decode(result[1].businessData)
            oldData[1].businessEncomy.businessSales = tonumber(oldData[1].businessEncomy.businessSales) + 1
            oldData[1].businessEncomy.salesGraph[monthName] = tonumber(oldData[1].businessEncomy.salesGraph[monthName]) + 1
            
            oldData[1].businessEncomy.businessMade = tonumber(oldData[1].businessEncomy.businessMade) + price
            oldData[1].businessEncomy.businessWeekMade = tonumber(oldData[1].businessEncomy.businessWeekMade) + price
            oldData[1].businessEncomy.businessMoney = tonumber(oldData[1].businessEncomy.businessMoney) + price

            
            exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(oldData)}, function(n)
            end)
        end
    end)
end

RegisterNetEvent('SalonS:MarkChair')
AddEventHandler('SalonS:MarkChair' , function(chair)
    Chairs[chair] = {}
    Chairs[chair].status = true
    Chairs[chair].user = source

end)


RegisterNetEvent('SalonS:UnmarkChair')
AddEventHandler('SalonS:UnmarkChair' , function(chair)
    Chairs[chair] = nil
end)


if(Config.Core == 'qb') then
    QBCore.Functions.CreateCallback('SaloonS:UpdateBusinessData', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid

        if(checkJob(xPlayer , true) == true) then
            for k,v in pairs(data) do
                exports["oxmysql"]:execute('SELECT * FROM players WHERE citizenid =  @id', {['@id'] = v.cid}, function(result)
                    if(result[1]) then
                        if(QBCore.Functions.GetPlayerByCitizenId(v.cid)) then
                            local player = QBCore.Functions.GetPlayerByCitizenId(v.cid)
                            player.Functions.SetJob('salon' , tonumber(v.gradeNumber))                            
                        end

                        local grade = json.decode(result[1].job)
                        grade.level = tonumber(v.gradeNumber)
                        grade.name = tonumber(v.gradeName)
                        grade.payment = tonumber(v.payment)

                        exports["oxmysql"]:execute('UPDATE players SET job = @grade WHERE citizenid = @identifier', {['@identifier'] = v.cid , ['@grade'] = json.encode(grade)}, function(n)
                        end)
                    end
                end)
            end
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local oldData = json.decode(result[1].businessData)
                    oldData[1].businessEmployees = data
                    exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(oldData)}, function(n)
                    end)
                end
            end)

        end

    end)

    QBCore.Functions.CreateCallback('SaloonS:WithdrawComp', function(source, cb, amount)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid

        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local bData = json.decode(result[1].businessData)
                    local businessMoney = bData[1]['businessEncomy'].businessMoney

                    if(tonumber(businessMoney) >= tonumber(amount)) then
                        bData[1]['businessEncomy'].businessMoney = bData[1]['businessEncomy'].businessMoney - tonumber(amount)
                        exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(bData)}, function(n)
                        end)

                        xPlayer.Functions.AddMoney('bank' , tonumber(amount))
                        cb({error = 'Successfully withdrawn <span style="color: green">$'..amount..'</span>'})
                    end
                end
            end)
        end
    end)

    QBCore.Functions.CreateCallback('SaloonS:SubmitApplyForm', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                if(xPlayer.PlayerData.job.name == 'salon') then return end
                local pendingPlayers = json.decode(result[1].businessData)
                for k,v in ipairs(pendingPlayers[1].JobApplications) do
                    if(v.identifier == license) then
                        return cb({error = 'Already <span style="color: red">Sent</span>'})                    
                    end
                end
                data.identifier = license
                table.insert(pendingPlayers[1].JobApplications , data)
                exports["oxmysql"]:execute('UPDATE salon SET businessData = @job WHERE id = 1', {['@job'] = json.encode(pendingPlayers)}, function(n)
                end)
                cb({})

            end
        end)
    end)
    QBCore.Functions.CreateCallback('SaloonS:PurchaseItem', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if(data.quant == nil) then
            data.quant = 1
        end
        local license = xPlayer.PlayerData.citizenid
        if(xPlayer.PlayerData.money['bank'] >= tonumber(data.quant) * tonumber(data.price)) then
            xPlayer.Functions.RemoveMoney('bank' , tonumber(data.quant) * tonumber(data.price))
            Framework:AddItem(source, data.name, tonumber(data.quant))
            cb({error = 'Successfully Purchased <span style="color: green">'..data.label..'</span>'})
        end
    end)



    QBCore.Functions.CreateCallback('SaloonS:purchaseItems', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        local totalPaid = 0

        local loadFile = LoadResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
        local jsonFileData = json.decode(loadFile)
        for k,v in pairs(data) do
            local itemName = v.itemName
            local itemQuantity = v.ItemQuan
            local price = Config.ShopItems[itemName].price
            if(xPlayer.PlayerData.money['bank'] >= (tonumber(price) * tonumber(itemQuantity))) then
                xPlayer.Functions.RemoveMoney('bank', tonumber(tonumber(price) * tonumber(itemQuantity)))
                Framework:AddItem(source, itemName, tonumber(itemQuantity))
                totalPaid = totalPaid + (tonumber(price) * tonumber(itemQuantity))
                for k,v in pairs(jsonFileData) do
                    if(v.itemName == itemName) then
                        v.quan = v.quan- tonumber(itemQuantity)
                    end
                end
                SaveResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json", json.encode(jsonFileData), -1)

            end
        end
        updateStats(totalPaid)

        cb({error = 'Successfully received items | Total: <span style="color: red">$'..totalPaid..'</span>'})

    end)



    QBCore.Functions.CreateCallback('SaloonS:checkChair', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        
        if(Chairs[data] == nil) then 
            cb(true)             
        else
            cb(false)
        end
    end)

    
    QBCore.Functions.CreateCallback('SaloonS:saveSkin', function(source, cb, selectedChair,type , currentHair , currentHairColor , id)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        
       local targetPlayer = Chairs[selectedChair].user
       local targetUser = QBCore.Functions.GetPlayer(targetPlayer)

        exports["oxmysql"]:execute('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { targetUser.PlayerData.citizenid, 1 } , function(result)
            if result[1] ~= nil then
                skin = json.decode(result[1].skin)
            end

            if(type == 'Hair') then
                skin['hair_1'].item = currentHair
                skin['hair_1'].texture = currentHairColor
            end 

            if(type == 'Nails') then

                local f1
                if(id == 1) then
                    f1 = 'mask'
                end

                if(id == 7) then
                    f1 = 'accessory'
                end

                if(id ==  3) then
                    f1 = 'torso'
                end

           
                skin[f1].item = currentHair
                skin[f1].texture = currentHairColor
            end 

            exports["oxmysql"]:execute('DELETE FROM playerskins WHERE citizenid = ?', { targetUser.PlayerData.citizenid }, function()
                exports["oxmysql"]:execute('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                    targetUser.PlayerData.citizenid,
                    GetPlayerPed(targetPlayer),
                    json.encode(skin),
                    1
                })
            end)
        end)
     
    end)

    

    QBCore.Functions.CreateCallback('SaloonS:addStock', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer , true) == true) then
            local loadFile = LoadResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
            local jsonFileData = json.decode(loadFile)


            for i,s in pairs(data.items) do
                for k,v in pairs(jsonFileData) do
                    if(v.itemName == s.itemName) then
                        local usercount = Framework:GetItem(source, s.itemName).count
                        if(usercount >= data.amount) then
                            v.quan = v.quan + tonumber(data.amount)
                            Framework:RemoveItem(source, s.itemName, tonumber(itemQuantity))
                        end
                    end
                end
                SaveResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json", json.encode(jsonFileData), -1)
            end
        end
        cb({})
    end)


    QBCore.Functions.CreateCallback('SaloonS:change', function(source, cb, num , chair ,type)
        local playerTarget = Chairs[chair].user
        if(playerTarget == nil) then return end

        if(type == 'Hair') then
            TriggerClientEvent('SalonS:changeHair' , playerTarget , num)
        end
        if(type == 'HairColor') then
            TriggerClientEvent('SalonS:changeHairColor' , playerTarget , num)
        end
        if(type == 'NailColor') then
            TriggerClientEvent('SalonS:changeNailColor' , playerTarget , num)
        end


    
        
    end)

    QBCore.Functions.CreateCallback('SaloonS:changeN', function(source, cb, num, type2 , chair ,type)
        local playerTarget = Chairs[chair].user
        if(playerTarget == nil) then return end
        TriggerClientEvent('SalonS:changeNail' , playerTarget , num , type2)

    end)



    QBCore.Functions.CreateCallback('SaloonS:getChairUser', function(source, cb, chair)
        local playerTarget = Chairs[chair].user
        cb(playerTarget)
    end)


    QBCore.Functions.CreateCallback('SaloonS:GetBooked', function(source, cb)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    cb(json.decode(result[1].booksList))
                end
            end)
        end
    end)

    QBCore.Functions.CreateCallback('SaloonS:hirePlayer', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                local pendingPlayers = json.decode(result[1].businessData)

                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(data.data.identifier)
                if(targetPlayer) then
                    TriggerClientEvent('SalonS:SentNotification' , xPlayer.PlayerData.source , 'You have <span style="color: green">hired</span> to Salon' , 5000)

                        targetPlayer.Functions.SetJob('salon' ,  tonumber(data.data.gradeNumber))
                    else
                        exports["oxmysql"]:execute('UPDATE players SET job = "salon" WHERE citizenid = @identifier', {['@identifier'] = data.data.identifier}, function(n)
                        end)
                        exports["oxmysql"]:execute('UPDATE players SET job_grade = @grade WHERE citizenid = @identifier', {['@identifier'] = data.data.identifier , ['@grade'] = tonumber(data.data.gradeNumber)}, function(n)
                        end)
                    end
                end
                for k,v in pairs(pendingPlayers[1].JobApplications) do
                    if(v.identifier == data.data.identifier) then
                        table.remove(pendingPlayers[1].JobApplications , k)
                    end
                end
                exports["oxmysql"]:execute('SELECT * FROM players WHERE citizenid = @identifier', {['@identifier'] = data.data.identifier}, function(result22)
                    table.insert(pendingPlayers[1].businessEmployees , {payment = data.data.payment , gradeNumber = data.data.gradeNumber , cid = data.data.identifier , name = json.decode(result22[1].charinfo).firstname..' '..json.decode(result22[1].charinfo).lastname})
                    local pdata = {payment = data.data.payment , gradeNumber = data.data.gradeNumber , cid = data.data.identifier , name = json.decode(result22[1].charinfo).firstname..' '..json.decode(result22[1].charinfo).lastname}
                    exports["oxmysql"]:execute('UPDATE salon SET businessData = @job WHERE id = 1', {['@job'] = json.encode(pendingPlayers)}, function(n)
                    end)
                    cb({error = "Successfully hired "..data.data.fullName , data = pdata})

                end)
            
            end)
        end
    end)


    function payBook(data)
        local price = Config.Prices[data.partSelected]
        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(data.identifier)

        if(targetPlayer) then
            targetPlayer.Functions.RemoveMoney('bank' , price)
            TriggerClientEvent('SalonS:SentNotification' , targetPlayer.PlayerData.source , 'Your appointment have <span style="color: green">confirmed</span>' , 5000)

        else
            exports["oxmysql"]:execute('SELECT * FROM players WHERE citizenid = @id ', {['@id'] = data.identifier}, function(res)
                if(res[1]) then
                    local data = json.decode(res[1].accounts)
                    data['bank'] = data['bank'] - tonumber(price)
                    exports["oxmysql"]:execute('UPDATE players SET accounts = @data WHERE citizenid = @id ', {['@id'] = data.identifier , ['@data'] = json.encode(data)}, function(d)
                    end)
                end
            end)
        end

        updateStats(price)


    end

    QBCore.Functions.CreateCallback('SaloonS:confirmBook', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local booksList = json.decode(result[1].booksList)
                    for k,v in ipairs(booksList) do
                        if(data.all == true) then
                            v.accepted = true  
                            payBook(v)           
                        else
                            if(v.identifier == data.identifier) then
                                v.accepted = true     
                                payBook(v)         
                            end
                        end
                    end
                    exports["oxmysql"]:execute('UPDATE salon SET booksList = @data WHERE id = 1', {['@data'] = json.encode(booksList)}, function(n)
                    end)
                end
        
            end)
        end
        cb({})
    end)

    QBCore.Functions.CreateCallback('SaloonS:declineBook', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local booksList = json.decode(result[1].booksList)
                        for k,v in ipairs(booksList) do
                            if(data.all == true) then
                                v.accepted = false             
                            else
                                if(v.identifier == data.identifier) then
                                    v.accepted = false              
                                end
                            end
                        end
                    exports["oxmysql"]:execute('UPDATE salon SET booksList = @data WHERE id = 1', {['@data'] = json.encode(booksList)}, function(n)
                    end)
                end
        
            end)
        end
        cb({})
    end)

    QBCore.Functions.CreateCallback('SaloonS:SubmitBook', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                local booksList = json.decode(result[1].booksList)
                for k,v in ipairs(booksList) do
                    if(v.identifier == license) then
                        if(v.accepted == 'none') then
                            return cb({error = 'Already have a pending appointment'})   
                        end                 
                    end
                end

                data.identifier = license
                data.accepted = 'none'

                local firstname = xPlayer.PlayerData.charinfo.firstname
                local lastname = xPlayer.PlayerData.charinfo.lastname
                data.name = firstname..' '..lastname
                table.insert(booksList , data)
                exports["oxmysql"]:execute('UPDATE salon SET booksList = @job WHERE id = 1', {['@job'] = json.encode(booksList)}, function(n)
                end)
                cb({})

            end
        end)
    end)

    QBCore.Functions.CreateCallback('SaloonS:checkAppointment', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                local booksList = json.decode(result[1].booksList)
                for k,v in ipairs(booksList) do
                    if(v.identifier == license) then
                        local status =''
                        if(v.accepted == true) then
                            status = "Is <span style='color: green'>Accepted</span>"
                        elseif(v.accepted == false) then
                            status = "Got <span style='color: red'>Declined</span>"
                        else
                            status = "Is <span style='color: yellow'>Pending</span>"
                        end

                        if(v.accepted == false) then
                            table.remove(booksList , k)
                            exports["oxmysql"]:execute('UPDATE salon SET booksList = @job WHERE id = 1', {['@job'] = json.encode(booksList)}, function(n)
                            end)
                        end

                        return cb({error = 'Your Appointment '..status})                    
                    end
                end
                cb({error = "Couldn't find any appointment"})
            end
        end)
    end)

    QBCore.Functions.CreateCallback('SaloonS:checkJob' , function(source , cb , getped)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer) == true) then
            
            cb(true)
        end

    end)


    QBCore.Functions.CreateCallback('SaloonS:payAll', function(source, cb, amount)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid

        if(checkJob(xPlayer , true) == true) then
            local addedP = 0

            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local bData = json.decode(result[1].businessData)

                    local businessMoney = bData[1]['businessEncomy'].businessMoney
                    if(businessMoney >= tonumber(amount * #bData[1].businessEmployees) ) then
                        for k,v in pairs(bData[1].businessEmployees) do
                            local pLicense = v.cid
                            if(QBCore.Functions.GetPlayerByCitizenId(pLicense)) then
                                xPlayer = QBCore.Functions.GetPlayerByCitizenId(pLicense)
                                xPlayer.Functions.AddMoney('bank' , tonumber(amount))
                                addedP = addedP + 1
                                TriggerClientEvent('SalonS:SentNotification' , xPlayer.PlayerData.source , 'You have <span style="color: green">received</span> $<span style="color: green">'..amount..'</span>' , 5000)
                            else
                                exports["oxmysql"]:execute('SELECT * FROM players WHERE citizenid = @id ', {['@id'] = pLicense}, function(res)
                                    if(res[1]) then
                                        local data = json.decode(res[1].money)
                                        data['bank'] = data['bank'] + tonumber(amount)
                                        exports["oxmysql"]:execute('UPDATE players SET money = @data WHERE citizenid = @id ', {['@id'] = pLicense , ['@data'] = json.encode(data)}, function(d)
                                        end)
                                        addedP = addedP + 1
                                    end
                                end)
                            end
                            
                        end
                    end

                    bData[1]['businessEncomy'].businessMoney = bData[1]['businessEncomy'].businessMoney - tonumber(amount*addedP)
                    exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(bData)}, function(n)
                    end)

        
                    return cb({error = '<span style="color: green">Successfully</span> Paid $<span style="color: green">'..amount..'</span> to '..addedP..' employees!'})                    
                end
            end)
        end
    end)

    
    QBCore.Functions.CreateCallback('SaloonS:getBusinessData', function(source, cb, data)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local license = xPlayer.PlayerData.citizenid
        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else

            
                    local bData = json.decode(result[1].businessData)
                    if(os.date('%w') == 0) then 
                        bData[1].businessEncomy.checkedIn = 0 
                        bData[1].businessEncomy.businessWeekMade = 0 
                        bData[1].businessEncomy.businessSales = 0 

                    end
                    if(#bData == 0) then
                        bData = {}
                        bData['businessEncomy'] = {
                            businessSales = 0,
                            businessMade = 0,
                            businessWeekMade = 0,
                            businessMoney = 0,
                            businessEngagment = 0,
                            checkedIn = 0,
                            salesGraph = {January = 0 , February = 0 , March = 0 , April = 0 , May = 0 , June = 0 , July = 0 ,August = 0, September = 0 , October = 0, November = 0 , December = 0  },
                        }
                        local firstname = xPlayer.PlayerData.charinfo.firstname
                        local lastname = xPlayer.PlayerData.charinfo.lastname
                        bData['businessEmployees'] = {
                            {name = firstname..' '..lastname , cid = license , gradeName = xPlayer.PlayerData.job.grade.name , gradeNumber = xPlayer.PlayerData.job.grade.level , payment = xPlayer.PlayerData.job.payment}
                        }
                        bData['JobApplications'] = {}
                        exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode({bData})}, function(n)
                        
                        end)
                        bData['Targets'] = Config.BusinessTargets
                        cb(bData)
                    else
                        bData[1]['Targets'] = Config.BusinessTargets
                        cb(bData[1])
                    end
                end
            end)
        end
    end)
end


RegisterNetEvent('SalonS:ProcessItem')
AddEventHandler('SalonS:ProcessItem' , function(d , target)
    for k,v in pairs(Config.Required[target].ItemsRequired) do
        if(v.name == d) then
            Framework:AddItem(source, d, 1)
        end
    end
end)



RegisterNetEvent('SalonS:CollectItem')
AddEventHandler('SalonS:CollectItem' , function(target)
   for k,v in pairs(Config.Required) do
    if(k == target) then
        local playerCoord = GetEntityCoords(GetPlayerPed(source))
        if(#(playerCoord - v.ProcessCoords) < 3.0) then
            local chance = math.random(1,100)
            if(Config.Required[target].ItemsRequired ~= false) then
                for key , value in pairs(Config.Required[target].ItemsRequired) do
                    local usercount = Framework:GetItem(source, value.name).count
                    if(usercount < 1) then
                        return
                    else
                        Framework:RemoveItem(source, value.name, 1)
                    end
                end
            end
            TriggerClientEvent('showProgress:Sa', source , 3000 , 'Collecting '..k)
            Citizen.Wait(3000)
            if((chance / 100) >= (1-v.RareItemChance)) then 
                Framework:AddItem(source, Config.RareItem, 1)
            else
                Framework:AddItem(source, k, 1)

            end
        end
    end
   end
end)


if(Config.Core == 'esx') then




    ESX.RegisterServerCallback('SaloonS:PurchaseItem', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        if(data.quant == nil) then
            data.quant = 1
        end
        local license = xPlayer.getIdentifier()
        if(xPlayer.getAccount('bank').money >= tonumber(data.quant) * tonumber(data.price)) then
            xPlayer.removeAccountMoney('bank' , tonumber(data.quant) * tonumber(data.price))
            Framework:AddItem(source, data.name, tonumber(data.quant))
            cb({error = 'Successfully Purchased <span style="color: green">'..data.label..'</span>'})
        end
    end)

    

    ESX.RegisterServerCallback('SaloonS:UpdateBusinessData', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()

        if(checkJob(xPlayer , true) == true) then
            for k,v in pairs(data) do
                exports["oxmysql"]:execute('SELECT * FROM users WHERE identifier =  @id', {['@id'] = v.cid}, function(result)
                    if(result[1]) then
                        if(ESX.GetPlayerFromIdentifier(v.cid)) then
                            local player = ESX.GetPlayerFromIdentifier(v.cid)
                            player.setJob('salon' , tonumber(v.gradeNumber))
                        else
                            exports["oxmysql"]:execute('UPDATE users SET job_grade = @grade WHERE identifier = @identifier', {['@identifier'] = v.cid , ['@grade'] = tonumber(v.gradeNumber)}, function(n)
                            end)
                        end
                    end
                end)
            end
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local oldData = json.decode(result[1].businessData)
                    oldData[1].businessEmployees = data
                    exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(oldData)}, function(n)
                    end)
                end
            end)

        end

    end)

    ESX.RegisterServerCallback('SaloonS:WithdrawComp', function(source, cb, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()

        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local bData = json.decode(result[1].businessData)
                    local businessMoney = bData[1]['businessEncomy'].businessMoney

                    if(tonumber(businessMoney) >= tonumber(amount)) then
                        bData[1]['businessEncomy'].businessMoney = bData[1]['businessEncomy'].businessMoney - tonumber(amount)
                        exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode(bData)}, function(n)
                        end)

                        xPlayer.addAccountMoney('bank' , tonumber(amount))
                        cb({error = 'Successfully withdrawn <span style="color: green">$'..amount..'</span>'})
                    end
                end
            end)
        end
    end)

    ESX.RegisterServerCallback('SaloonS:SubmitApplyForm', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                if(xPlayer.getJob().name == 'salon') then return end
                local pendingPlayers = json.decode(result[1].businessData)
                for k,v in ipairs(pendingPlayers[1].JobApplications) do
                    if(v.identifier == license) then
                        return cb({error = 'Already <span style="color: red">Sent</span>'})                    
                    end
                end
                data.identifier = license
                table.insert(pendingPlayers[1].JobApplications , data)
                exports["oxmysql"]:execute('UPDATE salon SET businessData = @job WHERE id = 1', {['@job'] = json.encode(pendingPlayers)}, function(n)
                end)
                cb({})

            end
        end)
    end)



    ESX.RegisterServerCallback('SaloonS:purchaseItems', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        local totalPaid = 0

        local loadFile = LoadResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
        local jsonFileData = json.decode(loadFile)
        for k,v in pairs(data) do
            local itemName = v.itemName
            local itemQuantity = v.ItemQuan
            local price = Config.ShopItems[itemName].price
            if(xPlayer.getAccount('bank').money >= (tonumber(price) * tonumber(itemQuantity))) then
                xPlayer.removeAccountMoney('bank', tonumber(tonumber(price) * tonumber(itemQuantity)))
                Framework:AddItem(source, itemName, tonumber(itemQuantity))
                totalPaid = totalPaid + (tonumber(price) * tonumber(itemQuantity))
                for k,v in pairs(jsonFileData) do
                    if(v.itemName == itemName) then
                        v.quan = v.quan- tonumber(itemQuantity)
                    end
                end
                SaveResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json", json.encode(jsonFileData), -1)

            end
        end
        updateStats(totalPaid)

        cb({error = 'Successfully received items | Total: <span style="color: red">$'..totalPaid..'</span>'})

    end)



    ESX.RegisterServerCallback('SaloonS:checkChair', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(Chairs[data] == nil) then 
            cb(true)             
        else
            cb(false)
        end
    end)


    ESX.RegisterServerCallback('SaloonS:addStock', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer , true) == true) then
            local loadFile = LoadResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
            local jsonFileData = json.decode(loadFile)


            for i,s in pairs(data.items) do
                for k,v in pairs(jsonFileData) do
                    if(v.itemName == s.itemName) then
                        local usercount = Framework:GetItem(source, s.itemName).count
                        if(usercount >= data.amount) then
                            v.quan = v.quan + tonumber(data.amount)
                            Framework:RemoveItem(source, s.itemName, tonumber(itemQuantity))
                        end
                    end
                end
                SaveResourceFile(GetCurrentResourceName(), "/interface/itemsStock.json", json.encode(jsonFileData), -1)
            end
        end
        cb({})
    end)




    ESX.RegisterServerCallback('SaloonS:change', function(source, cb, num , chair ,type)
        local playerTarget = Chairs[chair].user
        if(playerTarget == nil) then return end

        if(type == 'Hair') then
            TriggerClientEvent('SalonS:changeHair' , playerTarget , num)
        end
        if(type == 'HairColor') then
            TriggerClientEvent('SalonS:changeHairColor' , playerTarget , num)
        end
        if(type == 'NailColor') then
            TriggerClientEvent('SalonS:changeNailColor' , playerTarget , num)
        end


    
        
    end)

    ESX.RegisterServerCallback('SaloonS:changeN', function(source, cb, num, type2 , chair ,type)
        local playerTarget = Chairs[chair].user
        if(playerTarget == nil) then return end
        TriggerClientEvent('SalonS:changeNail' , playerTarget , num , type2)

    end)


    ESX.RegisterServerCallback('SaloonS:getChairUser', function(source, cb, chair)
        local playerTarget = Chairs[chair].user
        cb(playerTarget)
    end)


    ESX.RegisterServerCallback('SaloonS:GetBooked', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    cb(json.decode(result[1].booksList))
                end
            end)
        end
    end)

    ESX.RegisterServerCallback('SaloonS:hirePlayer', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                local pendingPlayers = json.decode(result[1].businessData)

                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                local targetPlayer = ESX.GetPlayerFromIdentifier(data.data.identifier)
                if(targetPlayer) then
                    TriggerClientEvent('SalonS:SentNotification' , xPlayer.source , 'You have <span style="color: green">hired</span> to Salon' , 5000)

                        targetPlayer.setJob('salon' ,  tonumber(data.data.gradeNumber))
                else
                        exports["oxmysql"]:execute('UPDATE users SET job = "salon" WHERE identifier = @identifier', {['@identifier'] = data.data.identifier}, function(n)
                        end)
                        exports["oxmysql"]:execute('UPDATE users SET job_grade = @grade WHERE identifier = @identifier', {['@identifier'] = data.data.identifier , ['@grade'] = tonumber(data.data.gradeNumber)}, function(n)
                        end)
                end
                end
                for k,v in pairs(pendingPlayers[1].JobApplications) do
                    if(v.identifier == data.data.identifier) then
                        table.remove(pendingPlayers[1].JobApplications , k)
                    end
                end
                exports["oxmysql"]:execute('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = data.data.identifier}, function(result22)
                    table.insert(pendingPlayers[1].businessEmployees , {payment = data.data.payment , gradeNumber = data.data.gradeNumber , cid = data.data.identifier , name = result22[1].firstname..' '..result22[1].lastname})
                    local pdata = {payment = data.data.payment , gradeNumber = data.data.gradeNumber , cid = data.data.identifier , name = result22[1].firstname..' '..result22[1].lastname}
                    exports["oxmysql"]:execute('UPDATE salon SET businessData = @job WHERE id = 1', {['@job'] = json.encode(pendingPlayers)}, function(n)
                    end)
                    cb({error = "Successfully hired "..data.data.fullName , data = pdata})

                end)
            
            end)
        end
    end)


    function payBook(data)
        local price = Config.Prices[data.partSelected]
        local targetPlayer = ESX.GetPlayerFromIdentifier(data.identifier)

        
        if(targetPlayer) then
            targetPlayer.removeAccountMoney('bank' , price)
            TriggerClientEvent('SalonS:SentNotification' , targetPlayer.source , 'Your appointment have <span style="color: green">confirmed</span>' , 5000)

        else
            exports["oxmysql"]:execute('SELECT * FROM users WHERE identifier = @id ', {['@id'] = data.identifier}, function(res)
                if(res[1]) then
                    local data = json.decode(res[1].accounts)
                    data['bank'] = data['bank'] - tonumber(price)
                    exports["oxmysql"]:execute('UPDATE users SET accounts = @data WHERE identifier = @id ', {['@id'] = data.identifier , ['@data'] = json.encode(data)}, function(d)
                    end)
                end
            end)
        end

        updateStats(price)


    end

    ESX.RegisterServerCallback('SaloonS:confirmBook', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local booksList = json.decode(result[1].booksList)
                    for k,v in ipairs(booksList) do
                        if(data.all == true) then
                            v.accepted = true  
                            payBook(v)           
                        else
                            if(v.identifier == data.identifier) then
                                v.accepted = true     
                                payBook(v)         
                            end
                        end
                    end
                    exports["oxmysql"]:execute('UPDATE salon SET booksList = @data WHERE id = 1', {['@data'] = json.encode(booksList)}, function(n)
                    end)
                end
        
            end)
        end
        cb({})
    end)

    ESX.RegisterServerCallback('SaloonS:declineBook', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local booksList = json.decode(result[1].booksList)
                        for k,v in ipairs(booksList) do
                            if(data.all == true) then
                                v.accepted = false             
                            else
                                if(v.identifier == data.identifier) then
                                    v.accepted = false              
                                end
                            end
                        end
                    exports["oxmysql"]:execute('UPDATE salon SET booksList = @data WHERE id = 1', {['@data'] = json.encode(booksList)}, function(n)
                    end)
                end
        
            end)
        end
        cb({})
    end)

    ESX.RegisterServerCallback('SaloonS:SubmitBook', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                local booksList = json.decode(result[1].booksList)
                for k,v in ipairs(booksList) do
                    if(v.identifier == license) then
                        if(v.accepted == 'none') then
                            return cb({error = 'Already have a pending appointment'})   
                        end                 
                    end
                end

                data.identifier = license
                data.accepted = 'none'
                data.name = xPlayer.getName()
                table.insert(booksList , data)
                exports["oxmysql"]:execute('UPDATE salon SET booksList = @job WHERE id = 1', {['@job'] = json.encode(booksList)}, function(n)
                end)
                cb({})

            end
        end)
    end)

    ESX.RegisterServerCallback('SaloonS:checkAppointment', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
            if(result[1] == nil) then
                return print('[Salon] Please insert the db file')
            else
                local booksList = json.decode(result[1].booksList)
                for k,v in ipairs(booksList) do
                    if(v.identifier == license) then
                        local status =''
                        if(v.accepted == true) then
                            status = "Is <span style='color: green'>Accepted</span>"
                        elseif(v.accepted == false) then
                            status = "Got <span style='color: red'>Declined</span>"
                        else
                            status = "Is <span style='color: yellow'>Pending</span>"
                        end

                        if(v.accepted == false) then
                            table.remove(booksList , k)
                            exports["oxmysql"]:execute('UPDATE salon SET booksList = @job WHERE id = 1', {['@job'] = json.encode(booksList)}, function(n)
                            end)
                        end

                        return cb({error = 'Your Appointment '..status})                    
                    end
                end
                cb({error = "Couldn't find any appointment"})
            end
        end)
    end)

    ESX.RegisterServerCallback('SaloonS:checkJob' , function(source , cb , getped)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        if(checkJob(xPlayer) == true) then
            
            cb(true)
        end

    end)


    ESX.RegisterServerCallback('SaloonS:payAll', function(source, cb, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()

        if(checkJob(xPlayer , true) == true) then
            local addedP = 0

            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else
                    local bData = json.decode(result[1].businessData)

                    local businessMoney = bData[1]['businessEncomy'].businessMoney
                    if(businessMoney >= tonumber(amount) ) then
                        for k,v in pairs(bData[1].businessEmployees) do
                            local pLicense = v.cid
                            if(ESX.GetPlayerFromIdentifier(pLicense)) then
                                xPlayer = ESX.GetPlayerFromIdentifier(pLicense)
                                xPlayer.addAccountMoney('bank', tonumber(amount), "Salon Bonus")
                                addedP = addedP + 1
                                TriggerClientEvent('SalonS:SentNotification' , xPlayer.source , 'You have <span style="color: green">received</span> $<span style="color: green">'..amount..'</span>' , 5000)
                            else
                                exports["oxmysql"]:execute('SELECT * FROM users WHERE identifier = @id ', {['@id'] = pLicense}, function(res)
                                    if(res[1]) then
                                        local data = json.decode(res[1].accounts)
                                        data['bank'] = data['bank'] + tonumber(amount)
                                        exports["oxmysql"]:execute('UPDATE users SET accounts = @data WHERE identifier = @id ', {['@id'] = pLicense , ['@data'] = json.encode(data)}, function(d)
                                        end)
                                        addedP = addedP + 1
                                    end
                                end)
                            end
                            
                        end
                    end
                    return cb({error = '<span style="color: green">Successfully</span> Paid $<span style="color: green">'..amount..'</span> to '..addedP..' employees!'})                    
                end
            end)
        end
    end)

       
    ESX.RegisterServerCallback('SaloonS:saveSkin', function(source, cb, selectedChair,type , currentHair , currentHairColor , id)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()
        
       local targetPlayer = Chairs[selectedChair].user
       local targetUser = ESX.GetPlayerFromId(targetPlayer)
       local targetIdentifier = targetUser.getIdentifier()


 

        exports["oxmysql"]:execute('SELECT * FROM users WHERE identifier = ?', { targetIdentifier } , function(result)
            if result[1] ~= nil then
                skin = json.decode(result[1].skin)
            end

            if(type == 'Hair') then
                skin['hair_1'] = currentHair
                skin['hair_color_1'] = currentHairColor
                skin['hair_color_2'] = currentHairColor

            end 

            if(type == 'Nails') then

                local f1
                if(id == 1) then
                    f1 = 'mask'
                end

                if(id == 7) then
                    f1 = 'bracelets'
                end

                if(id ==  3) then
                    f1 = 'torso'
                end

           
                skin[f1..'_1'] = currentHair
                skin[f1..'_2'] = currentHairColor
            end 
            exports["oxmysql"]:execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
                ['@skin'] = json.encode(skin),
                ['@identifier'] = targetIdentifier
            })
        end)
     
    end)

    
    ESX.RegisterServerCallback('SaloonS:getBusinessData', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local license = xPlayer.getIdentifier()

        if(checkJob(xPlayer , true) == true) then
            exports["oxmysql"]:execute('SELECT * FROM salon', {}, function(result)
                if(result[1] == nil) then
                    return print('[Salon] Please insert the db file')
                else

            
                    local bData = json.decode(result[1].businessData)
                    if(os.date('%w') == 0) then 
                        bData[1].businessEncomy.checkedIn = 0 
                        bData[1].businessEncomy.businessWeekMade = 0 
                        bData[1].businessEncomy.businessSales = 0 

                    end
                    if(#bData == 0) then
                        bData = {}
                        bData['businessEncomy'] = {
                            businessSales = 0,
                            businessMade = 0,
                            businessWeekMade = 0,
                            businessMoney = 0,
                            businessEngagment = 0,
                            checkedIn = 0,
                            salesGraph = {January = 0 , February = 0 , March = 0 , April = 0 , May = 0 , June = 0 , July = 0 ,August = 0, September = 0 , October = 0, November = 0 , December = 0  },
                        }
            
                        bData['businessEmployees'] = {
                            {name = xPlayer.getName() , cid = license , gradeName = xPlayer.getJob().grade_name , gradeNumber = xPlayer.getJob().grade , payment = xPlayer.getJob().grade_salary}
                        }
                        bData['JobApplications'] = {}
                        exports["oxmysql"]:execute('UPDATE salon SET businessData = @data WHERE id = 1', {['@data'] = json.encode({bData})}, function(n)
                        
                        end)
                        bData['Targets'] = Config.BusinessTargets
                        cb(bData)
                    else
                        bData[1]['Targets'] = Config.BusinessTargets
                        cb(bData[1])
                    end
                end
            end)
        end
    end)
end