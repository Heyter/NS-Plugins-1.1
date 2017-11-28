local PLUGIN = PLUGIN
PLUGIN.name = "Equipment armor"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "armor, different types of damage and deflection."

nut.util.include("sv_plugin.lua")
nut.util.include("cl_vgui.lua")

local MOVETYPE_NONE = MOVETYPE_NONE

function PLUGIN:Move(client, mv)
	if (client:GetMoveType() == MOVETYPE_NONE) then return end
	
	local char = client:getChar()
	local f,s = mv:GetMaxClientSpeed(), mv:GetMaxSpeed()
	local speed = client:getNetVar("armorSpeed", 1)

	if (char and speed) then
		mv:SetMaxClientSpeed(f * speed)
		mv:SetMaxSpeed(s * speed)
	end
end