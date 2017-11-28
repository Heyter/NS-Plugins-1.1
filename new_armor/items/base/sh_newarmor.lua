ITEM.name = "Броня"
ITEM.desc = "Описание."
ITEM.category = "Броня"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.SetModel = "models/aoc_player/e_archer.mdl"
ITEM.armorClass = "armor"
ITEM.armorGender = "all"
ITEM.width = 3
ITEM.height = 3
ITEM.resistData = { -- http://wiki.garrysmod.com/page/Enums/DMG
	[DMG_SLASH] = 1,
	[DMG_CLUB] = 1,
	[DMG_CRUSH] = 1,
	[DMG_BULLET] = 1,
	[DMG_BURN] = 1,
	[DMG_GENERIC] = 1,
}
ITEM.SetSpeed = 1

-- Inventory drawing
if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

function ITEM:removeArmor(client)
	local char = client:getChar()
	self:setData("equip", nil)
	client:setNetVar("armorSpeed", nil)
	client:SetModel(char:getModel())
	client:EmitSound("items/ammo_pickup.wav", 80)
end

ITEM:hook("drop", function(item)
	if (item:getData("equip")) then
		item:removeArmor(item.player)
	end
end)

ITEM.functions.EquipUn = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item:removeArmor(item.player)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player
		
		if (item.armorGender != "all") then
			if (client:isFemale() and item.armorGender == "male") then
				client:notify("Only for male!")
				return false
			elseif (!client:isFemale() and item.armorGender == "female") then
				client:notify("Only for female!")
				return false
			end
		end
			
		local inventory = client:getChar():getInv():getItems()
		for _, v in pairs(inventory) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]
				if (itemTable) then
					if (itemTable.armorClass == item.armorClass and itemTable:getData("equip")) then
						client:notify("You're already wearing armor!")
						return false
					end 
				else
					client:notifyLocalized("tellAdmin", "wid!xt")
					return false
				end
			end
		end
		
		item:setData("equip", true)
		client:SetModel(item.SetModel)
		client:setNetVar("armorSpeed", item.SetSpeed)
		client:EmitSound("items/ammo_pickup.wav", 80)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}

ITEM.functions.Preview = {
	tip = "previewTip",
	icon = "icon16/camera.png",
	onRun = function(item)
		netstream.Start(item.player, "nutArmorPreview", item.SetModel)
		return false
	end,
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equip")) then
		return false
	end

	return true
end

function ITEM:onLoadout()
	if (self:getData("equip")) then
		local client = self.player
		client:SetModel(self.SetModel)
		client:setNetVar("armorSpeed", self.SetSpeed)
	end
end

function ITEM:onRemoved()
	local inv = nut.item.inventories[self.invID]
	local receiver = inv.getReceiver and inv:getReceiver()

	if (IsValid(receiver) and receiver:IsPlayer()) then
		if (self:getData("equip")) then
			self:removeArmor(receiver)
		end
	end
end

local DMG_ENUMS = {
	[DMG_GENERIC] = "Generic",
	[DMG_CRUSH] = "Crushing",
	[DMG_BULLET] = "Bullet",
	[DMG_SLASH] = "Cutting",
	[DMG_BURN] = "Fire",
	[DMG_VEHICLE] = "Vehicle",
	[DMG_FALL] = "Fall",
	[DMG_BLAST] = "Explosion",
	[DMG_CLUB] = "Crowbar",
	[DMG_SHOCK] = "Electrical",
	[DMG_SONIC] = "Sonic",
	[DMG_ENERGYBEAM] = "Laser",
	[DMG_NEVERGIB] = "What it is?",
	[DMG_ALWAYSGIB] = "What it is?",
	[DMG_DROWN] = "Drown",
	[DMG_PARALYZE] = "Poison",
	[DMG_NERVEGAS] = "Neurotoxin",
	[DMG_POISON] = "Poison",
	[DMG_ACID] = "Toxic chemicals or acid burns",
	[DMG_AIRBOAT] = "Airboat gun",
	[DMG_BLAST_SURFACE] = "Underwater dmg",
	[DMG_BUCKSHOT] = "Shotgun",
	[DMG_DIRECT] = "What it is?",
	[DMG_DISSOLVE] = "Combine ball",
	[DMG_DROWNRECOVER] = "What it is?",
	[DMG_PHYSGUN] = "Gravity gun",
	[DMG_PLASMA] = "Plasma",
	[DMG_PREVENT_PHYSICS_FORCE] = "Physics force",
	[DMG_RADIATION] = "Radiation",
	[DMG_REMOVENORAGDOLL] = "What it is?",
	[DMG_SLOWBURN] = "What it is?",
}
local function dmgInfo(data)
	local text = "Different"
	if (DMG_ENUMS[data]) then
		return tostring(text)
	else
		return text
	end
end

function ITEM:getDesc()
	local desc = self.desc
	desc = desc.."\n Characteristics: "
	for k, _ in pairs(self.resistData) do
		if (self.resistData[k] == 1) then 
			continue
		end
		desc = Format("%s \n [*] Defence from %s: %d", desc, dmgInfo(k), math.Round((1 - self.resistData[k]), 1))
	end
	return desc
end
