PLUGIN.name = "NPC Item Drop"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "За убийство NPC, будет выпадать вещь"

PLUGIN.itemDrops = {
	drop = {
		{item = "pistol", chance = 100, npc = {"npc_zombie"}}, -- выпадаемый предмет; шанс выпадения с NPC; типы NPC с которых выпадет вещь.
		{item = "spraycan", chance = 10, npc = {"npc_zombie", "npc_bug"}},
		{item = "water", chance = 15, npc = {"npc_zombie", "npc_bug", "npc_fastzombie"}},
	},
	
	money = {
		enabled = true, -- Выпадение денег при убийстве NPC. (true/false)
		amount = 100, -- Максимальная сумма выпадения денег.
	},
}

function PLUGIN:OnNPCKilled(entity, attacker)
	if (!IsValid(entity)) then
		return
	end

	if (!IsValid(attacker) and !attacker:IsPlayer()) then
		return
	end

	local chnce, class, money = 100 * math.random(), entity:GetClass(), self.itemDrops.money
	local item,npcc,chancce
	for _, data in ipairs(self.itemDrops.drop) do
		for _, npc in ipairs(data.npc) do
			if (class == npc) then
				npcc = npc
				chancce = data.chance
				item = data.item
			end
		end
	end
	
	if (class == npcc) then
		if (chnce > chancce) then
			return
		end
		
		if (money.enabled) then
			nut.currency.spawn(entity:GetPos() + Vector(0, 0, 20), math.random(1, money.amount or 100))
		end
		
		nut.item.spawn(item, entity:GetPos() + Vector(0, 0, 15))
	end
end