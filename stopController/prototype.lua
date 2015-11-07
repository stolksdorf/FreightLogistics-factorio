local utils = require "FAD.utils"

utils.addToExistingTech(data, "freight_logistics", "stop_controller")

data:extend({
	--Recipe
	{
		type = "recipe",
		name = "stop_controller",
		enabled = false,
		ingredients =
		{
			{"copper-cable", 5},
			{"train-stop", 2},
			{"electronic-circuit", 2},
		},
		result = "stop_controller"
	},


	--FAKE Recipe
	{
		type = "recipe",
		name = "stop_controller",
		enabled = true,
		ingredients =
		{
			{"iron-plate", 1},
		},
		result = "stop_controller"
	},

	--Item
	{
		type = "item",
		name = "stop_controller",
		icon = "__FreightLogistics__/stopController/img/icon.png",
		flags = { "goes-to-quickbar" },
		subgroup = "circuit-network",
		place_result="stop_controller",
		order = "b[combinators]-a[stop_controller]",
		stack_size= 50,
	},

	{
		type = "inserter",
		name = "stop_controller",
		icon = "__FreightLogistics__/stopController/img/icon.png",
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "stop_controller"},
		max_health = 100,
		render_layer = "object",
		corpse = "small-remnants",
		filter_count = 1,
		resistances = {
			{
				type = "fire",
				percent = 90
			}
		},
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		pickup_position = {0, -0.2},
		insert_position = {0, 1.2},
		energy_per_movement = 200,
		energy_per_rotation = 200,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			drain = "0.4kW",
		},
		extension_speed = 0.7,
		programmable = true,
		rotation_speed = 0.35,
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		hand_base_picture = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		hand_closed_picture = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		hand_open_picture = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		hand_base_shadow = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		hand_closed_shadow = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		hand_open_shadow = { filename = "__FreightLogistics__/stopController/img/entity.png", width = 0, height = 0 },
		platform_picture = {
			sheet = {
				filename = "__FreightLogistics__/stopController/img/entity.png",
				width = 72,
				height = 46,
				frame_count = 4,
				shift = {0, 0},
			}
		},

		circuit_wire_connection_point = {
			shadow = {
				red = {0.2, 0},
				green = {0.2, 0}
			},
			wire = {
				red = {0.0, -0.2},
				green = {0.0, -0.2}
			}
		},
		circuit_wire_max_distance = 7.5,
		uses_arm_movement = "basic-inserter"
	},

	--Indicator lights used on the Stop Controller
	{
		type = "simple-entity",
		name = "indicator_green",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures = {
			{
				filename = "__FreightLogistics__/stopController/img/indicator_green.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},
	{
		type = "simple-entity",
		name = "indicator_orange",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures = {
			{
				filename = "__FreightLogistics__/stopController/img/indicator_orange.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},
	{
		type = "simple-entity",
		name = "indicator_red",
		flags = {"placeable-off-grid"},
		drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
		render_layer = "object",
		max_health = 0,
		pictures = {
			{
				filename = "__FreightLogistics__/stopController/img/indicator_red.png",
				width = 11,
				height = 11,
				shift = {0,0},
			},
		}
	},


})
