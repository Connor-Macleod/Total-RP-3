--
-- Bookworm.lua
-- By Ellypse
-- Date: 13/10/2014
-- Core of the addon, bridges Book and totalRP2_API. Utilizes Book to get the information from the current document and totalRP2_API to
-- create a document in Total RP 2.
-- Licence : CC BY-NC-SA (http://creativecommons.org/licenses/)
--

local _, Bookworm = ...;

Bookworm.API = {};

function Bookworm.API.init()

	local log = Bookworm.log;
	local TRP3 = {
		generateID = TRP3_API.utils.str.id,
		getDocumentItemData = TRP3_API.extended.tools.getDocumentItemData,
		createItem = TRP3_API.extended.tools.createItem,
	}
	local tinsert = tinsert;

	-- Default icons to use when the document is not from an item
	Bookworm.API.DEFAULT_ICONS = {
		Parchment = "INV_Misc_Book_03",
		Bronze = "inv_misc_wartornscrap_plate",
		Silver = "inv_misc_wartornscrap_plate",
		Stone = "INV_Misc_StoneTablet_04",
		Marble = "INV_Misc_StoneTablet_03",
		default = "INV_Misc_Book_03",
	}

	Bookworm.API.DOCUMENT_TYPE = {
		Parchment = "Book",
		Bronze = "Plaque",
		Silver = "Plaque",
		Stone = "Plaque",
		Marble = "Plaque",
	}

	Bookworm.API.TITLE_PAGE = [[
{p:c}{/p}




{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]
	Bookworm.API.NORMAL_PAGE = [[{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]];
	Bookworm.API.TITLED_PAGE = [[{p:c}{/p}
{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]

	local function getIconForMaterial(material)
		return Bookworm.API.DEFAULT_ICONS[material] or Bookworm.defaultIcons.default;
	end

	local function createItem()
		local id = TRP3.generateID();
		return TRP3.createItem(TRP3.getDocumentItemData(id), id);
	end

	local function documentAlreadyExists(documentName)
		for _, item in pairs(TRP3_DB.global) do
			if item.BA.NA == documentName then
				return true;
			end
		end
		return false;
	end

	function Bookworm.API.onItemTextReady()
		Bookworm.buttons.showButton();

		local itemIcon = Bookworm.book.getItemIcon() or "Interface\\ICONS\\" .. getIconForMaterial(Bookworm.book.getMaterial());

		Bookworm.buttons.setIconTexture(itemIcon);

		if documentAlreadyExists(Bookworm.book.getItem()) then
			Bookworm.buttons.showCheckmark();
		end
	end

	function Bookworm.API.onItemTextClosed()
		Bookworm.buttons.hideButton();
	end

	function Bookworm.API.onButtonClicked()
		local itemID, item = createItem();

		-- Add opening sound on use
		item.SC.onUse.ST["2"] = {
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
		};
		item.SC.onUse.ST["1"].n = "2";

		item.BA.NA = Bookworm.book.getItem();
		if Bookworm.book.author() then
			item.BA.LE = ITEM_TEXT_FROM .. " " .. Bookworm.book.author();
		end
		item.BA.IC = getIconForMaterial(Bookworm.book.getMaterial()); -- Bookworm.book.getItemIcon() or

		local content = item.IN.doc;
		content.PA = {};

		local currentPageNumber = Bookworm.book.getPageNumber();

		local title = item.BA.NA;

		if item.BA.LE then
			title = title ..",\n" .. item.BA.LE;
		end

		Bookworm.book.goToFirstPage();
		tinsert(content.PA, {
			TX = Bookworm.API.TITLED_PAGE:format(title) .. Bookworm.book.getText();
		})
		while(Bookworm.book.hasNextPage()) do
			Bookworm.book.nextPage();
			tinsert(content.PA, {
				TX = Bookworm.API.NORMAL_PAGE .. Bookworm.book.getText();
			})
		end
		Bookworm.book.goToPage(currentPageNumber);

		TRP3_API.inventory.addItem(nil, itemID, {count = 1});
		TRP3_API.ui.misc.playSoundKit(1184);

		TRP3_API.events.fireEvent(TRP3_API.events.ON_OBJECT_UPDATED);
		Bookworm.buttons.showCheckmark();
	end
end