----------------------------------------------------------------------------------
-- Total RP 3: Bookworm
-- Bookworm API
--	---------------------------------------------------------------------------
--	Copyright 2017 Renaud "Ellypse" Parize @EllypseCelwe <ellypse@totalrp3.info>
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

local _, Bookworm = ...;

Bookworm.API = {};

function Bookworm.API.init()

	local tinsert = tinsert;
	local pairs = pairs;
	local UNKNOWN = UNKNOWN;

	local TRP3_API = {
		generateID = TRP3_API.utils.str.id,
		getDocumentItemData = TRP3_API.extended.tools.getDocumentItemData,
		createItem = TRP3_API.extended.tools.createItem,
		addItem = TRP3_API.inventory.addItem,
		playSound = TRP3_API.ui.misc.playSoundKit,
		fireEvent = TRP3_API.events.fireEvent,
		ON_OBJECT_UPDATED = TRP3_API.events.ON_OBJECT_UPDATED,
		registerEffect = TRP3_API.script.registerEffect,
		displayMessage = TRP3_API.utils.message.displayMessage,
		messageTypes = TRP3_API.utils.message.type,
		loc = TRP3_API.locale.getText,
		getClass = TRP3_API.extended.getClass,
		registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor,
		getBlankItemData = TRP3_API.extended.tools.getBlankItemData
	}
	local TRP3_DB = TRP3_DB;
	local ITEM_TEXT_FROM = ITEM_TEXT_FROM;

	setfenv(1, Bookworm);

	-- Default icons to use when the document is not from an item
	local DEFAULT_ICONS = {
		Parchment = "INV_Misc_Book_03",
		Bronze = "inv_misc_wartornscrap_plate",
		Silver = "inv_misc_wartornscrap_plate",
		Stone = "INV_Misc_StoneTablet_04",
		Marble = "INV_Misc_StoneTablet_03",
		default = "INV_Misc_Book_03",
	}

	local DOCUMENT_TYPES = {
		Parchment = "Book",
		Bronze = "Plaque",
		Silver = "Plaque",
		Stone = "Plaque",
		Marble = "Plaque",
	}

	local TITLE_PAGE_TEMPLATE = [[
{p:c}{/p}




{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]
	local NORMAL_PAGE_TEMPLATE = [[{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]];
	local TITLED_PAGE_TEMPLATE = [[{p:c}{/p}
{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]

	local function getIconForMaterial(material)
		return DEFAULT_ICONS[material] or DEFAULT_ICONS.default;
	end

	local function fetchExistingDocument(documentName)
		for itemID, item in pairs(TRP3_DB.global) do
			if item.BA.NA == documentName then
				return itemID;
			end
		end
	end

	local function documentAlreadyExists(documentName)
		return fetchExistingDocument(documentName) ~= nil;
	end

	function API.onItemTextReady()
		logEvent("ITEM_TEXT_READY");
		logValue("Item name", Book.getItem());
		logValue("Item info", Book.getInfo());
		logValue("Item has author", Book.hasAuthor());
		logValue("Item's author", Book.getAuthor());
		logTexture("Item icon", Book.getItemIcon());
		logValue("Page is HTML", Book.currentPageIsHTML());

		Button:Show();

		logValue("Item text", Book.getText());

		local itemIcon = Book.getItemIcon() or "Interface\\ICONS\\" .. getIconForMaterial(Book.getMaterial());
		logTexture("Computed item icon", itemIcon);

		Button:SetIcon(itemIcon);

		logValue("Document already exisits", documentAlreadyExists(Book.getItem()));
		if documentAlreadyExists(Book.getItem()) then
			Button:ShowCheckmark();
		end
	end

	function Bookworm.API.onItemTextClosed()
		logEvent("ITEM_TEXT_CLOSED");
		Button:Hide();
	end

	function Bookworm.API.onButtonClicked()
		local itemID;
		if documentAlreadyExists(Book.getItem()) then
			itemID = fetchExistingDocument(Book.getItem());
			logValue("Item already exists, adding to the inventory item", itemID);
		else

			local newItemID, item = TRP3_API.createItem(TRP3_API.getBlankItemData());
			itemID = newItemID;
			logValue("Created new item", itemID);

			-- Decorate item
			item.BA.NA = Book.getItem();
			if Book.hasAuthor() then
				item.BA.LE = ITEM_TEXT_FROM .. " " .. Book.getAuthor();
			end
			item.BA.IC = getIconForMaterial(Book.getMaterial()); -- Book.getItemIcon() or

			local pages = {};
			local currentPageNumber = Book.getPageNumber();

			Book.goToFirstPage();
			tinsert(pages, Book.getText());
			while(Book.hasNextPage()) do
				Book.nextPage();
				tinsert(pages, Book.getText());
			end
			Book.goToPage(currentPageNumber);

			-- Add opening sound on use
			item.SC = {
				onUse = {
					ST = {
						["1"] = {
							["e"] = {
								{
									["id"] = "sound_id_self",
									["args"] = {
										"SFX",
										831,
									},
								},
							},
							["t"] = "list",
							["n"] = "2"
						},
						["2"] = {
							["e"] = {
								{
									["id"] = "document_show_html",
									["args"] = {
										name = Book.getItem(),
										author = Book.getAuthor(),
										pages = pages
									},
								},
							},
							["t"] = "list",
						}
					}
				}
			};
		end

		TRP3_API.addItem(nil, itemID, {count = 1});
		TRP3_API.playSound(1184);

		TRP3_API.fireEvent(TRP3_API.ON_OBJECT_UPDATED);

		return true
	end

--	TRP3.registerEffect({
--		document_show_html = {
--			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
--			codeReplacementFunc = function (args)
--				local documentID = args[1];
--				return ("lastEffectReturn = showDocument(\"%s\", args);"):format(documentID);
--			end,
--			env = {
--				showDocument = "TRP3_API.extended.document.showDocument",
--			},
--		},
--	})

	TRP3_API.registerEffectEditor("document_show_html", {
		title = "Show HTML document",
		icon = "inv_icon_mission_complete_order",
		description = "Show an HTML document",
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. (args and args.name or UNKNOWN));
		end,
		getDefaultArgs = function()
			return {""};
		end,
	});
end