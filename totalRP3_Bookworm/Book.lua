local _, Bookworm = ...;

local Book = {};
Bookworm.book = Book;

function Book.init()
	-- Local import of global functions
	local ItemTextGetMaterial = ItemTextGetMaterial;
	local select = select;


	-- Get the number of the current page
	Book.getPageNumber = ItemTextGetPage;
	-- Go to previous page
	Book.previousPage = ItemTextPrevPage;
	-- Go to next page
	Book.nextPage = ItemTextNextPage;
	-- Return true if a next page exists
	Book.hasNextPage = ItemTextHasNextPage;
	-- Get information about an item by its name
	Book.getInfo = GetItemInfoInstant;
	-- Get the name of the item (book; parchment; letter; plaque)
	Book.getItem = ItemTextGetItem;
	-- Get the name of the creator of the letter; if there is one
	Book.author = ItemTextGetCreator;
	-- Get the text from the page being displayed
	Book.getText = ItemTextGetText;

	-- Return true if an author exists for the document (only for letters)
	Book.hasAuthor = function()
		return Book.author() ~= nil;
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
		return select(5, Book.getInfo(Book.getItem()));
	end
end

