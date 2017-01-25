-------------------------------------------------------------------
-- Total RP 3: Module
-- Bookworm
-- Save readable items into Total RP 3
-- Created by Ellypse
-- Licence : CC BY-NC-SA (http://creativecommons.org/licenses/)
-------------------------------------------------------------------
local _, Bookworm = ...;

function Bookworm.log(...)
	if not TRP3_DEBUG then return end;
	local tab = 1
	for i = 1,10 do
		if GetChatWindowInfo(i) == "Logs" then
			tab = i
			break
		end
	end
	_G["ChatFrame"..tab]:AddMessage("|cffaaaaaa[Total RP 3: Bookworm]|r " .. strjoin(" ", tostringall(...)));
end;

function Bookworm.logEvent(event, ...)
	Bookworm.log(("|cff62D96B[EVENT FIRED : %s]|r"):format(event), ...);
end

function Bookworm.logValue(valueName, ...)
	Bookworm.log(("|cff669EFF[%s]|r = "):format(valueName), ...);
end
function Bookworm.logTexture(valueName, texture, ...)
	Bookworm.log(("|cff669EFF[%s]|r = "):format(valueName), ("\124T%s:20:20\124t"):format(texture or ""), ...);
end

function Bookworm.init()

	local registerHandler = TRP3_API.utils.event.registerHandler;

	setfenv(1, Bookworm);

	Button.init();
	Book.init();
	API.init();

	registerHandler("ITEM_TEXT_READY", API.onItemTextReady);
	registerHandler("ITEM_TEXT_CLOSED", API.onItemTextClosed);
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