--- General stateless utility algorithms
--
-- @module gear.algo
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local floor = math.floor
local min, max = math.min, math.max

local algo = {}


--- Clamp x within range [a,b] (where b >= a).
--
-- @number x value to clamp.
-- @number a interval lower bound (inclusive).
-- @number b interval upper bound (includive).
-- @treturn number clamped value.
function algo.clamp(x, a, b) return min(max(x, a), b) end

--- Fast remove from array.
--
-- Replace 'array[i]' with last array's element and
-- discard array's tail.
--
-- @tparam table array
-- @int i
function algo.removefast(array, i)
    local n = #array

    array[i] = array[n]  -- NOP if i == n
    array[n] = nil
end

local function lt(a, b) return a < b end

--- Sort array using Insertion Sort - O(n^2).
--
-- Provides the most basic sorting algorithm around.
-- Performs better than regular table.sort() for small arrays
-- (~100 elements).
--
-- @tparam table array array to be sorted.
-- @tparam[opt=operator <] function less comparison function, takes 2 arguments,
--                                  returns true if its first argument is
--                                  less than its second argument,
--                                  false otherwise.
function algo.insertionsort(array, less)
    less = less or lt

    for i = 2,#array do
        local val = array[i]
        local j = i

        while j > 1 and less(val, array[j-1]) do
            array[j] = array[j-1]
            j = j - 1
        end

        array[j] = val
    end
end

--- Binary search last element where
--  what <= array[i] - also known as lower bound.
--
-- @tparam table array an array sorted according to the less function.
-- @param what the comparison argument.
-- @tparam[opt=operator <] function less sorting criterium, a function taking 2 arguments,
--                                  returns true if the first argument
--                                  is less than the second argument,
--                                  false otherwise.
--
-- @treturn int the greatest index i, where what <= array[i].
--              If no such element exists, it returns an out of bounds index
--              such that array[i] == nil.
function algo.bsearchl(array, what, less)
    less = less or lt

    local lo, hi = 1, #array
    local ofs, mid = -1, hi

    while mid > 0 do
        mid = floor(hi / 2)

        -- array[lo+mid] <= what <-> what >= array[lo+mid]
        --                       <-> not what < array[lo+mid]
        if not less(what, array[lo+mid]) then
            lo = lo + mid
            ofs = 0  -- at least one element where array[lo+mid] <= what
        end

        hi = hi - mid
    end

    return lo + ofs
end

--- Binary search first element where
--  what >= array[i] - also known as upper bound.
--
-- @tparam table array an array sorted according to the less function.
-- @param what the comparison argument.
-- @tparam[opt=operator <] function less sorting criterium,
--                                  a function taking 2 arguments,
--                                  returns true if the first argument
--                                  is less than the second argument,
--                                  false otherwise.
--
-- @treturn int the smallest index i, where what >= array[i].
--              If no such element exists, it returns an out of bounds index
--              such that array[i] == nil.
function algo.bsearchr(array, what, less)
    less = less or lt

    local lo, hi = 1, #array
    local ofs, mid = -1, hi

    while mid > 0 do
        mid = floor(hi / 2)

        -- array[lo+mid] >= what <-> not array[lo+mid] < what
        if not less(array[lo+mid], what) then
            ofs = 0
        else
            lo = lo + mid
            ofs = 1
        end

        hi = hi - mid
    end

    return lo + ofs
end

return algo
