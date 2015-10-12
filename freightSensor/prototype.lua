local utils = require "FAD.utils"

utils.addToExistingTech(data, "freight_logistics", "freight_sensor")

data:extend({

	--Recipe
	{
		type = "recipe",
		name = "freight_sensor",
		enabled = false,
		ingredients = {
			{"copper-cable", 5},
			{"rail-signal", 2},
			{"electronic-circuit", 2},
		},
		result = "freight_sensor"
	},

	--Item
	{
		type = "item",
		name = "freight_sensor",
		icon = "__FreightLogistics__/freightSensor/img/icon.png",
		flags = { "goes-to-quickbar" },
		subgroup = "circuit-network",
		place_result="freight_sensor",
		order = "b[combinators]-a[freight-sensor]",
		stack_size= 50,
	},

	--Entity
	{
		type = "constant-combinator",
		name = "freight_sensor",
		icon = "__FreightLogistics__/freightSensor/img/icon.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "freight_sensor"},
		max_health = 50,
		corpse = "small-remnants",

		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

		item_slot_count = 15,

		sprite = {
			filename = "__FreightLogistics__/freightSensor/img/entity.png",
			x = 61,
			width = 61,
			height = 50,
			shift = {0.078125, 0.15625},
		},
		circuit_wire_connection_point = {
			shadow = {
				red = {0.828125, 0.328125},
				green = {0.828125, -0.078125},
			},
			wire = {
				red = {0.515625, -0.078125},
				green = {0.515625, -0.484375},
			}
		},
		circuit_wire_max_distance = 7.5
	},
})
