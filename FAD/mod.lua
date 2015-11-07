require "defines"

Mod = {
	schematics = {},
	eventListeners = {},
}


local function handleOnTick(event)
	if Mod.eventListeners[defines.events.on_tick] ~= nil then
		for _, listener in ipairs(Mod.eventListeners[defines.events.on_tick]) do
			listener(event)
		end
	end

	for name, schematic in pairs(Mod.schematics) do
		local shouldUpdate = true
		if schematic.updateRateBySecond~=nil then
			shouldUpdate = false
			if event.tick % (schematic.updateRateBySecond * 60) == 0  then
				shouldUpdate = true
			end
		end
		--Allow different entity schematics to have different update rates
		if shouldUpdate then
			for _, obj in pairs(global.entities[name]) do
				if obj.entity ~= nil and obj.entity.valid then
					schematic.onUpdate(obj.entity, obj.storage, event)
				end
			end
		end
	end
end


local function handleEntityBuilt(event)
	if Mod.schematics[event.created_entity.name]~= nil then
		local specificEntityTable = global.entities[event.created_entity.name]
		local entityStorage = {}
		Mod.schematics[event.created_entity.name].onPlace(event.created_entity, entityStorage, event)
		table.insert(specificEntityTable,{
			entity = event.created_entity,
			storage = entityStorage
		})
		global.entities[event.created_entity.name] = specificEntityTable
	end

end

local function handleEntityRemoved(event)
	if Mod.schematics[event.entity.name]~= nil then
		for index, obj in ipairs(global.entities[event.entity.name]) do
			--utils.print(obj.entity)
			if obj.entity==event.entity then
				local specificEntityTable = global.entities[event.entity.name]
				table.remove(specificEntityTable,index)
				Mod.schematics[event.entity.name].onDestroy(obj.entity, obj.storage, event)
				global.entities[event.entity.name] = specificEntityTable
				break
			end
		end
	end
end

local handleLoad = function()
	if global.entities == nil then
		global.entities = {}
	end

	-- Bootstrap the entity table with schematics
	for name, schematic in pairs(Mod.schematics) do
		if global.entities[name] == nil then
			global.entities[name] = {}
		end
	end
end



Mod.set = function(key, val)
	global[key] = val
	return Mod
end

Mod.get = function(key, default)
	if global[key] == nil then
		return default
	end
	return global[key]
end


Mod.addSchematic = function(schematic)
	if schematic.name == nil then
		error("FAD err: No name set on schematic")
	end
	Mod.schematics[schematic.name] = schematic
end


Mod.addOnTickListener = function(listener)
	Mod.addListener(defines.events.on_tick, listener)
	--return Mod
end

Mod.addListener = function(event, listener)
	if Mod.eventListeners[event] == nil then
		Mod.eventListeners[event] = {}
	end
	table.insert(Mod.eventListeners[event], listener)
end

Mod.getStorageByEntity = function(entity)
	local result
	for _, entityTypes in pairs(global.entities) do
		for _, obj in pairs(entityTypes) do
			if obj.entity == entity then
				result = obj.storage
			end
		end
	end
	return result
end





script.on_init(function()
	handleLoad()
end)

script.on_load(function()
	handleLoad()
end)




script.on_event(defines.events.on_tick,                 handleOnTick)
script.on_event(defines.events.on_built_entity,         handleEntityBuilt)
script.on_event(defines.events.on_robot_built_entity,   handleEntityBuilt)
script.on_event(defines.events.on_preplayer_mined_item, handleEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined,      handleEntityRemoved)
script.on_event(defines.events.on_entity_died,          handleEntityRemoved)


return Mod