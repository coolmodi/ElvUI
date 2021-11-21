local PLUGIN_NAME = "HealCommBAPIexpo"
local E, _, _, P, _ = unpack(ElvUI)
local Plugin = E:NewModule(PLUGIN_NAME)
local EP = LibStub("LibElvUIPlugin-1.0")
local HealComm = LibStub("LibHealComm-4.0")

local active = false
local min = math.min
local max = math.max
local floor = math.floor
local DIRECT_HEALS = HealComm.DIRECT_HEALS
local BOMB_HEALS = HealComm.BOMB_HEALS
local HOT_HEALS = HealComm.HOT_HEALS
local CHANNEL_HEALS = HealComm.CHANNEL_HEALS
local playerGUID = UnitGUID("player")

---@class PendingHeal
---@field endTime number
---@field spellID number
---@field bitType number

---@class PendingDirect : PendingHeal
---@field stacks number|nil

---@class PendingHoT : PendingHeal
---@field startTime number
---@field duration number
---@field totalTicks number
---@field tickInterval number
---@field isMultiTarget boolean
---@field stack number

---Try to guess unknown incoming heal from players without HealComm.
---Add it if it's probably actually real outside of calculation differences.
-- TODO: Once API includes HoTs this needs to be revisited!
---@param unitId string
---@param otherIncommingTotal number
---@param ignoreOwnHeal boolean
local function GetAdditionalBlizzardAPIHeal(unitId, otherIncommingTotal, ignoreOwnHeal)
    local myIncomingHeal = ignoreOwnHeal and UnitGetIncomingHeals(unitId, "player") or 0
    local allIncomingHeal = UnitGetIncomingHeals(unitId) or 0
    local incomingFromOthersAPI = allIncomingHeal - myIncomingHeal
    -- This should make sure to catch heals if HC doesn't know anything,
    -- while preventing false positives on huge incoming heal amounts due to
    -- value differences between HealComm and the Blizzard API.
    -- The bigger the known heal the less we care about the unknown.
    local errorMargin = otherIncommingTotal * 0.1
    local unaccountedHeal = incomingFromOthersAPI - otherIncommingTotal - errorMargin
    if unaccountedHeal > 0 then
        return unaccountedHeal
    end
    return 0
end

