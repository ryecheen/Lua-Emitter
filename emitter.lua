---@class Emitter
---@field eventNames function
---@field listeners function
---@field listenerCount function
---@field removeListener function
---@field emit function
---@field on function
---@field once function
---@field addListener function
---@field removeAllListeners function

---@class Listener

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local clone, arrayRemove

function clone(any)
    local hasCloned = {}
    local function _clone(a)
        if type(a) ~= 'table' then return a end
        if hasCloned[a] then return hasCloned[a] end

        local _o = {}
        hasCloned[a] = _o
        for k, v in pairs(a) do _o[_clone(k)] = _clone(v) end
        return setmetatable(_o, getmetatable(a))
    end
    return _clone(any)
end

function arrayRemove(array, condition, ...)
    if type(condition) ~= "function" then
        local del = {}
        local arg = table.pack(condition, ...)
        for i = 1, arg.n do
            if arg[i] ~= nil then del[arg[i]] = true end
        end
        condition = function(_, i, _) return del[i] or false end
    end

    local newi = 1
    for i = 1, #array do
        if condition(array, i, newi) then
            array[i] = nil
        else
            if i ~= newi then array[newi], array[i] = array[i], nil end
            newi = newi + 1
        end
    end

    return array
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local Emitter
local addListener

function addListener(emitter, evt, fn, n)
    if emitter._e[evt] == nil then
        emitter._e[evt] = { fn = fn, n = n }
    elseif emitter._e[evt].fn then
        emitter._e[evt] = { emitter._e[evt], { fn = fn, n = n } }
    else
        emitter._e[evt][#emitter._e[evt] + 1] = { fn = fn, n = n }
    end
    return emitter
end

Emitter         = {}
Emitter.__index = {}

---@return Emitter
function Emitter.new() return setmetatable({ _e = {} }, Emitter) end

---@return string[]
function Emitter.__index:eventNames()
    local names = {}

    if next(self._e) == nil then return names end

    for name in pairs(self._e) do names[#names + 1] = name end

    return names
end

---@param  event string
---@return Listener[]
function Emitter.__index:listeners(event)
    if self._e[event] == nil then
        return {}
    elseif self._e[event].fn then
        return { clone(self._e[event]) }
    else
        return clone(self._e[event])
    end
end

---@param  event string
---@return number
function Emitter.__index:listenerCount(event)
    if self._e[event] == nil then
        return 0
    elseif self._e[event].fn then
        return 1
    else
        return #self._e[event]
    end
end

---@param  event string
---@param  fn function|nil #Only remove the listeners that match this function.
---@param  n number|nil #Only remove the listeners that match the given `n`.
---@return Emitter
function Emitter.__index:removeListener(event, fn, n)
    if self._e[event] == nil then return self end

    if fn == nil and n == nil then
        self._e[event] = nil
        return self
    end

    if self._e[event].fn then
        if (fn == nil or self._e[event].fn == fn) and
            (n == nil or self._e[event].n == n) then
            self._e[event] = nil
        end
    else
        arrayRemove(self._e[event], function(ar, i, j)
            return (fn == nil or ar[i].fn == fn) and (n == nil or ar[i].n == n)
        end)

        if #self._e[event] == 0 then
            self._e[event] = nil
        elseif #self._e[event] == 1 then
            self._e[event] = self._e[event][1]
        end
    end

    return self
end

---@param  event string
---@return boolean #Return `true` if the event had listeners, else `false`.
function Emitter.__index:emit(event, ...)
    if self._e[event] == nil then return false end

    if self._e[event].fn then
        self._e[event].fn(...)
        self._e[event].n = self._e[event].n - 1
    else
        for i = 1, #self._e[event] do
            self._e[event][i].fn(...)
            self._e[event][i].n = self._e[event][i].n - 1
        end
    end

    self:removeListener(event, nil, 0)
    return true
end

---@param  event string
---@param  fn function
---@param  n number|nil #How many times the listener will be triggered.
---@return Emitter
function Emitter.__index:on(event, fn, n)
    return addListener(self, event, fn, n or math.huge)
end

---@param  event string
---@param  fn function
---@return Emitter
function Emitter.__index:once(event, fn)
    return addListener(self, event, fn, 1)
end

---@param  event string
---@param  fn function
---@param  n number|nil #How many times the listener will be triggered.
---@return Emitter
function Emitter.__index:addListener(event, fn, n)
    return addListener(self, event, fn, n or math.huge)
end

---@return Emitter
function Emitter.__index:removeAllListeners()
    self._e = {}
    return self
end

return setmetatable(Emitter, {
    __call = function(self, ...) return self.new(...) end
})
