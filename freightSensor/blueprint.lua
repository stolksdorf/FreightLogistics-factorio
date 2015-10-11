
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

-- Incrementally adds an item to a table
local function addToIncrementTable(tab, item, count)
	if tab[item] == nil then
		tab[item] = 0
	end
	tab[item] = tab[item] + count
	return tab
end

--Creates a table used to set the circuit condition
local function createCircuitCondition(items, fluids)
	local condition = {parameters = {}}
	local i = 1
	for name,count in pairs(items) do
		condition.parameters[i]={signal={type = "item", name = name}, count = count, index = i}
		i = i + 1
	end
	for name,count in pairs(fluids) do
		condition.parameters[i]={signal={type = "fluid", name = name}, count = count, index = i}
		i = i + 1
	end
	return condition
end







--[[ BLUEPRINT ]]--

FreightSensorBlueprint = {
	name="freight-sensor",
	updateRateBySecond = 1.5,

	onPlace = function(entity, storage)
		debug("Placed a freight sensor!")
		entity.operable = false --Doesn't open a menu
	end,
	onDestroy = function(entity, storage) end,
	onUpdate = function(entity, storage, event)
		local items = {}
		local fluids = {}
		for i,entityNearby in ipairs(entity.surface.find_entities(utils.getArea(entity.position))) do
			local isTrain,train=pcall(getTrain,entityNearby)
			if isTrain then
				for i,cargoWagon in ipairs(train.cargo_wagons) do
					if cargoWagon.name == 'rail-tanker' then
						local fluid = getFluid(cargoWagon)
						if fluid then
							debug(fluid.type .. fluid.amount)
							fluids = addToIncrementTable(fluids, fluid.type, fluid.amount)
						end
					else
						for itemName,itemCount in pairs(cargoWagon.get_inventory(1).get_contents()) do
							debug(itemName .. itemCount)
							items = addToIncrementTable(items, itemName, itemCount)
						end
					end
				end
			end
		end
		entity.set_circuit_condition(1, createCircuitCondition(items, fluids))
	end
}

return FreightSensorBlueprint