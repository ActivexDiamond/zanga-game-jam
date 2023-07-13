--- Common functions for strings.
--
-- @module gear.strings
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local strings = {}

-- Platform preferred path separator
local SEP = package.config:sub(1,1)

--- Remove redundant slashes and resolve dot and dot-dots in path.
--
-- @string path a file path
-- @string[opt] sep separator pattern, '/' for Unix, '\\' for Windows (default)
-- @string[optchain] osep target separator pattern, '/' for Unix, '\\' for Windows, uses the platform preferred path separator by default.
-- @treturn string cleared path
function strings.clearpath(path, sep, osep)
    sep = sep or '\\' -- conservative, both / and \ as seps
    osep = osep or SEP

    local dot, dotdot, sepsub, esub
    if sep == '\\' then
        -- Windows style separator pattern
        dot, dotdot = '[\\/]+%.?[\\/]', '[^\\/]+[\\/]%.%.[\\/]?'
        sepsub, esub = '[\\/]', '[\\/]$'
    elseif sep == '/' then
        -- Unix like separators only
        dot, dotdot = '/+%.?/', '[^/]+/%.%./?'
        sepsub, esub = '/', '/$'
    else
        error("Unsupported separator pattern: "..tostring(sep))
    end
    if osep ~= '\\' and osep ~= '/' then
        error("Unsupported target separator pattern: "..tostring(osep))
    end

    local k

    repeat  -- /./ -> /
        path,k = path:gsub(dot, osep, 1)
    until k == 0

    repeat  -- A/../ -> (empty)
        path,k = path:gsub(dotdot, '', 1)
    until k == 0

    -- Make separators consistent
    path = path:gsub(sepsub, osep)
    path = path:gsub(esub, '')  -- never leave trailing separator
    return path == '' and '.' or path
end

--- Split path into components: directory, basename, extension.
--
-- @string path path to be split
-- @treturn string directory name (including separator), '' if none was found in path
-- @treturn string file name without extension, '' if none was found in path
-- @treturn string file extension including '.', '' if none was found in path
function strings.splitpath(path)
    return path:match("(.-)([^\\/]-)(%.?[^%.\\/]*)$")
end

--- Test whether a string starts with a prefix.
--
-- This is an optimized version of: return s:sub(1, #prefix) == prefix.
--
-- @string s string to be tested
-- @string prefix prefix to test for
-- @treturn bool true if prefix is found, false otherwise
function strings.startswith(s, prefix)
    for i = 1,#prefix do
        if s:byte(i) ~= prefix:byte(i) then
            return false
        end
    end
    return true
end

--- Test whether a string ends with a trailing suffix.
--
-- This is an optimized version of: return trailing == ""
-- or s:sub(-#trailing) == trailing.
--
-- @string s string to be tested
-- @string trailing suffix to test for
-- @treturn bool true if suffix is found, false otherwise
function strings.endswith(s, trailing)
    local n1,n2 = #s,#trailing

    for i = 0,n2-1 do
        if s:byte(n1-i) ~= trailing:byte(n2-i) then
            return false
        end
    end
    return true
end

return strings
