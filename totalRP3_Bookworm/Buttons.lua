local _, Bookworm = ...;

local button = TRP3_BookwormButton;
local SetCursor = SetCursor;

Bookworm.buttons = {};

function Bookworm.buttons.init()

	function Bookworm.buttons.showButton()
		button:Show();
	end

	function Bookworm.buttons.showCheckmark()
		button.icon:SetVertexColor(0.5, 0.5, 0.5);
		button.checked:Show();
	end

	function Bookworm.buttons.hideCheckmark()
		button.icon:SetVertexColor(1, 1, 1);
		button.checked:Hide();
	end

	function Bookworm.buttons.hideButton()
		button:Hide();
		Bookworm.buttons.hideCheckmark();
	end

	function Bookworm.buttons.setIconTexture(icon)
		button.icon:SetTexture(icon);
	end

	local function showTooltip()
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT") --Set our button as the tooltip's owner and attach it to the top right corner of the button.
		if button.checked:IsVisible() then
			GameTooltip:SetText("Item already exists.", nil, nil, nil, nil, true)
		else
			GameTooltip:SetText("Copy item to Total RP 3.", nil, nil, nil, nil, true);
		end
		GameTooltip:Show() --Show the tooltip
	end

	local function setCursorAndHighlight()
		if not button.checked:IsVisible() then
			button.highlight:Show();
			SetCursor("Interface\\CURSOR\\Pickup");
		else
			button.highlight:Hide();
			SetCursor(nil);

		end
	end

	button:SetScript("OnClick", function()
		Bookworm.API.onButtonClicked();
		setCursorAndHighlight();
		GameTooltip:Hide();
	end)
	button:SetScript("OnEnter", function()
		setCursorAndHighlight();
		showTooltip();
	end);
	button:SetScript("OnLeave", function()
		button.highlight:Hide();
		SetCursor(nil);
		GameTooltip:Hide();
	end);
end