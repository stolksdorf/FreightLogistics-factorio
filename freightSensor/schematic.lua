local utils = require "FAD.utils"


local function getTrain(entity)
	return entity.train
end

-- Attempts to get the amount of fluid from a rail tanker (If you have that mod)
local function getFluid(railtanker)
	if remote.interfaces.railtanker and remote.interfaces.railtanker.getLiquidByWagon then
		local tankerval = remote.call("railtanker", "getLiquidByWagon", railtanker)
		if tankerval ~= nil and tankerval.amount ~= nil then
			local amount = math.ceil(tankerval.amount)
			if amount > 0 then
				return {
					type = tankerval.type,
					amount = amount
				}
			end
		end
	end
end



--[[ Schematic ]]--
FreightSensorSchematic = {
	name="freight_sensor",
	updateRateBySecond = 1.5,

	onPlace = function(entity, storage)
		entity.operable = false --Doesn't open a menu
	end,

	onDestroy = function(entity, storage) end,

	onUpdate = function(entity, storage, event)
		local items = {}
		local fluids = {}
		for i,entityNearby in utils.getNearbyEntities(entity) do
			local isTrain,train=pcall(getTrain,entityNearby)
			if isTrain then
				for i,cargoWagon in ipairs(train.cargo_wagons) do
					if cargoWagon.name == 'rail-tanker' then
						local fluid = getFluid(cargoWagon)
						if fluid then
							fluids = utils.addTables(fluids, {[fluid.type] = fluid.amount})
						end
					else
						for itemName,itemCount in pairs(cargoWagon.get_inventory(1).get_contents()) do
							items = utils.addTables(items, {[itemName] = itemCount})
						end
					end
				end
			end
		end
		utils.setCircuitCondition(entity,{
			item = items,
			fluid = fluids
		})
	end
}

return FreightSensorSchematic