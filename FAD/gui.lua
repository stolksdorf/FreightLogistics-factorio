require "defines"
local utils = require "FAD.utils"

gui = {
	onClickListeners = {}
}

-- Removes all non-Factorio keys from the GUI markup
local sanatizeMarkup = function(guiMarkup)
	local result = {}
	for key, val in pairs(guiMarkup) do
		if key ~= "children" and key ~= "onClick" then
			result[key] = val
		end
	end
	return result
end

local handleGUIClick = function(event)
	for elementName, listener in pairs(gui.onClickListeners) do
		local openedEntity
		if utils.isValid(game.player.opened) then
			openedEntity = game.player.opened
		end
		if elementName == event.element.name then
			listener(event, openedEntity)
		end
	end
end


gui.register = function(guiMarkup)
	findHandlers = function(elementMarkup)
		if elementMarkup.onClick ~= nil then
			gui.onClickListeners[elementMarkup.name] = elementMarkup.onClick
		end
		if elementMarkup.children ~= nil then
			for _, childMarkup in ipairs(elementMarkup.children) do
				findHandlers(childMarkup)
			end
		end
	end
	findHandlers(guiMarkup)
	return guiMarkup
end


gui.create = function(container, guiMarkup)
	createElement = function(container, elementMarkup)
		if container[elementMarkup.name] == nil then
			container.add(sanatizeMarkup(elementMarkup))
			if elementMarkup.children ~= nil then
				for _, element in ipairs(elementMarkup.children) do
					createElement(container[elementMarkup.name], element)
				end
			end
		end
		return container[elementMarkup.name]
	end
	return createElement(container, guiMarkup)
end

gui.destroy = function(guiEntity)
	if utils.isValid(guiEntity) then
		guiEntity.destroy()
	end
end



--Register the gui click handler with the game
game.on_event(defines.events.on_gui_click, handleGUIClick)

return gui