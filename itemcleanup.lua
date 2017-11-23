local ipairs, CurTime, IsValid = ipairs, CurTime, IsValid
local PLUGIN = PLUGIN
PLUGIN.name = "Item Cleanup"
PLUGIN.author = "Hikka"
PLUGIN.desc = "Cleans up items after a period of time."
PLUGIN.cleanUP = {
	"nut_item",
	"nut_money",
}
local timeCleanUP = 1800

if (SERVER) then
	local thinkNext = CurTime() + timeCleanUP
	hook.Add("Think", "Think_itemcleanup", function()
		if (thinkTime < CurTime()) then
			for _, data in ipairs(PLUGIN.cleanUP) do
				for _, ent in ipairs(ents.FindByClass(data)) do
					if (!IsValid(ent)) then continue end
					ent:Remove()
				end
			end
			thinkTime = CurTime() + timeCleanUP
		end
	end)
end

nut.command.add("itemclean", {
	superAdminOnly = true,
	onRun = function (client)
		for _, data in ipairs(PLUGIN.cleanUP) do
			for _, ent in ipairs(ents.FindByClass(data)) do
				if (!IsValid(ent)) then continue end
				ent:Remove()
			end
		end
		client:notify("The map was cleared of items.")
	end
})