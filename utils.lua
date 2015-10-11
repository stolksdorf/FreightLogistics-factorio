local config = require "config"
require "defines"

utils = {}




--Converts any type, including tables into a string
local AnyToString = function(arg)
	ToString = function(arg, depth)
		depth = depth or "  "
		local res=""
		if type(arg)=="table" then
			res="{"
			for k,v in pairs(arg) do
				res=res.. depth ..tostring(k).." = ".. ToString(v, depth .. "  ") ..","
			end
			res=res.."}"
		else
			res=tostring(arg)
		end
		return res
	end
	return ToString(arg, "  ")
end


utils.print = function(arg)
	return game.player.print(AnyToString(arg))
end
debug = function() end
if config.DEBUG then
	debug=utils.print
end



--[[ ENTITY UTILS ]]--

utils.createText = function(text, pos, colour)
	if colour == nil then
		game.createentity({name="flying-text", position=pos, text=text})
	else
		game.createentity({name="flying-text", position=pos, text=text, color=colour})
	end
end

utils.getArea = function(pos,size, direction)
	size = size or 1
	if direction == nil then
		return {{pos.x-size,pos.y-size},{pos.x+size,pos.y+size}}
	elseif direction == 0 then
		return {{pos.x,pos.y},{pos.x,pos.y+size}}
	elseif direction == 2 then
		return {{pos.x - size,pos.y},{pos.x,pos.y}}
	elseif direction == 4 then
		return {{pos.x,pos.y - size},{pos.x,pos.y}}
	elseif direction == 6 then
		return {{pos.x,pos.y},{pos.x + size,pos.y}}
	end
end

--Gets all entities around a given entity
utils.getNearbyEntities = function(entity, distance)
	distance = distance or 1
	return ipairs(entity.surface.find_entities(utils.getArea(entity.position, distance)))
end
utils.getEntitiesInFront = function(entity, distance)
	distance = distance or 1
	return ipairs(entity.surface.find_entities(utils.getArea(entity.position, distance, entity.direction)))
end

--Used in the prototype file to add a recipe to an existing tech
utils.addToExistingTech = function(data, techName, recipeName)
	table.insert(data.raw["technology"][techName].effects, {
		type = "unlock-recipe",
		recipe = recipeName
	})
end

--Set the circuit conditions with a table of tables
--signal keys to use: item, fluid, virtual
utils.setCircuitCondition = function(entity, signals)
	local condition = {parameters = {}}
	local i = 1
	for signalType, list in pairs(signals) do
		if type(list) == "table" then
			for name,count in pairs(list) do
				condition.parameters[i]={signal={type = signalType, name = name}, count = count, index = i}
				i = i + 1
			end
		end
	end
	entity.set_circuit_condition(1, condition)
	return entity
end

utils.isValid = function(entity)
	return (entity ~= nil and entity.valid)
end



--[[ TABLE UTILS ]]--

-- Incrementally adds an item to a table
utils.addTables = function(...)
	local res = {}
	for _,tab in ipairs({...}) do
		for k,v in pairs(tab) do
			if res[k] == nil then
				res[k] = 0
			end
			res[k] = res[k] + v
		end
	end
	return res
end

--Joins many tables together
utils.extendTables = function(...)
	local res = {}
	for _,tab in ipairs({...}) do
		for k,v in pairs(tab) do
			res[k] = v
		end
	end
	return res
end

-- Drops the keys and merges all the values into a new table
utils.mergeTables = function(...)
	local res = {}
	for _,tab in ipairs({...}) do
		for k,v in pairs(tab) do
			table.insert(res, v)
		end
	end
	return res
end




--[[ MOD MANAGEMENT ]]--

local function handleEntityBuilt(mod, event)
	if mod.blueprints[event.created_entity.name]~= nil then
		local tab = mod.entities[event.created_entity.name]
		local entityStorage = {}
		mod.blueprints[event.created_entity.name].onPlace(event.created_entity, entityStorage, event)
		table.insert(tab,{
			entity = event.created_entity,
			storage = entityStorage
		})
		mod.entities[event.created_entity.name] = tab
	end
	return mod
end

local function handleEntityRemoved(mod, event)
	if mod.blueprints[event.entity.name]~= nil then
		for index, obj in ipairs(mod.entities[event.entity.name]) do
			if obj.entity==event.entity then
				local tab = mod.entities[event.entity.name]
				table.remove(tab,index)
				mod.blueprints[event.entity.name].onDestroy(obj.entity, obj.storage, event)
				mod.entities[event.entity.name] = tab
				break
			end
		end
	end
	return mod
end

local function handleOnTick(mod, event)
	for name, blueprint in pairs(mod.blueprints) do
		local rate = 1
		if blueprint.updateRateBySecond~=nil then
			rate = blueprint.updateRateBySecond * 60
		end
		--Allow different entity blueprints to have different update rates
		if event.tick % rate == 0 then
			for index, obj in pairs(mod.entities[name]) do
				if obj.entity.valid then
					blueprint.onUpdate(obj.entity, obj.storage, event)
				end
			end
		end
	end
	return mod
end

local function handleOnLoad(mod)
	mod.entities = global[mod.key] or {}
	for name,blueprint in pairs(mod.blueprints) do
		mod.entities[name] = mod.entities[name] or {}
	end
	return mod
end


--TODO : Maybe Register GUIs, pass in the open Entity
-- add onClick handlers
--[[
local function handleGUIClick(mod, event)
	mod.entities = global[mod.key] or {}
	for name,blueprint in pairs(mod.blueprints) do
		mod.entities[name] = mod.entities[name] or {}
	end
	return mod
end
]]


function utils.addModToGame(mod, onTick)
	game.on_event(defines.events.on_tick,function(event)
		handleOnTick(mod, event)
		if onTick ~= nil then
			onTick(event)
		end
	end)
	game.on_init(function()
		mod = handleOnLoad(mod)
	end)
	game.on_load(function()
		mod = handleOnLoad(mod)
	end)
	game.on_save(function()
		global[mod.key] = mod.entities
	end)
	game.on_event(defines.events.on_built_entity,function(event)
		mod = handleEntityBuilt(mod, event)
	end)
	game.on_event(defines.events.on_robot_built_entity,function(event)
		mod = handleEntityBuilt(mod, event)
	end)
	game.on_event(defines.events.on_preplayer_mined_item,function(event)
		mod = handleEntityRemoved(mod, event)
	end)
	game.on_event(defines.events.on_robot_pre_mined,function(event)
		mod = handleEntityRemoved(mod, event)
	end)
	game.on_event(defines.events.on_entity_died,function(event)
		mod = handleEntityRemoved(mod, event)
	end)

--[[
	game.on_event(defines.events.on_gui_click,function(event)
		mod = handleGUIClick(mod, event)
	end)
]]
end

return utils