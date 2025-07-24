function init()
  local oldMessage = message
  message = setmetatable({}, {__index = oldMessage})  -- Extend oldMessage

  local relayInfo = root.assetJson("/tbworkaround_relays.config")

  -- Override message.setHandler.
  function message.setHandler(name, func)
    local playerId = player.id()
    oldMessage.setHandler(name, function(msgName, fromLocalEntity, ...)
      func(msgName, fromLocalEntity, ...)

      -- Send extra messages for each relay, if it exists.
      if relayInfo[name] then
        for _, relayName in ipairs(relayInfo[name]) do
          world.sendEntityMessage(playerId, relayName, ...)
        end
      end
    end)
  end

  -- Plug the old stealing script into this script.
  local script = root.assetJson("/player.config:tbworkaround_stealing_old")
  require(script)
  init()  -- Initialize the old stealing script.
end