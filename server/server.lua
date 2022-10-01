-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

if Config.DiscordWhitelist.enabled then
    AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
        local whitelisted
        deferrals.defer()
        local roles = Config.DiscordWhitelist.whitelistedRoles
        for i=1, #roles do
            local hasRole = checkDiscordRole(source, roles[i])
            if hasRole then
                whitelisted = true
                break
            end
        end
        if whitelisted then
            deferrals.done()
        else
            deferrals.done(Config.DiscordWhitelist.deniedMessage)
        end
    end)
end
