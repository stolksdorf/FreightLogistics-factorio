local utils = require "utils"


local function getTrain(entity)
	return entity.train
end


local hasStop = function(schedule, stationName)
	local res = false
	utils.print(type(schedule.records))
	if type(schedule.records) == "table" and next(schedule.records) then
		for idx,stop in ipairs(schedule.records) do
			if stationName == stop.station then
				--res = idx
				return true
			end
		end
	end
	return res
end

local addStop = function(schedule, stationName, duration)
	duration = duration or 1800
	if type(schedule.records) ~= "table" then
		schedule.records = {}
	end
	table.insert(schedule.records, {
		station=stationName,
		time_to_wait=duration
	})
	return schedule
end

local removeStop = function(schedule, stationName)
	if type(schedule.records) == "table" and next(schedule.records) then
		for idx,stop in ipairs(schedule.records) do
			if stationName == stop.station then
				table.remove(schedule.records, idx)
				return schedule
			end
		end
	end
	return schedule
end


local drawIndicator = function(entity, storage, state)
	if storage.indicator ~= nil and storage.indicator.valid then
		storage.indicator.destroy()
	end

	if state then
		storage.indicator = entity.surface.create_entity{name = "indicator-green", position = entity.position}
	else
		storage.indicator = entity.surface.create_entity{name = "indicator-red", position = entity.position}
	end
end


--[[ GUI STUFF ]]


local findIndexByKey = function(tab, key)
	local result
	local inverse = {}
	for k,v in pairs(tab) do
		inverse[v] = k
	end
	debug(inverse)
	for index, val in ipairs(inverse) do
		if val == key then
			debug('FOUND'.. index)
			result = index
		end
	end
	return result
end


local schematicAdd = function(schematic)
	local result = {}
	for key, val in pairs(schematic) do
		if key ~= "children" and key ~= "onclick" then
			result[key] = val
		end
	end
	return result
end

local showGUI = function(container, schematic)
	createElement = function(container, schematic)
		if container[schematic.name] == nil then

			--debug(findIndexByKey(schematic, 'onclick'))
			--debug(type(schematic.children))
			debug(schematicAdd(schematic))
			debug('---')
			container.add(schematicAdd(schematic))
			if schematic.children ~= nil then
				for _, element in ipairs(schematic.children) do
					createElement(container[schematic.name], element)
				end
			end
		end
		return container[schematic.name]
	end
	return createElement(container, schematic)
end




local clickEvents = {}
local registerGUI = function(schematic)
	local events = {}
	findHandlers = function(schematic)
		if schematic.onclick ~= nil then
			events[schematic.name] = schematic.onclick
		end
		if schematic.children ~= nil then
			for _, element in ipairs(schematic.children) do
				findHandlers(element)
			end
		end
		return schematic
	end
	findHandlers(schematic)
	return events
end


game.on_event(defines.events.on_gui_click,function(event)
	debug("GUI CLICK")

	local entity
	if utils.isValid(game.player.opened) and game.player.opened.name == "stop_controller" then
		entity = game.player.opened
	end
	for elementName, func in pairs(clickEvents) do
		if elementName == event.element.name then
			func(entity)
		end
	end
end)





local StopControllerGUI = {
	type="frame",
	name="test",
	caption={"gui_window_title"},
	direction="vertical",
	onclick=function()
		debug("COOL")
	end,
	children={
		{type="button", name="test_save", caption={"msg-button-save"}},
		{
			type="button",
			name="test_save2",
			caption={"msg-button-save"},
			onclick=function()
				debug(globalGUI)
			end
		},
		{type="textfield", name="test_text", text="WOO"}
	}
}

clickEvents = registerGUI(StopControllerGUI)


globalGUI = {}


--[[ BLUEPRINT ]]--

StopControllerBlueprint = {
	name="stop_controller",
	updateRateBySecond = 0.5,
	onPlace = function(entity, storage)
		debug("Placed a stop_controller!")
		storage.indicator = entity.surface.create_entity{name = "indicator-orange", position = entity.position}
	end,
	onDestroy = function(entity, storage)
		if utils.isValid(storage.indicator) then
			storage.indicator.destroy()
		end
	end,
	onUpdate = function(entity, storage, event)

		local condFulfilled = entity.get_circuit_condition(1).fulfilled

		if storage.state ~= condFulfilled then
			storage.state = condFulfilled
			drawIndicator(entity, storage, condFulfilled)
			debug('updating')
		end


		--debug(game.player.selected)
		--debug(entity.selected)

		--debug('---')

		if utils.isValid(game.player.opened) and game.player.opened.name == "stop_controller" then
			--debug("Menu opened on this guy")
			storage.gui = showGUI(game.player.gui.left, StopControllerGUI)
			globalGUI = storage.gui

			debug(game.player.gui.left.test.test_text.text)

			game.player.gui.left.test.test_text.text = "neato"

			--temp = newGUI(storage.gui, {type="button", name="test_save", caption={"msg-button-save"}})
		else
			if utils.isValid(storage.gui) then
				storage.gui.destroy()
			end
		end





		for _,entityNearby in utils.getEntitiesInFront(entity) do
			local isTrain,train=pcall(getTrain,entityNearby)
			if isTrain and train.speed == 0 then
				utils.print(train.schedule)
				utils.print(hasStop(train.schedule, 'Alpha'))
				utils.print(hasStop(train.schedule, 'Beta'))
				utils.print("---")

				if hasStop(train.schedule, 'Alpha') == false then
					train.schedule=addStop(train.schedule, 'Alpha')
				end
				train.schedule=removeStop(train.schedule, 'Beta')

			end
		end

	end
}

return StopControllerBlueprint