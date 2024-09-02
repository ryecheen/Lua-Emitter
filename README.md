<div align="center"><h1>Lua-Emitter</h1></div>

## _Constructor_
* `Emitter()`
* `Emitter.new()`

## _Method_

* `Emitter:eventNames()` : Return an array of events for which the emitter has 
    registered listeners.
```lua
---@return string[]
```

* `Emitter:listeners(event)` : Return the listeners registered for a given 
    event.
```lua
---@param  event string
---@return Listener[]
```

* `Emitter:listenerCount(event)` : Return the number of listeners listening to 
    a given event.
```lua
---@param  event string
---@return number
```

* `Emitter:removeListener(event, fn, n)` : Remove the listeners of a given 
    event that meet the condition.
```lua
---@param  event string
---@param  fn function|nil #Only remove the listeners that match this function.
---@param  n number|nil #Only remove the listeners that match the given `n`.
---@return Emitter
```

* `Emitter:emit(event, ...)` : Calls each of the listeners registered for a 
  given event.
```lua
---@param  event string
---@return boolean #Return `true` if the event had listeners, else `false`.
```

* `Emitter:on(event, fn, n)` : Add a listener for a given event. You can specify 
    `n` to determine how many times the listener will be triggered. By default, 
    it will be triggered indefinitely.
```lua
---@param  event string
---@param  fn function
---@param  n number|nil 
---@return Emitter
```

* `Emitter:once(event, fn)` : Shorthand for `Emitter:on(event, fn, 1)`

* `Emitter:addListener(event, fn, n)` : Alias for `Emitter:on(event, fn, n)`

* `Emitter:removeAllListeners()` : Remove all listeners. To remove listeners 
    for a specific event, use `Emitter:removeListener(event)` instead.

## _Example_
```lua
local Emitter = require("emitter")

Emi = Emitter()

Emi:on("test", function(n) print(n) end)
Emi:on("test", function(n) print(n) end, 2)
Emi:on("test", function(n) print(n) end, 10)
Emi:once("test", function(n) print(n) end)

for i = 1, 5 do Emi:emit("test", i) end

Emi:removeListener("test", nil, 5)

Emi:emit("test", 6)
```

