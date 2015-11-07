require "defines"
require "config"



if global.FreightLogistics == nil then
	global.FreightLogistics = {
		name = '',
		schematics = {},
		entities = {},

		eventListeners = {
			onTick = {}
		}
	}
end


local mod = global.FreightLogistics



mod.register = function(modName)
	mod.name = modName
--	global[mod.name] = mod

	return mod
end

mod.addSchematic = function(schematic)
	if schematic.name == nil then
		error("FAD err: No name set on schematic")
	end
	mod.schematics[schematic.name] = schematic
	return mod
end

mod.addOnTickListener = function(listener)
	table.insert(mod.eventListeners.onTick, listener)
	return mod
end

--Given an entity, searches through all schematic types and all entities to find match
--If found returns the refernce to that entitie's storage, used in GUI
mod.getStorageByEntity = function(entity)
	local result
	for _, entityTypes in pairs(mod.entities) do
		for _, obj in pairs(entityTypes) do
			if obj.entity == entity then
				result = obj.storage
			end
		end
	end
	return result
end


--[[ MOD MANAGEMENT ]]--


local function handleOnTick(event)
	for name, schematic in pairs(mod.schematics) do
		local shouldUpdate = true
		if schematic.updateRateBySecond~=nil then
			shouldUpdate = false
			if event.tick % (schematic.updateRateBySecond * 60) == 0  then
				shouldUpdate = true
			end
		end
		--Allow different entity schematics to have different update rates
		if shouldUpdate then
			for _, obj in pairs(mod.entities[name]) do
				if obj.entity ~= nil and obj.entity.valid then
					schematic.onUpdate(obj.entity, obj.storage, event)
				end
			end
		end
	end

	for _, listener in ipairs(mod.eventListeners.onTick) do
		listener(event)
	end
	return mod
end


local function handleEntityBuilt(event)
	if mod.schematics[event.created_entity.name]~= nil then
		local specificEntityTable = mod.entities[event.created_entity.name]
		local entityStorage = {}
		mod.schematics[event.created_entity.name].onPlace(event.created_entity, entityStorage, event)
		table.insert(specificEntityTable,{
			entity = event.created_entity,
			storage = entityStorage
		})
		mod.entities[event.created_entity.name] = specificEntityTable
	end
	return mod
end

local function handleEntityRemoved(event)
	if mod.schematics[event.entity.name]~= nil then
		for index, obj in ipairs(mod.entities[event.entity.name]) do
			if obj.entity==event.entity then
				local specificEntityTable = mod.entities[event.entity.name]
				table.remove(specificEntityTable,index)
				mod.schematics[event.entity.name].onDestroy(obj.entity, obj.storage, event)
				mod.entities[event.entity.name] = specificEntityTable
				break
			end
		end
	end
	return mod
end


--[[local function handleOnLoad()
	if mod.name == nil then
		error("FAD err: No name set for mod")
	end
	if global[mod.name] == nil then
		global[mod.name] = mod
	else
		mod = global[mod.name]
	end

	--Create a table for each list of entities
	for name,schematic in pairs(mod.schematics) do
		mod.entities[name] = mod.entities[name] or {}
	end
	return mod
end

]]


--[[
script.on_save(function()
	global[mod.name] = mod.entities
end)
]]

script.on_init(handleOnLoad)
script.on_load(handleOnLoad)
script.on_event(defines.events.on_tick, handleOnTick)
script.on_event(defines.events.on_built_entity, handleEntityBuilt)
script.on_event(defines.events.on_robot_built_entity, handleEntityBuilt)
script.on_event(defines.events.on_preplayer_mined_item, handleEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, handleEntityRemoved)
script.on_event(defines.events.on_entity_died, handleEntityRemoved)

return mod