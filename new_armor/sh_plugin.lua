local PLUGIN = PLUGIN
PLUGIN.name = "Equipment armor"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "armor, different types of damage and deflection."

nut.util.include("sv_plugin.lua")
nut.util.include("cl_vgui.lua")

function PLUGIN:Move(client, mv)
	if (client:GetMoveType() != MOVETYPE_WALK) then return end
	
	local char = client:getChar()
	local f,s = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local speed = client:getNetVar("armorSpeed", 1)

	if (char and speed) then
		mv:SetForwardSpeed(f * speed)
		mv:SetSideSpeed(s * speed)
	end
end