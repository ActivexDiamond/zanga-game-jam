--- Timer utilities.
--
-- This is a reworked implementation of the original signal module
-- from the hump library (https://github.com/vrld/hump).
-- See README.ACKNOWLEDGEMENT for detailed information.
--
-- It offers functionality to register for and publish signals.
-- Implements the Observer pattern.
--
-- @module gear.timer
-- @copyright 2010-2013 Matthias Richter
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Matthias Richter, Lorenzo Cogotti

local Signal = {}
Signal.__index = function(self, key)
    return Signal[key] or (function()
        local t = {}
        rawset(self, key, t)
        return t
    end)()
end

function Signal:register(s, f)
    self[s][f] = f
    return f
end

function Signal:emit(s, ...)
    for f in pairs(self[s]) do
        f(...)
    end
end

function Signal:remove(s, ...)
    local f = {...}
    for i = 1,select('#', ...) do
        self[s][f[i]] = nil
    end
end

function Signal:clear(...)
    local s = {...}
    for i = 1,select('#', ...) do
        self[s[i]] = {}
    end
end

function Signal:emitPattern(p, ...)
    for s in pairs(self) do
        if s:match(p) then self:emit(s, ...) end
    end
end

function Signal:registerPattern(p, f)
    for s in pairs(self) do
        if s:match(p) then self:register(s, f) end
    end
    return f
end

function Signal:removePattern(p, ...)
    for s in pairs(self) do
        if s:match(p) then self:remove(s, ...) end
    end
end

function Signal:clearPattern(p)
    for s in pairs(self) do
        if s:match(p) then self[s] = {} end
    end
end

-- instancing
function Signal.new()
    return setmetatable({}, Signal)
end

-- default instance
local default = Signal.new()

-- module forwards calls to default instance
local module = {}
for k in pairs(Signal) do
    if k ~= "__index" then
        module[k] = function(...) return default[k](default, ...) end
    end
end

return Signal
