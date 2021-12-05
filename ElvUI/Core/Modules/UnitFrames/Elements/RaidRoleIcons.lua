local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local strfind = strfind
local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooterIndicator = anchor:CreateTexture(nil, 'OVERLAY')
    frame.RaidRoleIndicator = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(24, 12)
	anchor:SetFrameLevel(frame.RaisedElementParent.RaidRoleLevel)

	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	frame.MasterLooterIndicator:Size(12)
    frame.RaidRoleIndicator:Size(12)

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooterIndicator.PostUpdate = UF.RaidRoleUpdate
    frame.RaidRoleIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('LeaderIndicator') then
			frame:EnableElement('LeaderIndicator')
			frame:EnableElement('AssistantIndicator')
			frame:EnableElement('MasterLooterIndicator')
            frame:EnableElement('RaidRoleIndicator')
		end

		raidRoleFrameAnchor:ClearAllPoints()
		raidRoleFrameAnchor:Point(frame.db.raidRoleIcons.position, frame, frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
		frame:DisableElement('MasterLooterIndicator')
        frame:DisableElement('RaidRoleIndicator')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterlooter = frame.MasterLooterIndicator
    local raidRole = frame.RaidRoleIndicator

	if not leader or not assistant or not masterlooter or not raidRole then return end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()
    local isRole = raidRole:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterlooter:ClearAllPoints()
    raidRole:ClearAllPoints()

	if db and db.raidRoleIcons then
		local pos, x, y = db.raidRoleIcons.position, db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset

		local right = strfind(pos, 'RIGHT')
		local pos1 = right and 'RIGHT' or 'LEFT'
		local pos2 = right and 'LEFT' or 'RIGHT'

        local elems = {}
        if isLeader then table.insert(elems, leader) end
        if isAssist then table.insert(elems, assistant) end
        if isRole then table.insert(elems, raidRole) end
        table.insert(elems, masterlooter)

        for i = 1, #elems do
            if i == 1 then
                elems[i]:Point(pos, anchor, x, y)
            else
                elems[i]:Point(pos1, elems[i-1], pos2)
            end
        end
	end
end
