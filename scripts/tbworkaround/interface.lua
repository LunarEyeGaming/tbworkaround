-- Initialize a globalized table in the string metatable containing some necessary information for this thing to work.
-- Modders should not attempt to access this table outside of this library mod.
local relayInfo = getmetatable''.__tbworkaround_relayInfo
if not relayInfo then
  -- relays is a map from the basic handler names to the names of the additional messages to relay.
  -- nextRelayIds is a map from a basic handler name to the next number to append for that handler when adding relays.
  relayInfo = {relays = {}, nextRelayIds = {}}
  getmetatable''.__tbworkaround_relayInfo = relayInfo
end

local msgRelayMap = {}  -- Map from given message name to actual message name.

tbWorkaround = {}

---Sets a handler for when a tile is broken by the player.
---@param func fun(messageName: string, fromLocalEntity: boolean, ...): any
---@return string
function tbWorkaround.onTileBroken(func)
  return tbWorkaround.setHandler("tileBroken", func)
end

---Sets a handler for when a tile entity is broken by the player.
---@param func fun(messageName: string, fromLocalEntity: boolean, ...): any
---@return string
function tbWorkaround.onTileEntityBroken(func)
  return tbWorkaround.setHandler("tileEntityBroken", func)
end

---Sets a message handler with the given name. Unlike standard handlers, this will only work with handlers that are
---defined in `/scripts/player/stealing.lua`.
---@param name string
---@param func fun(messageName: string, fromLocalEntity: boolean, ...): any
---@return string
function tbWorkaround.setHandler(name, func)
  if not relayInfo.relays[name] then
    relayInfo.relays[name] = {}
    relayInfo.nextRelayIds[name] = 0
  end

  local relayName
  -- If a message with that name has not been set already...
  if not msgRelayMap[name] then
    relayName = name .. relayInfo.nextRelayIds[name]
    relayInfo.nextRelayIds[name] = relayInfo.nextRelayIds[name] + 1  -- Increment ID
    -- Add relay message name.
    table.insert(relayInfo.relays[name], relayName)

    msgRelayMap[name] = relayName  -- Store
  else
    -- Set the relay name to override the previous handler.
    relayName = msgRelayMap[name]
  end

  -- Set the handler.
  message.setHandler(relayName, func)

  return relayName
end