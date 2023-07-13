local middleclass = require "libs.middleclass"
local utils = require "libs.utils"

------------------------------ Helpers ------------------------------
local function inputData(self, t)
	local id = table.remove(t, 1)
	self.data[id] = {}
	for k, v in pairs(t) do
		self.data[id][k] = v
	end
end

------------------------------ Constructor ------------------------------
local DataRegistry = middleclass("DataRegistry")
function DataRegistry:initialize()
	self.data = {}
	
	---load data
	self.datapackDirs = [[
		datapack
	]]
end

------------------------------ Core API ------------------------------
function DataRegistry:loadData()
	local dirs = self:_cleanDirs(self.datapackDirs)
	_G.data = function(t) inputData(self, t) end 
	for _, dir in ipairs(dirs) do
		local files = utils.listFiles(dir)
		for _, file in ipairs(files) do love.filesystem.load(file)() end
	end
	_G.data = nil	
	self.loaded = true
end

---API
function DataRegistry:applyStats(obj)
	if not self.loaded then error "The Registry must be loaded first." end
	local data = self.data[obj.ID]
--		print('applying to item:' , obj.ID, data)
	if data then
		for k, v in pairs(data) do
			obj[k] = v
--				print("applied:", k, v)
		end
	end
end

------------------------------ Internals ------------------------------
function DataRegistry:_cleanDirs(dirs)
	dirs = utils.str.rem(dirs, "%s")			--remove spaces
	dirs = utils.str.rem(dirs, "\t")			--remove tabs
	return utils.str.sep(dirs, '\n')			--cut into arr
end

return DataRegistry()