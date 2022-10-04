-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local fToken = 'Bot '..Config.DiscordInfo.botToken
players, connectInfo = {}, {}
local pCard = json.decode(LoadResourceFile(GetCurrentResourceName(), 'adaptiveCard.json'))

if Config.DiscordWhitelist.enabled then
    AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
        local whitelisted
        deferrals.defer()
        local roles = Config.DiscordWhitelist.whitelistedRoles
        for i=1, #roles do
            local hasRole = checkRole(source, roles[i])
            if hasRole then
                whitelisted = true
                break
            end
        end
        if whitelisted then
            deferrals.done()
        else
            setKickReason(Config.DiscordWhitelist.deniedMessage)
        end
    end)
end

if Config.DiscordQueue.enabled then
    StopResource('hardcap')
    AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
        local _source = source
        local discordId
        deferrals.defer()
        Wait(100)
        deferrals.update(Config.DiscordQueue.strings.verifyConnection)
        Wait(250)
        for k,v in ipairs(GetPlayerIdentifiers(_source)) do
            if string.sub(v, 1, string.len('discord:')) == 'discord:' then
                discordId = v
            end
        end
        if not discordId then
            deferrals.done(Config.DiscordQueue.strings.noDiscord)
            return
        end
        if not processQueue(discordId, deferrals, _source) then
            CancelEvent()
        end
    end)

    AddEventHandler('playerDropped', function(reason)
        removeFromQueue(GetPlayerIdentifier(_source, 3))
    end)

    RegisterServerEvent('wasabi_discord:removeFromQueue')
    AddEventHandler('wasabi_discord:removeFromQueue', function()
        for k, v in pairs(connectInfo) do
            if v.discordId == GetPlayerIdentifier(source, 3) then
                table.remove(connectInfo, k)
            end
        end
    end)
end

lib.callback.register('wasabi_discord:getConfig', function(source)
    local cConfig = copyTable(Config)
    cConfig.DiscordInfo = nil 
    return cConfig
end)

lib.callback.register('wasabi_discord:checkForRole', function(source, role)
    local hasRole = checkRole(source, role)
    return hasRole
end)

lib.callback.register('wasabi_discord:getRoles', function(source, role)
    local roles = getRoles(source)
    return roles
end)

-- Functions

function copyTable(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copyTable(k, s)] = copyTable(v, s) end
    return res
end

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

