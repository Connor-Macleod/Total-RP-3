----------------------------------------------------------------------------------
--  Total RP 3: Bookworm
--  Book API
--  A layer of abstraction on top of WoW's API for getting info about an Item Text item.
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

Bookworm.Book = {};
local Book = Bookworm.Book;

function Book.init()
	-- Local import of global functions
	local ItemTextGetMaterial = ItemTextGetMaterial;
	local find = string.find;

	-- Get the number of the current page
	Book.getPageNumber = ItemTextGetPage;
	-- Go to previous page
	Book.previousPage = ItemTextPrevPage;
	-- Go to next page
	Book.nextPage = ItemTextNextPage;
	-- Return true if a next page exists
	Book.hasNextPage = ItemTextHasNextPage;
	-- Get the name of the item (book; parchment; letter; plaque)
	Book.getItem = ItemTextGetItem;
	-- Get information about an item by its name
	Book.getInfo = function()
		return GetItemInfoInstant(Book.getItem());
	end;
	-- Get the name of the creator of the letter; if there is one
	Book.getAuthor = ItemTextGetCreator;
	-- Get the text from the page being displayed
	Book.getText = ItemTextGetText;

	setfenv(1, Bookworm);

	-- Return true if an author exists for the document (only for letters)
	Book.hasAuthor = function()
		return Book.getAuthor() ~= nil;
	end

	-- Return the type of material for the document
	-- Parchment, Bronze, Silver, Stone or Marble
	Book.getMaterial = function()
		return ItemTextGetMaterial() or "Parchment";
	end

	-- Go back to the first page of the book
	Book.goToFirstPage = function()
		while Book.getPageNumber() > 1 do
			Book.previousPage();
		end
	end

	-- Go to the last page of the book
	Book.goToLastPage = function()
		while Book.hasNextPage() do
			Book.nextPage();
		end
	end

	-- Go to a specific page in the book
	Book.goToPage = function(pageNumer)
		Book.goToFirstPage();
		while Book.getPageNumber() ~= pageNumer do
			Book.nextPage();
		end
	end

	function Book.currentPageIsHTML()
		local text = Book.getText();
		return find(text, "<HTML>") == 1;
	end

	function Book.getNumberOfPages()
		local currentPage = Book.getPageNumber();
		local numberOfPages = 1;
		Book.goToFirstPage();
		while(Book.hasNextPage()) do
			numberOfPages = numberOfPages + 1;
			Book.nextPage();
		end
		Book.goToPage(currentPage);
		return numberOfPages;
	end

	-- Return the icon of the item used to display the document
	Book.getItemIcon = function()
		local itemID, itemType, itemSubType, itemEquipLoc, iconFileDataID, itemClassID, itemSubClassID = Book.getInfo();
		return iconFileDataID;
	end
end

