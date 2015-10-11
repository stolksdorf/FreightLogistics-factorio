local utils = require "utils"

utils.addToExistingTech(data, "rail-signals", "freight-sensor")

data:extend({

	--Recipe
	{
		type = "recipe",
		name = "freight-sensor",
		enabled = false,
		ingredients =
		{
			{"copper-cable", 5},
			{"rail-signal", 2},
			{"electronic-circuit", 2},
		},
		result = "freight-sensor"
	},

	--Item
	{
		type = "item",
		name = "freight-sensor",
		icon = "__freight-sensor__/freightSensor/img/icon.png",
		flags = { "goes-to-quickbar" },
		subgroup = "circuit-network",
		place_result="freight-sensor",
		order = "b[combinators]-a[freight-sensor]",
		stack_size= 50,
	},

	--Entity
	{
		type = "constant-combinator",
		name = "freight-sensor",
		icon = "__freight-sensor__/freightSensor/img/icon.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "freight-sensor"},
		max_health = 50,
		corpse = "small-remnants",

		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

		item_slot_count = 15,

		sprite =
		{
			filename = "__freight-sensor__/freightSensor/img/entity.png",
			x = 61,
			width = 61,
			height = 50,
			shift = {0.078125, 0.15625},
		},
		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.828125, 0.328125},
				green = {0.828125, -0.078125},
			},
			wire =
			{
				red = {0.515625, -0.078125},
				green = {0.515625, -0.484375},
			}
		},
		circuit_wire_max_distance = 7.5
	},
})