---This will return direct incomming heal before our next direct heal, our direct heal and heal after that.
---Heal after will include all HoTs.
---Depending will also return additional healing found via the Blizzard API.
---@param dstGUID string The target unit GUID
---@param timeMax number Include healing up to this time, based on GetTime().
---@param unitId string
---@return number beforeOurDirect
---@return number ourDirect
---@return number afterOurDirect
---@return number overTime
---@return number blizzardHeal
function HealComm:GetHealAmountCM(dstGUID, timeMax, unitId)
    ---@type table<number, table<number, PendingDirect>>
    local pendingHeals = self.pendingHeals
    ---@type table<number, table<number, PendingHoT>>
    local pendingHots = self.pendingHots
	local beforeOurDirect = 0
    local ourDirect = 0
	local afterOurDirect = 0
	local overTime = 0
    local totalOtherIncomming = 0
    ---@type number
    local playerDirectTime = timeMax
    local playerIsCastingDirect = false
    local currTime = GetTime()

    -- Find player direct heal end time if player is casting a heal on the target
    if pendingHeals[playerGUID] then
        for _, pending in pairs(pendingHeals[playerGUID]) do
            if pending.bitType == DIRECT_HEALS then
                for i=1, #(pending), 5 do
                    local targetGUID = pending[i]
                    if targetGUID == dstGUID then
                        local endTime = pending[i + 3]
                        endTime = endTime > 0 and endTime or pending.endTime
                        if endTime <= playerDirectTime then
                            playerDirectTime = endTime
                        end
                        playerIsCastingDirect = true
                    end
                end
            end
        end
    end

	for _, tbl in ipairs({ pendingHeals, pendingHots }) do
		for casterGUID, spells in pairs(tbl) do
			if spells then
				for _, pending in pairs(spells) do
                    local bitType = pending.bitType or 0

					for i = 1, #pending, 5 do
                        local targetGUID = pending[i]
                        if targetGUID == dstGUID then
                            local amount = pending[i + 1]
                            local stack = pending[i + 2]
                            local endTime = pending[i + 3]

                            endTime = endTime > 0 and endTime or pending.endTime

                            if endTime > currTime then
                                amount = amount * stack

                                if bitType == DIRECT_HEALS then
                                    if endTime <= timeMax then
                                        if casterGUID == playerGUID then
                                            ourDirect = ourDirect + amount
                                        else
                                            if endTime <= playerDirectTime then
                                                beforeOurDirect = beforeOurDirect + amount
                                            else
                                                afterOurDirect = afterOurDirect + amount
                                            end
                                            totalOtherIncomming = totalOtherIncomming + amount
                                        end
                                    end
                                elseif bitType == BOMB_HEALS then
                                    if endTime <= timeMax then
                                        if endTime <= playerDirectTime then
                                            beforeOurDirect = beforeOurDirect + amount
                                        else
                                            afterOurDirect = afterOurDirect + amount
                                        end
                                        -- Blizzard API does not include HoTs! TODO: This may change at any point.
                                        -- If this changes this may need a GUID check too.
                                        --totalOtherIncomming = totalOtherIncomming + amount
                                    end
                                elseif bitType == HOT_HEALS or bitType == CHANNEL_HEALS then
                                    local ticksLeft = pending[i + 4]
                                    local ticks

                                    if timeMax >= endTime then
                                        ticks = ticksLeft
                                    else
                                        local tickInterval = pending.tickInterval
                                        local secondsLeft = endTime - currTime
                                        local bandSeconds = max(timeMax - currTime, 0)

                                        ticks = floor(min(bandSeconds, secondsLeft) / tickInterval)

                                        local nextTickIn = secondsLeft % tickInterval
                                        local fractionalBand = bandSeconds % tickInterval

                                        if nextTickIn > 0 and nextTickIn < fractionalBand then
                                            ticks = ticks + 1
                                        end
                                    end

                                    if ticks > ticksLeft then
                                        ticks = ticksLeft
                                    end

                                    overTime = overTime + amount * ticks
                                    -- Blizzard API does not include HoTs! TODO: This may change at any point.
                                    -- if casterGUID ~= playerGUID then
                                    --     totalOtherIncomming = totalOtherIncomming + amount * ticksLeft
                                    -- end
                                end
                            end
                        end
                    end
				end
			end
		end
	end

    local blizzardHeal = 0
    if active then
        blizzardHeal = GetAdditionalBlizzardAPIHeal(unitId, totalOtherIncomming, playerIsCastingDirect)
    end

    --print(currTime, " Healing on " .. unitId .. ": ", beforeOurDirect, ourDirect, afterOurDirect, overTime, blizzardHeal)
	return beforeOurDirect, ourDirect, afterOurDirect, overTime, blizzardHeal
end

---------------------------------
-- ElvUI module stuff
---------------------------------

P[PLUGIN_NAME] = {
	["active"] = false,
}

function Plugin:Update()
	active = E.db[PLUGIN_NAME].active
end

function Plugin:InsertOptions()
	E.Options.args[PLUGIN_NAME] = {
		order = 100,
		type = "group",
		name = PLUGIN_NAME,
		args = {
			active = {
				order = 1,
				type = "toggle",
				name = "Try to include non-HealComm heal into predictions?",
				get = function(info)
					return E.db[PLUGIN_NAME].active
				end,
				set = function(info, value)
					E.db[PLUGIN_NAME].active = value
					Plugin:Update()
				end,
			},
		},
	}
end

function Plugin:Initialize()
	EP:RegisterPlugin(PLUGIN_NAME, Plugin.InsertOptions)
    self:Update()
end

E:RegisterModule(Plugin:GetName())