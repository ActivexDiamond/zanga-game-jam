local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local Vector = require "libs.Vector"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Wizard = middleclass("Wizard", WorldObject)
function Wizard:initialize(scene, x, y)
	WorldObject.initialize(self, "wizard", scene, x, y)
end

------------------------------ Core API ------------------------------
function Wizard:update(dt)
	WorldObject.update(self, dt)
	local isDown = love.keyboard.isDown 

	local dirX, dirY = 0, 0
	if isDown('w') then dirY = dirY - 1 end
	if isDown('s') then dirY = dirY + 1 end
	if isDown('d') then dirX = dirX + 1 end
	if isDown('a') then dirX = dirX - 1 end
	self.velocity = Vector(dirX * self.speed, dirY * self.speed) 
end


function Wizard:draw(g2d)
	WorldObject.draw(self, g2d)
end

------------------------------ API ------------------------------


------------------------------ Getters / Setters ------------------------------

return Wizard