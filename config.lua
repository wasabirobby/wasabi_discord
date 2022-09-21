-----------------For support, scripts, and more----------------
----------------- https://discord.gg/XJFNyMy3Bv ---------------
---------------------------------------------------------------
Config = {}

Config.DiscordInfo = {
    botToken = 'DISCORD_BOT_TOKEN', -- Your Discord bot token here
    guildID = 'DISCORD_GUID_ID', -- Your Discord's server ID here(Aka Guild ID)
}

Config.DiscordWhitelist = { -- Restrict if someone can fly in if they lack specific Discord role(s)
    enabled = false, -- Enable?
    deniedMessage = 'https://discord.gg/jsd : Join our Discord server and verify to play!', -- Message for those who lack whitelisted role(s)
    whitelistedRoles = {
      --'ROLE_ID_HERE',  
        '835370971501297706', -- Maybe like a civilian role or whitelisted role(can add multiple to table)
    }
}
