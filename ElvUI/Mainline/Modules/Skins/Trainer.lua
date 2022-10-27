local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, select, unpack = next, select, unpack

local hooksecurefunc = hooksecurefunc

function S:Blizzard_TrainerUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer) then return end

	for _, object in next, {
		_G.ClassTrainerScrollFrameScrollChild,
		_G.ClassTrainerFrameSkillStepButton,
		_G.ClassTrainerFrameBottomInset,
	} do
		object:StripTextures()
	end

	for _, texture in next, {
		_G.ClassTrainerFramePortrait,
		_G.ClassTrainerScrollFrameScrollBarBG,
		_G.ClassTrainerScrollFrameScrollBarTop,
		_G.ClassTrainerScrollFrameScrollBarBottom,
		_G.ClassTrainerScrollFrameScrollBarMiddle,
	} do
		texture:Kill()
	end

	for _, button in next, { _G.ClassTrainerTrainButton } do
		button:StripTextures()
		S:HandleButton(button)
	end

	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandlePortraitFrame(ClassTrainerFrame)

	hooksecurefunc(ClassTrainerFrame.ScrollBox, 'Update', function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.IsSkinned then
				S:HandleIcon(button.icon, true)
				button:CreateBackdrop('Transparent')
				button.backdrop:SetPoint('TOPLEFT', button.icon, 'TOPRIGHT', 1, 0)
				button.backdrop:SetPoint('BOTTOMRIGHT', button.icon, 'BOTTOMRIGHT', 253, 0)

				button.name:SetParent(button.backdrop)
				button.name:SetPoint('TOPLEFT', button.icon, 'TOPRIGHT', 6, -2)
				button.subText:SetParent(button.backdrop)
				button.money:SetParent(button.backdrop)
				button.money:SetPoint('TOPRIGHT', button, 'TOPRIGHT', 5, -8)

				button:SetNormalTexture(E.Media.Textures.Invisible)
				button:SetHighlightTexture(E.Media.Textures.Invisible)
				button.disabledBG:SetTexture()
				button.selectedTex:SetInside(button.backdrop)
				local r, g, b = unpack(E.media.rgbvaluecolor)
				button.selectedTex:SetColorTexture(r, g, b, .25)

				button.IsSkinned = true
			end
		end
	end)

	S:HandleTrimScrollBar(_G.ClassTrainerFrame.ScrollBar)
	S:HandleDropDownBox(_G.ClassTrainerFrameFilterDropDown, 155)

	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 5)
	ClassTrainerFrame:SetTemplate('Transparent')

	local stepButton = _G.ClassTrainerFrameSkillStepButton
	stepButton:SetTemplate()
	stepButton.icon:SetTexCoord(unpack(E.TexCoords))
	stepButton.selectedTex:SetColorTexture(1,1,1,0.3)
	_G.ClassTrainerFrameSkillStepButtonHighlight:SetColorTexture(1,1,1,0.3)

	local ClassTrainerStatusBar = _G.ClassTrainerStatusBar
	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:CreateBackdrop()
	ClassTrainerStatusBar.rankText:ClearAllPoints()
	ClassTrainerStatusBar.rankText:Point('CENTER', ClassTrainerStatusBar, 'CENTER')
	E:RegisterStatusBar(ClassTrainerStatusBar)
end

S:AddCallbackForAddon('Blizzard_TrainerUI')
