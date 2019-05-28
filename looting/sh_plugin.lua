local PLUGIN = PLUGIN
PLUGIN.name = "Looting"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "A plugin for dropping player inventory on death."

-- Ignored Items will be set here
PLUGIN.ignored = PLUGIN.ignored or {}
nut.util.include('sh_ignored.lua')

nut.config.add("lootTime", 50, "Number of seconds before loot disappears.", nil, {
	data = {min = 1, max = 86400},
	category = "Looting"
})

nut.util.include('sv_plugin.lua')

if CLIENT then
	netstream.Hook("openLoot", function(entity, items)
		nut.gui.loot = vgui.Create("nutLoots")
		nut.gui.loot:setItems(entity, items)
	end)
end