
data:extend({
	{
		type = "technology",
		name = "freight_logistics",
		icon = "__FreightLogistics__/img/technology.png",
		unit = {
			count = 50,
			time  = 10,
			ingredients = {
				{"science-pack-1", 1,},
				{"science-pack-2", 1,},
			},
		},
		prerequisites = {"rail-signals"},
		effects = {},
		order = "a-d-e",
	},
})

require("freightSensor.prototype")
require("fuelSensor.prototype")
require("stopController.prototype")