local PLUGIN_NAME = "MainTankColor";
local E, L, V, P, G = unpack(ElvUI);
local oUF = E.oUF;
local Plugin = E:NewModule(PLUGIN_NAME);
local EP = LibStub("LibElvUIPlugin-1.0");

local TAG_NAME = "tankc";

---------------------------------
-- Add tags
---------------------------------

oUF.Tags.Events[TAG_NAME] = "RAID_ROSTER_UPDATE";
oUF.Tags.Methods[TAG_NAME] = function(unit)
    if GetPartyAssignment('MAINTANK', unit) then
        return "|cFFff3e3e";
    end
    return "";
end

---------------------------------
-- ElvUI module stuff
---------------------------------

function Plugin:Update()

end

function Plugin:InsertOptions()

end

function Plugin:Initialize()
	EP:RegisterPlugin(PLUGIN_NAME, Plugin.InsertOptions);
	-- E:AddTagInfo(TAG_HEALPREDICTION, "Health", "Displays HP deficit with HealComm prediction");
    self:Update();
end

E:RegisterModule(Plugin:GetName());