-------------------------------------------------------------------
-- Total RP 3: Module
-- Bookworm
-- Save readable items into Total RP 3
-- Created by Ellypse
-- Licence : CC BY-NC-SA (http://creativecommons.org/licenses/)
-------------------------------------------------------------------
local _, Bookworm = ...;

Bookworm.log = print;

function Bookworm.init()

	local registerHandler = TRP3_API.utils.event.registerHandler;

	Bookworm.log = TRP3_API.utils.log.log;

	Bookworm.buttons.init();
	Bookworm.book.init();
	Bookworm.API.init();

	registerHandler("ITEM_TEXT_READY", Bookworm.API.onItemTextReady);
	registerHandler("ITEM_TEXT_CLOSED", Bookworm.API.onItemTextClosed);
end

local MODULE_STRUCTURE = {
	["name"] = "Bookworm",
	["description"] = "Save in-game books into Total RP 3: Extended",
	["version"] = 1.000,
	["id"] = "trp3_bookworm",
	["onStart"] = Bookworm.init,
	["minVersion"] = 25,
	["requiredDeps"] = {
		{"trp3_extended", 0.9},
	}
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);