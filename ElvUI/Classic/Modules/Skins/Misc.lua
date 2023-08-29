local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, ipairs, unpack = pairs, ipairs, unpack

local hooksecurefunc = hooksecurefunc
local UnitIsUnit = UnitIsUnit
local CreateFrame = CreateFrame

local function NavButtonXOffset(button, point, anchor, point2, _, yoffset, skip)
	if not skip then
		button:Point(point, anchor, point2, 1, yoffset, true)
	end
end

local function SkinNavBarButtons(self)
	if (self:GetParent():GetName() == 'EncounterJournal' and not E.private.skins.blizzard.encounterjournal) or (self:GetParent():GetName() == 'WorldMapFrame' and not E.private.skins.blizzard.worldmap) or (self:GetParent():GetName() == 'HelpFrameKnowledgebase' and not E.private.skins.blizzard.help) then
		return
	end

	local total = #self.navList
	local navButton = self.navList[total]
	if navButton and not navButton.isSkinned then
		S:HandleButton(navButton, true)
		navButton:GetFontString():SetTextColor(1, 1, 1)
		if navButton.MenuArrowButton then
			navButton.MenuArrowButton:StripTextures()
			if navButton.MenuArrowButton.Art then
				navButton.MenuArrowButton.Art:SetTexture(E.Media.Textures.ArrowUp)
				navButton.MenuArrowButton.Art:SetTexCoord(0, 1, 0, 1)
				navButton.MenuArrowButton.Art:SetRotation(3.14)
			end
		end

		if total == 2 then
			-- EJ.navBar.home.xoffset = 1 (this causes a taint, use the hook below instead)
			NavButtonXOffset(navButton, navButton:GetPoint())
			hooksecurefunc(navButton, 'SetPoint', NavButtonXOffset)
		end

		navButton.xoffset = 1
		navButton.isSkinned = true
	end
end

local function ClearSetTexture(texture, tex)
	if tex ~= nil then
		texture:SetTexture()
	end
end

