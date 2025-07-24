# tileBroken Workaround

A library mod that allows modders to use the `tileBroken` and `tileEntityBroken` entity message handlers without interfering with each other or with vanilla.

## What's special about these handlers?

When a player breaks a tile or a tile entity, the engine sends one of two messages to the player that broke it. These messages have names `tileBroken` and `tileEntityBroken` respectively. They are the only ways to detect when any tile or tile entity is broken without resorting to repeated calls to `world.material()` and other similar functions.

## Why use this?

In an otherwise normal client / server, modders can *try* to use the `tileBroken` and `tileEntityBroken` handlers in generic script contexts. The problem with this approach, however, becomes apparent when one considers the following example:

`/scripts/player/example.lua`
```lua
function init()
  message.setHandler("tileBroken", function()
    sb.logInfo("Blah")
  end)
end
```

`/player.config.patch`
```json
[
  {
    "op" : "add",
    "path" : "/genericScriptContexts/example",
    "value" : "/scripts/player/example.lua"
  }
]
```

It should be noted that vanilla Starbound also uses these handlers in `/scripts/player/stealing.lua`. Due to how entity message handling works, only one of these two scripts will actually receive the message.

This mod works around that issue by making the `stealing.lua` script send extra messages to the player (courtesy of patman for providing the basis for this workaround and for helping with it).

I very strongly recommend to every modder who wants to set a `tileBroken` or `tileEntityBroken` handler: Please use this library mod instead. It will prevent any interference that may occur from using the former approach.

## How to use it

First, before you start using this mod, you need to install it. You can download and extract this code as a ZIP file or download the PAK file through the releases.

The second thing you need to do when using this is to add a patch to `/tbworkaround_relays.config`:
```json
[
  { "op" : "add", "path" : "/tileBroken/-", "value" : "example-tileBroken" },
  // OR
  { "op" : "add", "path" : "/tileEntityBroken/-", "value" : "example-tileEntityBroken" }
]
```

Then, where you would put a call of one of the two forms
```lua
message.setHandler("tileBroken", function() --[[...]] end)
-- OR
message.setHandler("tileEntityBroken", function() --[[...]] end)
```
put something like one of these instead:
```lua
message.setHandler("example-tileBroken", function() --[[...]] end)
-- OR
message.setHandler("example-tileEntityBroken", function() --[[...]] end)
```

That is all you have to do.