local pairs, IsValid = pairs, IsValid
function PLUGIN:EntityTakeDamage(entity, dmginfo)
	if (IsValid(entity) and entity:IsPlayer()) then
		local char = entity:getChar()
		if (char) then
			local inv = char:getInv()
			for k, v in pairs(inv:getItems()) do
				if (v.armorClass and v:getData("equip")) then
					local dmg = v.resistData[dmginfo:GetDamageType()]
					dmginfo:ScaleDamage(dmg or 1)
				end
			end
		end
	end
end