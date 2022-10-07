-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

checkForRole = function(roleId)
    local hasPerms = lib.callback.await('wasabi_discord:checkForRole', 100, roleId)
    return hasPerms
end

exports('checkForRole', checkForRole)

getRoles = function()
    local roles = lib.callback.await('wasabi_discord:getRoles', 100)
    if roles then
        return roles
    else
        return false
    end
end

exports('checkForRole', checkForRole)