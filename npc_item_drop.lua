PLUGIN.name = "NPC Item Drop"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "За убийство NPC, будет выпадать вещь"

PLUGIN.chance = 100 -- шанс выпадение вещи
PLUGIN.items = { -- вещи которые будут выпадать
	"pistol",
	"spraycan",
}
PLUGIN.typeNPC = { -- тип npc, с которого падает награда
	"npc_bug",
	"npc_zombie",
}

function PLUGIN:OnNPCKilled(entity)
	if math.random( 0, 100 ) <= math.Clamp( self.chance, 0, 100 ) then
		for _, x in pairs(self.typeNPC) do
			if entity:GetClass() == x then
				nut.item.spawn(table.Random(self.items), entity:GetPos() + Vector(0, 0, 8))
			end
		end
	end
end