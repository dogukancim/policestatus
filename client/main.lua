local QBCore = nil

if Config.UIVariant == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then
        print('^1[Error] ox_lib is selected in config but not started! Returning...^7')
        return
    end
elseif Config.UIVariant == 'qb-core' then
    if GetResourceState('qb-core') ~= 'started' then
        print('^1[Error] qb-core is selected in config but not started! Returning...^7')
        return
    end
end

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('^1[Error] qb-core is required for core logic! Returning...^7')
    return
end

local function OpenStatusSelection(targetData)
    if Config.UIVariant == 'ox_lib' then
        local options = {}
        for _, status in ipairs(Config.Statuses) do
            if status.enabled then
                table.insert(options, {
                    title = _U(status.label),
                    icon = status.icon,
                    onSelect = function()
                        TriggerServerEvent('dogukancim-policestatus:server:UpdateStatus', targetData.source, status.value)
                    end
                })
            end
        end

        lib.registerContext({
            id = 'police_status_selection',
            title = _U('status_selection_title', targetData.name),
            menu = 'police_personnel_list',
            options = options
        })
        lib.showContext('police_status_selection')

    elseif Config.UIVariant == 'qb-core' then
        local menu = {
            {
                header = _U('go_back'),
                params = {
                    event = "dogukancim-policestatus:client:OpenMenu"
                }
            },
            {
                header = _U('status_selection_for', targetData.name),
                isMenuHeader = true
            }
        }
        for _, status in ipairs(Config.Statuses) do
            if status.enabled then
                table.insert(menu, {
                    header = _U(status.label),
                    params = {
                        event = "dogukancim-policestatus:client:SetTargetStatus",
                        args = {
                            targetSrc = targetData.source,
                            status = status.value
                        }
                    }
                })
            end
        end
        exports['qb-menu']:openMenu(menu)
    end
end

local function OpenPersonnelMenu()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name ~= "police" then 
        QBCore.Functions.Notify(_U('not_police'), "error")
        return 
    end

    QBCore.Functions.TriggerCallback('dogukancim-policestatus:server:GetPoliceList', function(policeList)
        if Config.UIVariant == 'ox_lib' then
            local options = {}
            for _, v in ipairs(policeList) do
                local isSelf = (v.source == GetPlayerServerId(PlayerId()))
                local canEdit = isSelf or Config.AuthorizedGrades[PlayerData.job.grade.level]
                
                local currentStatusLabel = _U('unknown')
                for _, s in ipairs(Config.Statuses) do
                    if s.value == v.status then currentStatusLabel = _U(s.label) break end
                end

                table.insert(options, {
                    title = v.name,
                    description = string.format("%s: %s", _U('status'), currentStatusLabel),
                    disabled = not canEdit,
                    arrow = canEdit,
                    onSelect = function()
                        OpenStatusSelection(v)
                    end
                })
            end

            lib.registerContext({
                id = 'police_personnel_list',
                title = _U('menu_title'),
                options = options
            })
            lib.showContext('police_personnel_list')

        elseif Config.UIVariant == 'qb-core' then
            local menu = {
                {
                    header = _U('menu_title'),
                    isMenuHeader = true
                }
            }
            for _, v in ipairs(policeList) do
                local isSelf = (v.source == GetPlayerServerId(PlayerId()))
                local canEdit = isSelf or Config.AuthorizedGrades[PlayerData.job.grade.level]
                
                local currentStatusLabel = _U('unknown')
                for _, s in ipairs(Config.Statuses) do
                    if s.value == v.status then currentStatusLabel = _U(s.label) break end
                end

                table.insert(menu, {
                    header = v.name,
                    txt = string.format("%s: %s", _U('status'), currentStatusLabel),
                    disabled = not canEdit,
                    params = {
                        event = "dogukancim-policestatus:client:OpenStatusSelection",
                        args = {
                            targetData = v
                        }
                    }
                })
            end
            exports['qb-menu']:openMenu(menu)
        end
    end)
end

RegisterNetEvent('dogukancim-policestatus:client:OpenMenu', function()
    OpenPersonnelMenu()
end)

exports('OpenMenu', function()
    OpenPersonnelMenu()
end)

RegisterNetEvent('dogukancim-policestatus:client:OpenStatusSelection', function(data)
    OpenStatusSelection(data.targetData)
end)

RegisterNetEvent('dogukancim-policestatus:client:SetTargetStatus', function(data)
    TriggerServerEvent('dogukancim-policestatus:server:UpdateStatus', data.targetSrc, data.status)
end)

if Config.CommandName and Config.CommandName ~= "" then
    RegisterCommand(Config.CommandName, function()
        OpenPersonnelMenu()
    end, false)
end
