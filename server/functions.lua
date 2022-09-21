-----------------For support, scripts, and more----------------
----------------- https://discord.gg/XJFNyMy3Bv ---------------
---------------------------------------------------------------

local fToken = 'Bot '..Config.DiscordInfo.botToken

discordRequest = function(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = fToken})
    while data == nil do
        Wait(0)
    end
    return data
end

checkDiscordRole = function(servId, role)
    local discId = nil
    for _,v in ipairs(GetPlayerIdentifiers(servId)) do
        if string.match(v, 'discord:') then
            discId = string.gsub(v, 'discord:', '')
            break
        end
    end
    local discRole = nil
    if type(role) == 'number' then
        discRole = tostring(role)
    end
    if discId then
        local endpoint = ('guilds/%s/members/%s'):format(Config.DiscordInfo.serverId, discId)
        local member = discordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            local found = true
            for i=1, #roles do
                if roles[i] == discRole then
                    return true
                end
            end
            return false
        else
            return false
        end
    else
        return false
    end
end

lib.callback.register('ws_discord:checkForRole', function(source, role)
    local hasRole = checkDiscordRole(source, role)
    return hasRole
end)
