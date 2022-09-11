checkForRole = function(roleId)
    local hasPerms = lib.callback.await('ws_discordapi:checkForRole', 100, roleId)
    return hasPerms
end

exports('checkForRole', checkForRole)