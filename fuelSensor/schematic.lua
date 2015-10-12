local utils = require "FAD.utils"


local function getTrain(entity)
	return entity.train
end


--[[ Schematic ]]--

FuelSensorSchematic = {
	name="fuel_sensor",
	updateRateBySecond = 0.5,
	onPlace = function(entity, storage)
		--Doesn't open a menu when clicked
		entity.operable = false
	end,
	onDestroy = function(entity, storage) end,
	onUpdate = function(entity, storage, event)
		local fuelItems = {}
		local fuelSignals = {}

		for _,entityNearby in utils.getNearbyEntities(entity) do
			local isTrain,train=pcall(getTrain,entityNearby)
			if isTrain then
				local locomotives = utils.mergeTables(train.locomotives.front_movers, train.locomotives.back_movers)
				for _,locomotive in ipairs(locomotives) do
					local contents = locomotive.get_inventory(1).get_contents()
					if next(contents) == nil then
						fuelSignals = utils.addTables(fuelSignals, { signal_unfueled = 1 })
					else
						fuelSignals = utils.addTables(fuelSignals, { signal_fueled = 1 })
					end
					fuelItems = utils.addTables(fuelItems, contents)
				end
			end
		end
		utils.setCircuitCondition(entity, {
			item    = fuelItems,
			virtual = fuelSignals
		})
	end
}

return FuelSensorSchematic