local config = require "config"

local utils = {}

--Converts any type, including tables into a string
local AnyToString = function(arg)
	ToString = function(arg)
		local res=""
		if type(arg)=="table" then
			res="{"
			for k,v in pairs(arg) do
				res=res.. tostring(k).." = ".. ToString(v) ..","
			end
			res=res.."}"
		else
			res=tostring(arg)
		end
		return res
	end
	return ToString(arg, "  ")
end


--A useful print-anything command, good for debugging
utils.print = function(arg)
	return game.player.print(AnyToString(arg))
end


debug = function() end
if config.DEBUG then
	debug=utils.print
end




utils.createText = function(text, pos, color)
	color = color or {r=1, g=1, b=1}
	game.player.surface.create_entity({name="flying-text", position=pos, text=text, color=color})
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
--[[
usage:
utils.setCircuitCondition(entity, {
	item : {
		"iron-plate" : 40
	},
	virtual : {
		"signal-green" : 1
	}
})

]]
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

--Shortcut for a common check you do
utils.isValid = function(entity)
	return (entity ~= nil and entity.valid)
end

utils.isOpenedEntityNamed = function(entityName)
	return utils.isValid(game.player.opened) and game.player.opened.name == entityName
end

utils.isOpenedEntity = function(entity)
	return utils.isValid(game.player.opened) and game.player.opened == entity
end



--[[ TABLE UTILS ]]--

-- Arthimetically adds multiple tables together
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


return utils