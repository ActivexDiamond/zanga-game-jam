--- Vector algebra.
--
-- Functions implementing basic 2D and 3D vector algebra.
-- Code is reasonably optimized for speed.
--
-- @module gear.vec
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local min, max = math.min, math.max
local sin, cos = math.sin, math.cos
local abs = math.abs
local sqrt = math.sqrt

local vec = {}


--- Vector dot product.
function vec.dot(x1,y1, x2,y2)
    return x1*x2 + y1*y2
end

--- vec.dot() equivalent for 3D vector.
function vec.dot3(x1,y1,z1, x2,y2,z2)
    return x1*x2 + y1*y2 + z1*z2
end

--- Vector cross product.
function vec.cross(x1,y1,z1, x2,y2,z2)
    return y1*z2 - z1*y2,
           z1*x2 - x1*z2,
           x1*y2 - y1*x2
end

--- Vector squared length.
function vec.sqrlen(x,y)
    return x*x + y*y  -- vec.dot(x,y, x,y)
end

--- vec.sqrlen() equivalent for 3D vectors.
function vec.sqrlen3(x,y,z)
    return x*x + y*y + z*z
end

--- Vector length.
function vec.len(x,y)
    return sqrt(x*x + y*y)  -- sqrt(vec.sqrlen(x,y))
end

--- vec.len() equivalent for 3D vectors.
function vec.len3(x,y,z)
    return sqrt(x*x + y*y + z*z)
end

--- Vector addition.
function vec.add(x1,y1, x2,y2)
    return x1+x2, y1+y2
end

--- vec.add() equivalent for 3D vectors.
function vec.add3(x1,y1,z1, x2,y2,z2)
    return x1+x2, y1+y2, z1+z2
end

--- Vector subtraction.
function vec.sub(x1,y1, x2,y2)
    return x1-x2, y1-y2
end

--- vec.sub() equivalent for 3D vectors.
function vec.sub3(x1,y1,z1, x2,y2,z2)
    return x1-x2, y1-y2, z1-z2
end

--- Vector scale.
function vec.scale(x,y, s)
    return x*s, y*s
end

--- vec.scale() equivalent for 3D vectors.
function vec.scale3(x,y,z, s)
    return x*s, y*s, z*s
end

--- Vector division by scalar.
function vec.div(x,y, s)
    return x/s, y/s
end

--- vec.div() equivalent for 3D vectors.
function vec.div3(x,y,z, s)
    return x/s, y/s, z/s
end

--- Vector multiply add.
--
-- @return the first vector, added to the second vector scaled by a factor.
function vec.madd(x1,y1, s, x2,y2)
    return x1 + x2*s, y1 + y2*s
end

--- vec.madd() equivalent for 3D vectors.
function vec.madd3(x1,y1,z1, s, x2,y2,z2)
    return x1 + x2*s, y1 + y2*s, z1 + z2*s
end

--- Test vectors for equality with optional epsilon.
function vec.eq(x1,y1, x2,y2, eps)
    eps = eps or 0.001

    return abs(x1-x2) < eps and abs(y1-y2) < eps
end

--- vec.eq() equivalent for 3D vectors.
function vec.eq3(x1,y1,z1, x2,y2,z2, eps)
    eps = eps or 0.001

    return abs(x1-x2) < eps and
           abs(y1-y2) < eps and
           abs(z1-z2) < eps
end

--- Normalize vector.
--
-- @return (x,y, len) normalized components and vector's original length.
function vec.normalize(x,y)
    local len = sqrt(x*x + y*y)  -- vec.len(x,y)

    if len < 1.0e-4 then
        return x,y, 0
    end

    return x / len, y / len, len
end

--- vec.normalize() equivalent for 3D vectors.
function vec.normalize3(x,y,z)
    local len = sqrt(x*x + y*y + z*z)

    if len < 1.0e-4 then
        return x,y,z, 0
    end

    return x / len, y / len, z / len, len
end

--- Calculate the squared distance between two vectors/points.
function vec.sqrdist(x1,y1, x2,y2)
    local dx,dy = x2-x1, y2-y1

    return dx*dx, dy*dy  -- vec.sqrlen(dx,dy)
end

