--[[----------------------------------------------------------------------------
	Vendor Search
	Adds a search box to the merchant window that filters the item list.

	How it works
	------------
	Rather than re-implementing Blizzard's merchant layout code (which changes
	between patches), we let Blizzard draw the page as usual, but for the
	duration of that single call we swap the merchant query API for wrappers
	that translate a "filtered" index into the real merchant index. After the
	draw we restore the real API and point each item button's ID at the real
	merchant index, so buying, tooltips, stack splitting and extended-cost
	confirmation all keep working through the untouched Blizzard code paths.
------------------------------------------------------------------------------]]

local ADDON = ...

-- Search box placement. ElvUI's merchant skin strips the portrait and pulls the
-- item rows up, leaving almost no header room; the default Blizzard frame has a
-- wide empty band between the title bar and the first row. So: two presets.
local PLACEMENT = {
	elvui   = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -30, y = -18, width = 110, height = 18 },
	default = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -40, y = -34, width = 130, height = 20 },
}

local ITEMS_PER_PAGE = MERCHANT_ITEMS_PER_PAGE or 10

--------------------------------------------------------------------------------
-- Filter state
--------------------------------------------------------------------------------

local tokens = {}       -- lowercased search terms; all must match
local map = {}          -- filtered index -> real merchant index
local numFiltered = 0
local searchBox         -- forward declaration

local function IsFiltering()
	return #tokens > 0 and MerchantFrame and MerchantFrame.selectedTab == 1
end

