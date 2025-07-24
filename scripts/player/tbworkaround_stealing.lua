-- Initialize a globalized table in the string metatable containing some necessary information for this thing to work.
-- Modders should not attempt to access this table outside of this library mod.
local relayInfo = getmetatable''.__tbworkaround_relayInfo
if not relayInfo then
  -- relays is a map from the basic handler names to the names of the additional messages to relay.
  -- nextRelayIds is a map from a basic handler name to the next number to append for that handler when adding relays.
  relayInfo = {relays = {}, nextRelayIds = {}}
  getmetatable''.__tbworkaround_relayInfo = relayInfo
end

function init()
  local oldMessage = message
  message = setmetatable({}, {__index = oldMessage})  -- Extend oldMessage

  -- Override message.setHandler.
  function message.setHandler(name, func)
    local playerId = player.id()
    oldMessage.setHandler(name, function(msgName, fromLocalEntity, ...)
      func(msgName, fromLocalEntity, ...)

      -- Send extra messages for each relay, if it exists.
      if relayInfo.relays[name] then
        for _, relayName in ipairs(relayInfo.relays[name]) do
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