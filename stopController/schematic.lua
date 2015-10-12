local utils = require "FAD.utils"
local GUI = require "FAD.gui"
local Mod = require "FAD.mod"


local function getTrain(entity)
	return entity.train
end


local hasStop = function(schedule, stationName)
	if type(schedule.records) == "table" and next(schedule.records) then
		for idx,stop in pairs(schedule.records) do
			if stationName == stop.station then
				return true
			end
		end
	end
	return false
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
	if utils.isValid(storage.indicator) then
		storage.indicator.destroy()
	end
	local indicatorName = "indicator_red"
	if state then
		indicatorName = "indicator_green"
	end
	storage.indicator = entity.surface.create_entity{name = indicatorName, position = entity.position}
end



local updateGUI = function(storage)
	storage.gui.stop_name_input.text = storage.stopName
	storage.gui.duration_container.duration_val.caption = storage.duration/60 .."s"
end

local saveFromGUI = function(storage)
	storage.stopName = storage.gui.stop_name_input.text
end


local StopControllerGUI = GUI.register({
	type="frame",
	name="stop_controller_frame",
	caption={"stc_window_title"},
	direction="vertical",

	children={
		{type="label", name="stop_name", caption={"stc_stop_name_caption"}},
		{type="textfield", name="stop_name_input", text=""},
		{type="flow", direction="horizontal", name="duration_container", children={
			{type="label", name="duration", caption="Duration : "},
			{
				type="button",
				name="decrease_btn",
				style="circuit_condition_sign_button_style",
				caption="<",
				onClick = function(event, openedEntity)
					local storage = Mod.getStorageByEntity(openedEntity)
					saveFromGUI(storage)
					storage.duration = storage.duration - 300
					if storage.duration < 0 then
						storage.duration = 0
					end
					updateGUI(storage)
				end
			},
			{type="label", name="duration_val", caption=""},
			{
				type="button",
				name="increase_btn",
				style="circuit_condition_sign_button_style",
				caption=">",
				onClick = function(event, openedEntity)
					local storage = Mod.getStorageByEntity(openedEntity)
					saveFromGUI(storage)
					storage.duration = storage.duration + 300
					if storage.duration > 18000 then
						storage.duration = 18000
					end
					updateGUI(storage)
				end
			},
		}},
	}
})




--[[ SCHEMATIC ]]--

StopControllerSchematic = {
	name="stop_controller",
	updateRateBySecond = 0.25,
	onPlace = function(entity, storage)
		storage.indicator = entity.surface.create_entity{name = "indicator_orange", position = entity.position}
		storage.stopName = ""
		storage.duration = 1800
	end,
	onDestroy = function(entity, storage)
		if utils.isValid(storage.indicator) then
			storage.indicator.destroy()
		end
		GUI.destroy(storage.gui)
	end,
	onUpdate = function(entity, storage, event)
		local condFulfilled = entity.get_circuit_condition(1).fulfilled

		--Update the indicator Light
		if storage.state ~= condFulfilled then
			storage.state = condFulfilled
			drawIndicator(entity, storage, condFulfilled)
		end

		--Draw the Gui if this entitie's GUI is opened
		if utils.isOpenedEntity(entity) then
			if not utils.isValid(storage.gui) then
				storage.gui = GUI.create(game.player.gui.left, StopControllerGUI)
				updateGUI(storage)
			end
		else
			if utils.isValid(storage.gui) then
				storage.stopName = storage.gui.stop_name_input.text
				storage.gui.destroy()
			end
		end


		--If a stop name is set, check for nearby trains to update their schedules
		if storage.stopName and storage.stopName ~= "" then

			for _,entityNearby in utils.getEntitiesInFront(entity) do
				local isTrain,train=pcall(getTrain,entityNearby)
				if isTrain and train.speed == 0 then

					if not hasStop(train.schedule, storage.stopName) and condFulfilled then
						train.schedule = addStop(train.schedule, storage.stopName, storage.duration)
						utils.createText("Added "..storage.stopName, entity.position, {r=0,g=1,b=0})
					end

					if hasStop(train.schedule, storage.stopName) and not condFulfilled then
						train.schedule = removeStop(train.schedule, storage.stopName)
						utils.createText("Removed "..storage.stopName, entity.position, {r=1, g=0, b=0})
					end

				end
			end
		end

	end
}

return StopControllerSchematic