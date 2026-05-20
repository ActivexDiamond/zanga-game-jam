local middleclass = require "libs.middleclass"
local Object = require "core.Object"

local Vector = require "libs.Vector"

local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"

local Projectile = require "entities.Projectile"

------------------------------ Constructor ------------------------------
local SignManager = middleclass("SignManager", Object)
function SignManager:initialize(scene, signs)
	Object.initialize(self, "sign_manager")
	self.scene = scene
	self.signs = signs or {}
	print("Spawned sign manager with " .. #self.signs .. " signs for this level.")
end

------------------------------ Core API ------------------------------
function SignManager:draw(g2d)
	for _, text in ipairs(self.signs) do
		local x, y = text[1] * GAME.GRID_SIZE, text[2] * GAME.GRID_SIZE
		g2d.print(text[3], x, y)
	end
end

------------------------------ Getters / Setters ------------------------------

return SignManager