local function SetSearchText(text)
	wipe(tokens)
	for word in string.gmatch(string.lower(text or ""), "%S+") do
		tokens[#tokens + 1] = word
	end
end

local function Matches(name)
	-- Unnamed items (not yet cached) are kept rather than silently dropped.
	if not name or name == "" then return true end
	name = string.lower(name)
	for i = 1, #tokens do
		if not string.find(name, tokens[i], 1, true) then
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- Merchant API remapping
--------------------------------------------------------------------------------

local orig = {
	GetMerchantNumItems     = GetMerchantNumItems,
	GetMerchantItemInfo     = GetMerchantItemInfo,
	GetMerchantItemLink     = GetMerchantItemLink,
	GetMerchantItemCostInfo = GetMerchantItemCostInfo,
	GetMerchantItemCostItem = GetMerchantItemCostItem,
	GetMerchantItemMaxStack = GetMerchantItemMaxStack,
	CanAffordMerchantItem   = CanAffordMerchantItem,
}

local function Real(index)
	return map[index] or index
end

local wrapped = {
	GetMerchantNumItems     = function() return numFiltered end,
	GetMerchantItemInfo     = function(i) return orig.GetMerchantItemInfo(Real(i)) end,
	GetMerchantItemLink     = function(i) return orig.GetMerchantItemLink(Real(i)) end,
	GetMerchantItemCostInfo = function(i) return orig.GetMerchantItemCostInfo(Real(i)) end,
	GetMerchantItemCostItem = function(i, n) return orig.GetMerchantItemCostItem(Real(i), n) end,
	GetMerchantItemMaxStack = function(i) return orig.GetMerchantItemMaxStack(Real(i)) end,
	CanAffordMerchantItem   = function(i) return orig.CanAffordMerchantItem(Real(i)) end,
}

-- Some of these are absent in older builds; don't install a wrapper for a nil.
for name, fn in pairs(orig) do
	if type(fn) ~= "function" then
		orig[name] = nil
		wrapped[name] = nil
	end
end

local function SwapIn()
	for name, fn in pairs(wrapped) do _G[name] = fn end
end

local function SwapOut()
	for name, fn in pairs(orig) do _G[name] = fn end
end

local function BuildMap()
	wipe(map)
	local total = orig.GetMerchantNumItems() or 0
	for i = 1, total do
		if Matches((orig.GetMerchantItemInfo(i))) then
			map[#map + 1] = i
		end
	end
	numFiltered = #map
end

-- After Blizzard has drawn the page using filtered indices, re-point the
-- buttons at the real merchant indices so every click path stays correct.
local function RemapButtonIDs()
	local base = (MerchantFrame.page - 1) * ITEMS_PER_PAGE
	for i = 1, ITEMS_PER_PAGE do
		local button = _G["MerchantItem" .. i .. "ItemButton"]
		local realIndex = map[base + i]
		if button and realIndex then
			button:SetID(realIndex)
		end
	end
end

--------------------------------------------------------------------------------
-- Hook the merchant page draw
--------------------------------------------------------------------------------

local origUpdateMerchantInfo = MerchantFrame_UpdateMerchantInfo

function MerchantFrame_UpdateMerchantInfo(...)
	if not IsFiltering() then
		if searchBox then searchBox.noResults:Hide() end
		return origUpdateMerchantInfo(...)
	end

	BuildMap()

	local maxPages = math.max(1, math.ceil(numFiltered / ITEMS_PER_PAGE))
	if not MerchantFrame.page or MerchantFrame.page > maxPages then
		MerchantFrame.page = maxPages
	elseif MerchantFrame.page < 1 then
		MerchantFrame.page = 1
	end

	SwapIn()
	local ok, err = pcall(origUpdateMerchantInfo, ...)
	SwapOut()

	RemapButtonIDs()
	searchBox.noResults:SetShown(numFiltered == 0)

	if not ok then
		geterrorhandler()(err)
	end
end

--------------------------------------------------------------------------------
-- Search box
--------------------------------------------------------------------------------

local function Refresh()
	if not MerchantFrame:IsShown() then return end
	MerchantFrame.page = 1
	MerchantFrame_Update()
end

searchBox = CreateFrame("EditBox", "VendorSearchBox", MerchantFrame, "SearchBoxTemplate")
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(50)
searchBox:SetFrameLevel(MerchantFrame:GetFrameLevel() + 4)

-- True only when ElvUI is loaded *and* actually skinning the merchant frame --
-- ElvUI can be installed with Blizzard-frame skinning switched off, in which
-- case the frame is the default one and wants the default placement.
local function ElvUISkinsMerchant()
	local ElvUI = _G.ElvUI
	local E = ElvUI and ElvUI[1]
	local blizzard = E and E.private and E.private.skins and E.private.skins.blizzard
	return (blizzard and blizzard.enable and blizzard.merchant) and true or false
end

local function ApplyPlacement()
	local p = ElvUISkinsMerchant() and PLACEMENT.elvui or PLACEMENT.default
	searchBox:SetSize(p.width, p.height)
	searchBox:ClearAllPoints()
	searchBox:SetPoint(p.point, MerchantFrame, p.relPoint, p.x, p.y)
end

ApplyPlacement()

if searchBox.Instructions then
	searchBox.Instructions:SetText(SEARCH or "Search")
end

searchBox:HookScript("OnTextChanged", function(self)
	local text = self:GetText()
	if text == self.lastText then return end
	self.lastText = text
	SetSearchText(text)
	Refresh()
end)

searchBox:SetScript("OnEscapePressed", function(self)
	self:SetText("")
	self:ClearFocus()
end)

searchBox:SetScript("OnEnterPressed", function(self)
	self:ClearFocus()
end)

searchBox.noResults = MerchantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
searchBox.noResults:SetPoint("CENTER", MerchantFrame, "CENTER", 0, 20)
searchBox.noResults:SetText(BROWSE_NO_RESULTS or "No matching items.")
searchBox.noResults:Hide()

-- Only meaningful on the Merchant tab, not Buyback.
hooksecurefunc("MerchantFrame_Update", function()
	local onMerchantTab = MerchantFrame.selectedTab == 1
	searchBox:SetShown(onMerchantTab)
	if not onMerchantTab then
		searchBox.noResults:Hide()
	end
end)

--------------------------------------------------------------------------------
-- Reset between vendors
--------------------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("MERCHANT_SHOW")
events:RegisterEvent("MERCHANT_CLOSED")
events:SetScript("OnEvent", function(_, event)
	-- Re-checked per vendor: ElvUI initialises after us, and profile switches
	-- can turn the merchant skin on or off mid-session.
	if event == "MERCHANT_SHOW" then
		ApplyPlacement()
	end
	searchBox:SetText("")
	searchBox.lastText = ""
	searchBox:ClearFocus()
	wipe(tokens)
	wipe(map)
	numFiltered = 0
	searchBox.noResults:Hide()
end)

--------------------------------------------------------------------------------
-- /vs <text> for keyboard users
--------------------------------------------------------------------------------

SLASH_VENDORSEARCH1 = "/vs"
SLASH_VENDORSEARCH2 = "/vendorsearch"
SlashCmdList["VENDORSEARCH"] = function(msg)
	if not MerchantFrame:IsShown() then
		print("|cff33ff99Vendor Search|r: open a vendor first.")
		return
	end
	searchBox:SetText(msg or "")
	searchBox:SetFocus()
end
