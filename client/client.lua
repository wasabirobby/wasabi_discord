-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

checkForRole = function(roleId)
    local hasPerms = lib.callback.await('ws_discord:checkForRole', 100, roleId)
    return hasPerms
end

exports('checkForRole', checkForRole)
