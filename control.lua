local config = require "config"
local utils  = require "utils"

--Mod Defintion
local freightSensorMod = {
	key        = "freightSensorMod",
	blueprints = {},
	entities   = {}
}

--Entities
local freightSensor = require("freightSensor.blueprint")
local fuelSensor = require("fuelSensor.blueprint")
local stopController = require("stopController.blueprint")



local onTick = function(event)

end




freightSensorMod.blueprints[freightSensor.name] = freightSensor
freightSensorMod.blueprints[fuelSensor.name] = fuelSensor
freightSensorMod.blueprints[stopController.name] = stopController



utils.addModToGame(freightSensorMod, onTick)