if Config.DiscordQueue.enabled then
    processQueue = function(discordId, deferrals, serverId)
        local data = {name = nil, pts = 0}
        local endpoint = ('guilds/%s/members/%s'):format(Config.DiscordInfo.guildID, string.gsub(discordId, 'discord:', ''))
        local memberRaw = discordRequest("GET", endpoint, {})
        local roleNames, firstRole = '', false
        local member = json.decode(memberRaw.data)
        if not member.roles then
            deferrals.setKickReason(Config.DiscordQueue.strings.notInDiscord)
            return
        end
        for k,v in ipairs(member.roles) do
            for i=1, #Config.DiscordQueue.roles do
                if v == Config.DiscordQueue.roles[i].roleId then
                    data.pts = data.pts + Config.DiscordQueue.roles[i].points
                    if not firstRole then
                        roleNames = Config.DiscordQueue.roles[i].name
                        firstRole = true
                    else
                        roleNames = roleNames..' & '..Config.DiscordQueue.roles[i].name
                    end
                end
            end
        end
        local discName, discDec
        for k,v in pairs(member.user) do
            if k == 'username' then
                discName = v
            elseif k == 'discriminator' then
                discDec = tostring(v)
            end
        end
        data.name = discName..'#'..tostring(discDec)
        roleNames = roleNames ~= '' and roleNames or 'No Role'
        placeInQueue(discordId, data.name, data.pts, roleNames, serverId, deferrals)
        local stop = false
        repeat
            for k,v in pairs(connectInfo) do
                if v.discordId == discordId then
                    stop = true
                end
            end
            for k,v in ipairs(players) do
                if v.discordId == discordId and (GetPlayerPing(v.source) == 0) then
                    removeFromQueue(discordId)
                    deferrals.done(Config.DiscordQueue.strings.error)
                    return false
                end
            end
            local currentMessage = currentMsg()
            deferrals.presentCard(currentMessage, function(data, rawData) end)
            Wait(0)
        until stop
        deferrals.done()
        return true
    end

    checkQueue = function()
        for k,v in pairs(players) do 
            if GetPlayerPing(v.source) == 500 then 
                removeFromQueue(nil, k)
            end
        end
        for k,v in pairs(connectInfo) do 
            if GetPlayerPing(v.source) == -1 then 
                if v.errorNumber > 1 then 
                    table.remove(connectInfo, k)
                end
                v.errorNumber = v.errorNumber + 1
            end
        end
    end

    firstQueued = function()
        if #players == 0 then 
            return
        end
        table.insert(connectInfo, {discordId = players[1].discordId, source = players[1].source, errorNumber = 0})
        removeFromQueue(nil, nil, 1)
    end

    currentMsg = function()
        local message = ''
        local counter = 1
        local card = pCard
        for k,v in pairs(players) do 
            if counter < 10 then 
                message = message..'['..tostring(k)..'] '..v.name..' | '..v.roleNames..'\n'
                counter = counter + 1
            elseif counter == 10 then 
                message = message..(Config.DiscordQueue.overflowQueueText):format(#players - counter)
                counter = counter + 1
            end
        end
        card.body[1].text = Config.DiscordQueue.title 
        card.body[2].url = Config.DiscordQueue.image.link 
        card.body[2].width = Config.DiscordQueue.image.width 
        card.body[2].height = Config.DiscordQueue.image.height 
        card.body[3].items[1].text = Config.DiscordQueue.currentQueueText
        card.body[3].items[2].text = message
        card.body[4].text = (Config.DiscordQueue.currentSpotText):format(tostring(#players), #GetPlayers(), Config.DiscordQueue.maxConnections)
        card.body[5].text = Config.DiscordQueue.footerText
        card.body[6].actions[1].title = Config.DiscordQueue.buttons.button1.title
        card.body[6].actions[1].iconUrl = Config.DiscordQueue.buttons.button1.iconUrl 
        card.body[6].actions[1].url = Config.DiscordQueue.buttons.button1.url
        card.body[6].actions[2].title = Config.DiscordQueue.buttons.button2.title
        card.body[6].actions[2].iconUrl = Config.DiscordQueue.buttons.button2.iconUrl 
        card.body[6].actions[2].url = Config.DiscordQueue.buttons.button2.url
        return card
    end

    removeFromQueue = function(discId, count)
        if count then
            local queueCnt = #players 
            for current = count, queueCnt do
                players[current] = players[current + 1]
            end
        else
            for k,v in pairs(players) do 
                if v.discordId then 
                    local queueCnt = #players 
                    local saveCred = nil 
                    for current = k + 1, queueCnt do 
                        players[current - 1] = players[current]
                    end
                    players[queueCnt] = nil 
                    return 
                end
            end
        end
    end

    placeInQueue = function(discordId, name, pts, roleNames, source, deferrals)
        local _source = source
        if #players == 0 then
            players[1] = {
                discordId = discordId,
                name = name,
                points = pts,
                roleNames = roleNames,
                source = _source
            }
        else
            for k,v in pairs(players) do 
                if v.points < pts then 
                    local queueCnt = #players 
                    local saveCred = nil 
                    for current = k, queueCnt + 1 do 
                        if current == k then 
                            saveCred = players[current + 1]
                            players[current + 1] = players[current]
                        else
                            local currentCred = players[current + 1]
                            players[current + 1] = saveCred
                            saveCred = currentCred 
                        end
                    end

                    players[k] = {
                        discordId = discordId,
                        name = name,
                        points = pts,
                        roleNames = roleNames,
                        source = _source
                    }
                    return
                end
            end

            players[#players + 1] = {
                discordId = discordId,
                name = name,
                points = pts,
                roleNames = roleNames,
                source = _source
            }
        end
    end
end

checkRole = function(source, role)
    local _source = source
    local discId = nil
    for _,v in ipairs(GetPlayerIdentifiers(_source)) do
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
        local endpoint = ('guilds/%s/members/%s'):format(Config.DiscordInfo.guildID, discId)
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

exports('checkRole', checkRole)

getRoles = function(source)
    local _source = source
    local discId = nil
    for _,v in ipairs(GetPlayerIdentifiers(_source)) do
        if string.match(v, 'discord:') then
            discId = string.gsub(v, 'discord:', '')
            break
        end
    end
    local endpoint = ('guilds/%s/members/%s'):format(Config.DiscordInfo.guildID, discId)
    local member = discordRequest("GET", endpoint, {})
    if member.code == 200 then
        local data = json.decode(member.data)
        local roles = data.roles
        return roles
    else
        return false
    end
end

exports('getRoles', getRoles)

CreateThread(function()
    while true do 
        Wait(3000)
        checkQueue()
        if #players > 0 and #connectInfo + #GetPlayers() < Config.DiscordQueue.maxConnections then
            firstQueued()
        end
    end
end)
