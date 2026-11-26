local QBCore = nil

if Config.UIVariant == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then
        print('^1[Error] ox_lib is selected in config but not started! Stopping resource...^7')
        StopResource(GetCurrentResourceName())
        return
    end
elseif Config.UIVariant == 'qb-core' then
    if GetResourceState('qb-core') ~= 'started' then
        print('^1[Error] qb-core is selected in config but not started! Stopping resource...^7')
        StopResource(GetCurrentResourceName())
        return
    end
end

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('^1[Error] qb-core is required for core logic! Stopping resource...^7')
    StopResource(GetCurrentResourceName())
    return
end

local PoliceStatuses = {}

QBCore.Functions.CreateCallback('dogukancim-policestatus:server:GetPoliceList', function(source, cb)
    local policeList = {}
    local players = QBCore.Functions.GetQBPlayers()
    
    for _, v in pairs(players) do
        if v.PlayerData.job.name == "police" then
            table.insert(policeList, {
                source = v.PlayerData.source,
                citizenid = v.PlayerData.citizenid,
                name = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                gradeLabel = v.PlayerData.job.grade.label,
                gradeLevel = v.PlayerData.job.grade.level,
                status = PoliceStatuses[v.PlayerData.citizenid] or 'available'
            })
        end
    end
    cb(policeList)
end)

RegisterNetEvent('dogukancim-policestatus:server:UpdateStatus', function(targetSrc, newStatus)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetSrc)

    if not Player or Player.PlayerData.job.name ~= "police" then return end
    if not TargetPlayer then return end

    if src ~= targetSrc then
        if not Config.AuthorizedGrades[Player.PlayerData.job.grade.level] then
            TriggerClientEvent('QBCore:Notify', src, _U('no_permission'), "error")
            return
        end
    end

    PoliceStatuses[TargetPlayer.PlayerData.citizenid] = newStatus
    
    local statusLabel = newStatus
    for _, s in ipairs(Config.Statuses) do
        if s.value == newStatus then
            statusLabel = s.label
            break
        end
    end

    Entity(GetPlayerPed(targetSrc)).state:set('policeStatus', newStatus, true)

    TriggerClientEvent('QBCore:Notify', src, _U('updated', TargetPlayer.PlayerData.charinfo.firstname.." "..TargetPlayer.PlayerData.charinfo.lastname, _U(statusLabel)), "info")
    
    if src ~= targetSrc then
        TriggerClientEvent('QBCore:Notify', targetSrc, _U('status_changed_by', Player.PlayerData.charinfo.lastname, _U(statusLabel)), "info")
    end
end)


local function StatusCount(status)
    local isEnabled = false
    for _, s in ipairs(Config.Statuses) do
        if s.value == status then
            if s.enabled then isEnabled = true end
            break
        end
    end
    if not isEnabled then return 0 end

    local count = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == "police" then
            local currentStatus = PoliceStatuses[v.PlayerData.citizenid] or 'available'
            if currentStatus == status then
                count = count + 1
            end
        end
    end
    return count
end

local function StatusNames(status)
    local isEnabled = false
    for _, s in ipairs(Config.Statuses) do
        if s.value == status then
            if s.enabled then isEnabled = true end
            break
        end
    end
    if not isEnabled then return {} end

    local names = {}
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == "police" then
            local currentStatus = PoliceStatuses[v.PlayerData.citizenid] or 'available'
            if currentStatus == status then
                table.insert(names, v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname)
            end
        end
    end
    return names
end

exports('StatusCount', StatusCount)
exports('StatusNames', StatusNames)

AddEventHandler('dogukancim-policestatus:server:StatusCount', function(status, cb)
    if cb then cb(StatusCount(status)) end
end)

AddEventHandler('dogukancim-policestatus:server:StatusNames', function(status, cb)
    if cb then cb(StatusNames(status)) end
end)
