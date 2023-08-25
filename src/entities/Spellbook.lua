local middleclass = require "libs.middleclass"
local Slab = require "libs.Slab"
local Vector = require "libs.Vector"

local Object = require "core.Object"

------------------------------ Helpers ------------------------------

------------------------------ Skills ------------------------------
local function dissipate(prj, other, info)
	prj:_remove()
end

local function destroy(prj, other, info)
	prj.scene:removeObject(other)
end

local function deflect(prj, other, info)
	local n = Vector(info.normal.x, info.normal.y).angle
	if info.normal.x == -1 then	
		prj.direction.angle = n - prj.direction.angle
	elseif info.normal.y == -1 then
		prj.direction.angle = n - prj.direction.angle + math.pi/2
	else	--If normal.x==1 or normal.y==1 
		prj.direction.angle = n + (n - prj.direction.angle) + math.pi
	end
end


local function slide(prj, other, info)

end

--The collision filter for each skill.
local SKILLS = {
	dissipate = dissipate,
	destroy = destroy,
	deflect = deflect,
}

local FILTERS = {
	[dissipate] = "touch",
	[destroy] = "cross",
	[deflect] = "slide",
	[slide] = "slide",
}

------------------------------ Constructor ------------------------------
local Spellbook = middleclass("Spellbook", Object)
function Spellbook:initialize()
	Object.initialize(self, "spellbook")

	self.winW = 300
	self.win = {
		id = 'win',
--		W = self.winW,
--		Title = "~ Book Of Shadows ~",
--		AutoSizeWindow = false,
--		AutoSizeWindowW = false,
--		AutoSizeWindowH = true
	}
	
	self.selectors = {}
end

------------------------------ Core API ------------------------------
function Spellbook:update(dt)
	Slab.BeginWindow(self.win.id, self.win)
	Slab.Text("\t\t\t\t\t\t~ Book Of Shadows ~")
	for id, name in pairs(self.tiles) do
		Slab.Text("On \t\t[" .. name .. "]\t\t")
		Slab.SameLine()
		
		Slab.Text(" do\t\t")
		Slab.SameLine()
		if id ~= "void_tile" then
			if not self.selectors[id] then 
				self.selectors[id] = self.skills[1]
			end
			self:_drawSkillSelector(id, name, self.skills)
		else
			Slab.Text("[dissipate]")
		end
	end
	Slab.EndWindow()
end

------------------------------ API ------------------------------
function Spellbook:updateState(fullReload)
	local level = GAME:getCurrentState().currentLevel
	self.tiles = level.uniqueTiles or {}
	self.skills = level.skills or {"dissipate"}
	
	if fullReload then self.selectors = {} end
	
	for id, name in pairs(self.tiles) do
		if id ~= "void_tile" and not self.selectors[id] then
			self.selectors[id] = self.skills[1]
		end
		if id == "void_tile" then
			self.selectors[id] = "dissipate"
		end
	end	

	local SW, SH = love.window.getMode()
--	self.win.X = SW / 2 - self.winW / 2
--	self.win.Y = SH / 2 - SH * 0.2
	self.win.X = GAME.GRID_SIZE * GAME.scale
	self.win.Y = GAME.GRID_SIZE * GAME.scale  
end

------------------------------ Internals ------------------------------
function Spellbook:_drawSkillSelector(id, name, skills)
	if Slab.BeginComboBox(id, {Selected = self.selectors[id]}) then
		for _, skill in ipairs(skills) do
			if Slab.TextSelectable(skill) then
				self.selectors[id] = skill
			end
		end
		Slab.EndComboBox()
	end

end

function Spellbook:_getProjectileOpt()
	local t = {
		speed = self.projectileSpeed,
		rules = {}
	}
	for id, name in pairs(self.tiles) do
		t.rules[id] = SKILLS[self.selectors[id]]
	end
	
	t.filters = {}
	for id, skill in pairs(t.rules) do
		t.filters[id] = FILTERS[skill]
	end
	
	return t	
end

------------------------------ Getters / Setters ------------------------------

return Spellbook