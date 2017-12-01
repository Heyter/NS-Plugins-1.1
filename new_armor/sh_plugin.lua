local PLUGIN = PLUGIN
PLUGIN.name = "Equipment armor"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "armor, different types of damage and deflection."

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

if (SERVER) then
	local pairs, IsValid = pairs, IsValid
	function PLUGIN:EntityTakeDamage(entity, dmginfo)
		if (IsValid(entity) and entity:IsPlayer() and dmginfo:GetDamage() > 0) then
			local char = entity:getChar()
			if (char) then
				local inv = char:getInv()
				if (inv and inv.getItems) then
					for k, v in pairs(inv:getItems()) do
						if (v.armorClass and v:getData("equip")) then
							local dmg = v.resistData[dmginfo:GetDamageType()]
							if (dmg) then
								dmginfo:ScaleDamage(dmg)
								--break
								--dmginfo:SetDamage(dmginfo:GetDamage() * dmg)
							end
						end
					end
				end
			end
		end
	end
end