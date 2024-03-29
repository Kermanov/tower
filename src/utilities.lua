local loadsave = require("loadsave")

M = {}

M.shallowCopy = function(original)
	local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

M.contains = function(tab, elem)
	for i = 1, #tab do
		if tab[i] == elem then
			return true
		end
	end
	return false
end

M.round = function(number, digits)
	return tonumber(string.format("%." .. digits .. "f", number))
end

M.saveSettings = function(options)
	local settings = loadsave.loadTable("settings.json")
	for key, val in pairs(options) do
		settings[key] = val
	end
	loadsave.saveTable(settings, "settings.json")
end

return M
