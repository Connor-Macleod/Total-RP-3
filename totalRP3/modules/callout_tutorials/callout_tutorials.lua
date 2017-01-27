----------------------------------------------------------------------------------
-- Total RP 3
-- Tutorials system
--	---------------------------------------------------------------------------
--	Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

TRP3_API.calloutTutorials = {};

local TUTORIAL_KEYS_PREFIX = "tutorial_";

local listenToEvent = TRP3_API.utils.event.registerHandler;
local registerConfigKey = TRP3_API.configuration.registerConfigKey;
local getConfigValue = TRP3_API.configuration.getValue;
local setConfigValue = TRP3_API.configuration.setValue;

local Tutorial = NPE_TutorialPointerFrame;
local registeredTutorials = {};

function TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialData)
	
	-- Unpack data structure
	local tutorialKey, content, frame, direction, event, check = tutorialData.ID, tutorialData.content, tutorialData.frame, tutorialData.direction, tutorialData.event, tutorialData.check;

	-- Check that we have everything we need
	assert(tutorialKey and type(content) == "string", "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) without a valid tutorial key.");
	assert(content and type(content) == "string", "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) without a valid content.");
	assert(frame, "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) without a valid frame.");
	assert(direction and type(direction) == "string", "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) without a valid direction.");
	assert(not check or type(check) == "function", "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) with an invalid check function.")
	assert(event and type(event) == "string", "Trying to call TRP3_API.calloutTutorials.registerNewSimpleTextTutorial(tutorialKey, content, frame, direction, event, check) without a valid event.");
	
	tutorialKey = TUTORIAL_KEYS_PREFIX .. tutorialKey;
	-- Register config key, by default the tutorial must be shown
	registerConfigKey(tutorialKey, true);
	tinsert(registeredTutorials, tutorialKey)
	
	listenToEvent(event, function(...)
		-- Check that the module is enabled, that the tutorial must be shown
		-- and if a check function has been given we use it too to check if we should show the tutorial
		if getConfigValue("CALLOUT_TUTORIALS") and getConfigValue(tutorialKey) and (not check or check(...)) then
			Tutorial:Show(content, direction, frame);
			-- The tutorial has been shown, it should not be shown again
			setConfigValue(tutorialKey, false);
		end
	end)
end

-- Config must be built on WORKFLOW_ON_LOADED or else the TargetFrame module could be not yet loaded.
TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
	
	registerConfigKey("CALLOUT_TUTORIALS", true);
	
	-- Enable tutorials checkbox
	tinsert(TRP3_API.configuration.CONFIG_STRUCTURE_GENERAL, {
		inherit = "TRP3_ConfigCheck",
		title = "Enable tutorials",
		configKey = "CALLOUT_TUTORIALS",
		help = "Show popup tutorials to show Total RP 3's features."
	});
	
	-- Edit dictionary button
	tinsert(TRP3_API.configuration.CONFIG_STRUCTURE_GENERAL, {
		inherit = "TRP3_ConfigButton",
		title = "Reset tutorials",
		help = "Reset tutorials",
		text = "Reset tutorials",
		callback = function()
			for _, configKey in pairs(registeredTutorials) do
				setConfigValue(configKey, true);
			end
		end,
	});
end);