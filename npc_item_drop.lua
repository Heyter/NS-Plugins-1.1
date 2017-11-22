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

	local chnce, class = 100 * math.random(), entity:GetClass()
	for _, data in ipairs(self.itemDrops) do
		local dropTbl = data.drop
		local moneyTbl = data.money
		
		if (class == dropTbl.npc) then
			if (chnce > dropTbl.chance) then
				break
			end
			
			if (moneyTbl.enabled) then
				nut.currency.spawn(entity:GetPos() + Vector(0, 0, 20), math.random(1, moneyTbl.amount or 100))
			end
			
			nut.item.spawn(table.Random(dropTbl.item), entity:GetPos() + Vector(0, 0, 15))
		end
		break
	end
end