--- vec.sqrdist() equivalent for 3D vectors.
function vec.sqrdist3(x1,y1,z1, x2,y2,z2)
    local dx,dy,dz = x2-x1, y2-y1, z2-z1

    return dx*dx, dy*dy, dz*dz
end

--- Calculate the distance between two vectors/points.
function vec.dist(x1,y1, x2,y2)
    local dx,dy = x2-x1, y2-y1

    return sqrt(dx*dx + dy*dy)  -- sqrt(vec.sqrdist(x1,y1, x2,y2))
end

--- vec.dist() equivalent for 3D vectors/points.
function vec.dist3(x1,y1,z1, x2,y2,z2)
    local dx,dy,dz = x2-x1, y2-y1, z2-z1

    return sqrt(dx*dx + dy*dy + dz*dz)
end

--- Rotate point (px,py) around (ox,oy) by the provided
--  sine and cosine.
--
--  This function should only be used for (valuable)
--  optimization purposes.
function vec.rotatesincos(px,py, sina,cosa, ox,oy)
    return ox + cosa*px - sina*py,
           oy + sina*px + cosa*py
end

--- Rotate point (px,py) around (ox,oy) about rot radians.
function vec.rotatepoint(px,py, rot, ox,oy)
    ox = ox or 0
    oy = oy or 0

    local sina,cosa = sin(rot),cos(rot)

    -- vec.rotatesincos(px,py, sina,cosa, ox,oy)
    return ox + cosa*px - sina*py,
           oy + sina*px + cosa*py
end

--- Transform world coordinates to screen coordinates.
--
-- @param x (number) World coordinate X.
-- @param y (number) World coordinate Y.
-- @param vx (number|nil) Point of view X coordinate, defaults to w/2.
-- @param vy (number|nil) Point of view Y coordinate, defaults to h/2.
-- @param rot (number|nil) View rotation in radians, defaults to 0.
-- @param scale (number|nil) View scale (zoom), defaults to 1.
-- @param left (number|nil) Viewport left corner, defaults to 0.
-- @param top (number|nil) Viewport top corner, defaults to 0.
-- @param w (number|nil) Viewport width, defaults to love.graphics.getWidth().
-- @param h (number|nil) Viewport height, defaults to love.graphics.getHeight().
--
-- @return (x,y) Transformed to screen coordinates according to
--         viewport and offset.
function vec.toscreencoords(x,y, vx,vy, rot, scale, left,top, w,h)
    left,top = left or 0, top or 0
    w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    local halfw,halfh = w/2, h/2

    vx,vy = vx or halfw, vy or halfh
    rot = rot or 0
    scale = scale or 1

    local sina,cosa = sin(rot),cos(rot)

    x,y = x - vx, y - vy
    x,y = cosa*x - sina*y, sina*x + cosa*y
    return x*scale + halfw + left, y*scale + halfh + top
end

--- Transform screen coordinates to world coordinates.
--
-- @param x (number) Screen coordinate X.
-- @param y (number) Screen coordinate Y.
-- @param vx (number|nil) Point of view X coordinate, defaults to w/2.
-- @param vy (number|nil) Point of view Y coordinate, defaults to h/2.
-- @param rot (number|nil) View rotation in radians, defaults to 0.
-- @param scale (number|nil) View scale (zoom), defaults to 1.
-- @param left (number|nil) Viewport left corner, defaults to 0.
-- @param top (number|nil) Viewport top corner, defaults to 0.
-- @param w (number|nil) Viewport width, defaults to love.graphics.getWidth().
-- @param h (number|nil) Viewport height, defaults to love.graphics.getHeight().
--
-- @return (x,y) Transformed to world coordinates according to
--         viewport and offset.
function vec.toworldcoords(x,y, vx,vy, rot, scale, left,top,w,h)
    left, top = left or 0, top or 0
    w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    local halfw,halfh = w/2, h/2

    vx,vy = vx or halfw, vy or halfh
    rot = rot or 0
    scale = scale or 1

    local sina,cosa = sin(-rot),cos(-rot)

    x,y = (x - halfw - left) / scale, (y - halfh - top) / scale
    x,y = cosa*x - sina*y, sina*x + cosa*y
    return x+vx, y+vy
end

return vec
