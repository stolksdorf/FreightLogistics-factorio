local Mod = require "FAD.mod"

--Mod Defintion
local FreightLogisticsMod = Mod.register("FreightLogisticsMod")

--Entities
FreightLogisticsMod.addSchematic(require "freightSensor.schematic")
FreightLogisticsMod.addSchematic(require "fuelSensor.schematic")
FreightLogisticsMod.addSchematic(require "stopController.schematic")
