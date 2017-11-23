local PLUGIN = PLUGIN

PLUGIN.name = "NPC Item Drop"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "За убийство NPC, будет выпадать вещь"

PLUGIN.itemDrops = {
	drop = {
		-- Вещь которая выпадет с NPC; шанс выпадение вещи; тип NPC с которого упадет вещь.
		{items = {"spray", "water"}, chance = 50, class = "npc_zombie"},
		{items = {"spray", "food"}, chance = 100, class = "npc_fastzombie"},
		{items = {"spray", "food"}, chance = 100, class = "npc_gman"},
	},
	
	money = {
		enabled = true, -- Выпадение денег при убийстве NPC. (true/false)
		amount = 100, -- Максимальная сумма выпадения денег.
		all = true, -- Выпадение денег СО всех NPC? Вне зависимости от настроек таблицы drop. (true - да; false - нет)
	},
}

function PLUGIN:OnNPCKilled(entity, attacker)
	if (!IsValid(entity)) then
		return
	end

	if (!IsValid(attacker) and !attacker:IsPlayer()) then
		return
	end

	local chnce, class, money, pos = 100 * math.random(), entity:GetClass(), self.itemDrops.money, entity:GetPos()
	
	if (money.enabled and money.all) then
		nut.currency.spawn(pos + Vector(0, 0, 20), math.random(1, money.amount or 100))
	end
	
	for _, data in ipairs(self.itemDrops.drop) do
		if (class == data.class) then
			if (chnce > data.chance) then
				break
			end
			
			if (money.enabled and !money.all) then
				nut.currency.spawn(pos + Vector(0, 0, 20), math.random(1, money.amount or 100))
			end
			
			nut.item.spawn(table.Random(data.items), pos + Vector(0, 0, 15))
			break
		end
	end
end