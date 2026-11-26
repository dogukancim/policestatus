Config = {}

Config.Locale = 'en' -- 'tr', 'en'
Config.UIVariant = 'ox_lib' -- 'ox_lib', 'qb-core'
Config.CommandName = 'policelist'

-- Authorized grades that can change other players statuses
Config.AuthorizedGrades = {
    [4] = true,
    [5] = true  
}

Config.Statuses = {
    { label = 'available', value = 'available', icon = 'check', color = '#2ecc71', enabled = true },
    { label = 'busy', value = 'busy', icon = 'xmark', color = '#e74c3c', enabled = true },
    { label = 'enroute', value = 'enroute', icon = 'car', color = '#3498db', enabled = true },
}


-- Translation system - do not touch unless you know what you're doing
function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] not found'
    end
end