function S:BlizzardMiscFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	-- Blizzard frame we want to reskin
	local skins = {
		'AutoCompleteBox',
		'ReadyCheckFrame'
	}

	for i = 1, #skins do
		_G[skins[i]]:StripTextures()
		_G[skins[i]]:SetTemplate('Transparent')
	end

	-- here we reskin all 'normal' buttons
	S:HandleButton(_G.ReadyCheckFrameYesButton)
	S:HandleButton(_G.ReadyCheckFrameNoButton)

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 3, -5)
	_G.ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point('TOP', 0, -15)

	_G.ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript('OnShow', function(self)
		-- bug fix, don't show it if player is initiator
		if self.initiator and UnitIsUnit('player', self.initiator) then
			self:Hide()
		end
	end)

	S:HandleButton(_G.StaticPopup1ExtraButton)

	if not E:IsAddOnEnabled('ConsolePortUI_Menu') then
		-- reskin all esc/menu buttons
		for _, Button in pairs({_G.GameMenuFrame:GetChildren()}) do
			if Button.IsObjectType and Button:IsObjectType('Button') then
				S:HandleButton(Button)
			end
		end

		_G.GameMenuFrame:StripTextures()
		_G.GameMenuFrame:SetTemplate('Transparent')
		_G.GameMenuFrameHeader:SetTexture()
		_G.GameMenuFrameHeader:ClearAllPoints()
		_G.GameMenuFrameHeader:Point('TOP', _G.GameMenuFrame, 0, 7)
	end

	if E:IsAddOnEnabled('OptionHouse') then
		S:HandleButton(_G.GameMenuButtonOptionHouse)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_OnDisplaySizeChanged', function(s)
		if s and s.closeDialog and not s.closeDialog.template then
			s.closeDialog:StripTextures()
			s.closeDialog:SetTemplate('Transparent')
			s:SetScale(E.uiscale)

			local dialogName = s.closeDialog.GetName and s.closeDialog:GetName()
			local closeButton = s.closeDialog.ConfirmButton or (dialogName and _G[dialogName..'ConfirmButton'])
			local resumeButton = s.closeDialog.ResumeButton or (dialogName and _G[dialogName..'ResumeButton'])
			if closeButton then S:HandleButton(closeButton) end
			if resumeButton then S:HandleButton(resumeButton) end
		end
	end)

	-- same as above except `MovieFrame_OnEvent` and `MovieFrame_OnShow`
	-- cant be hooked directly so we can just use this
	-- this is called through `MovieFrame_OnEvent` on the event `PLAY_MOVIE`
	hooksecurefunc('MovieFrame_PlayMovie', function(s)
		if s and s.CloseDialog and not s.CloseDialog.template then
			s:SetScale(E.uiscale)
			s.CloseDialog:StripTextures()
			s.CloseDialog:SetTemplate('Transparent')
			S:HandleButton(s.CloseDialog.ConfirmButton)
			S:HandleButton(s.CloseDialog.ResumeButton)
		end
	end)

	local ChatMenus = {
		_G.ChatMenu,
		_G.EmoteMenu,
		_G.LanguageMenu,
		_G.VoiceMacroMenu,
	}

	for _, frame in ipairs(ChatMenus) do
		if frame == _G.ChatMenu then
			frame:HookScript('OnShow', function(menu) menu:SetTemplate('Transparent', true) menu:SetBackdropColor(unpack(E.media.backdropfadecolor)) menu:ClearAllPoints() menu:Point('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', 0, 30) end)
		else
			frame:HookScript('OnShow', function(menu) menu:SetTemplate('Transparent', true) menu:SetBackdropColor(unpack(E.media.backdropfadecolor)) end)
		end
	end

	-- Emotes NineSlice
	_G.ChatMenu.NineSlice:SetTemplate()

	-- reskin popup buttons
	for i = 1, 4 do
		local StaticPopup = _G['StaticPopup'..i]
		StaticPopup:HookScript('OnShow', function() -- UpdateRecapButton is created OnShow
			if StaticPopup.UpdateRecapButton and (not StaticPopup.UpdateRecapButtonHooked) then
				StaticPopup.UpdateRecapButtonHooked = true -- we should only hook this once
				hooksecurefunc(_G['StaticPopup'..i], 'UpdateRecapButton', S.UpdateRecapButton)
			end
		end)
		StaticPopup:StripTextures()
		StaticPopup:SetTemplate('Transparent')

		for j = 1, 4 do
			local button = StaticPopup['button'..j]
			S:HandleButton(button)

			button.Flash:Hide()

			button:CreateShadow(5)
			button.shadow:SetAlpha(0)
			button.shadow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

			local anim1, anim2 = button.PulseAnim:GetAnimations()
			anim1:SetTarget(button.shadow)
			anim2:SetTarget(button.shadow)
		end

		_G['StaticPopup'..i..'EditBox']:SetFrameLevel(_G['StaticPopup'..i..'EditBox']:GetFrameLevel()+1)
		S:HandleEditBox(_G['StaticPopup'..i..'EditBox'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameGold'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameSilver'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameCopper'])
		_G['StaticPopup'..i..'EditBox'].backdrop:Point('TOPLEFT', -2, -4)
		_G['StaticPopup'..i..'EditBox'].backdrop:Point('BOTTOMRIGHT', 2, 4)
		_G['StaticPopup'..i..'ItemFrameNameFrame']:Kill()
		_G['StaticPopup'..i..'ItemFrame']:SetTemplate()
		_G['StaticPopup'..i..'ItemFrame']:StyleButton()
		_G['StaticPopup'..i..'ItemFrame'].IconBorder:SetAlpha(0)
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetTexCoord(unpack(E.TexCoords))
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetInside()

		local normTex = _G['StaticPopup'..i..'ItemFrame']:GetNormalTexture()
		if normTex then
			normTex:SetTexture()
			hooksecurefunc(normTex, 'SetTexture', ClearSetTexture)
		end

		S:HandleIconBorder(_G['StaticPopup'..i..'ItemFrame'].IconBorder)
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	--DropDownMenu
	hooksecurefunc('UIDropDownMenu_CreateFrames', function(level, index)
		local listFrame = _G['DropDownList'..level]
		local listFrameName = listFrame:GetName()
		local expandArrow = _G[listFrameName..'Button'..index..'ExpandArrow']
		if expandArrow then
			local normTex = expandArrow:GetNormalTexture()
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)
			normTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
			normTex:SetRotation(S.ArrowRotation.right)
			expandArrow:Size(12)
		end

		local Backdrop = _G[listFrameName..'Backdrop']
		if Backdrop and not Backdrop.template then
			Backdrop:StripTextures()
			Backdrop:SetTemplate('Transparent')
		end

		local menuBackdrop = _G[listFrameName..'MenuBackdrop']
		if menuBackdrop and not menuBackdrop.template then
			menuBackdrop.NineSlice:SetTemplate('Transparent')
		end
	end)

	hooksecurefunc('UIDropDownMenu_SetIconImage', function(icon, texture)
		if texture:find('Divider') then
			local r, g, b = unpack(E.media.rgbvaluecolor)
			icon:SetColorTexture(r, g, b, 0.45)
			icon:Height(1)
		end
	end)

	hooksecurefunc('ToggleDropDownMenu', function(level)
		if ( not level ) then
			level = 1
		end

		local r, g, b = unpack(E.media.rgbvaluecolor)

		for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G['DropDownList'..level..'Button'..i]
			local check = _G['DropDownList'..level..'Button'..i..'Check']
			local uncheck = _G['DropDownList'..level..'Button'..i..'UnCheck']
			local highlight = _G['DropDownList'..level..'Button'..i..'Highlight']
			local text = _G['DropDownList'..level..'Button'..i..'NormalText']

			highlight:SetTexture(E.Media.Textures.Highlight)
			highlight:SetBlendMode('BLEND')
			highlight:SetDrawLayer('BACKGROUND')
			highlight:SetVertexColor(r, g, b)

			if not button.backdrop then
				button:CreateBackdrop()
			end

			button.backdrop:Hide()

			if not button.notCheckable then
				S:HandlePointXY(text, 5)

				uncheck:SetTexture()
				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
					check:SetVertexColor(r, g, b, 1)
					check:Size(20)
					check:SetDesaturated(true)
					button.backdrop:SetInside(check, 4, 4)
				else
					check:SetTexture(E.media.normTex)
					check:SetVertexColor(r, g, b, 1)
					check:Size(10)
					check:SetDesaturated(false)
					button.backdrop:SetOutside(check)
				end

				button.backdrop:Show()
				check:SetTexCoord(0, 1, 0, 1)
			else
				check:Size(16)
			end
		end
	end)

	local SideDressUpFrame = _G.SideDressUpFrame
	S:HandleCloseButton(_G.SideDressUpModelCloseButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	S:HandleButton(_G.SideDressUpModelResetButton)
	SideDressUpFrame:SetTemplate('Transparent')

	-- StackSplit
	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:CreateBackdrop('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:Point('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:Point('BOTTOMRIGHT', -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(_G.StackSplitOkayButton)
	S:HandleButton(_G.StackSplitCancelButton)

	local buttons = {StackSplitFrame.LeftButton, StackSplitFrame.RightButton}
	for _, btn in pairs(buttons) do
		btn:Size(14, 18)

		btn:ClearAllPoints()

		if btn == StackSplitFrame.LeftButton then
			btn:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			btn:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(btn)

		if btn.SetTemplate then
			btn:SetTemplate('NoBackdrop')
		end
	end

	--NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', SkinNavBarButtons)
end

S:AddCallback('BlizzardMiscFrames')
