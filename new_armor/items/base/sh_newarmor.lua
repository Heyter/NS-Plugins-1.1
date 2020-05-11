ITEM.name = "Armor base"
ITEM.desc = "This is test armor."
ITEM.category = "Armor"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.SetModel = "models/aoc_player/e_archer.mdl"
ITEM.armorClass = "armor" -- don't change
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
			local m, f = "male", "female"
			if (client:isFemale() and item.armorGender == m) then
				client:notify(Format("Only for %s!", m))
				return false
			elseif (!client:isFemale() and item.armorGender == f) then
				client:notify(Format("Only for %s!", f))
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
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
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

function GetDamageName(data)
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
		[DMG_NEVERGIB] = "NEVERGIB",
		[DMG_ALWAYSGIB] = "ALWAYSGIB",
		[DMG_DROWN] = "Drown",
		[DMG_PARALYZE] = "Poison",
		[DMG_NERVEGAS] = "Neurotoxin",
		[DMG_POISON] = "Poison",
		[DMG_ACID] = "Toxic chemicals or acid burns",
		[DMG_AIRBOAT] = "Airboat gun",
		[DMG_BLAST_SURFACE] = "Underwater dmg",
		[DMG_BUCKSHOT] = "Shotgun",
		[DMG_DIRECT] = "DIRECT",
		[DMG_DISSOLVE] = "Combine ball",
		[DMG_DROWNRECOVER] = "DROWNRECOVER",
		[DMG_PHYSGUN] = "Gravity gun",
		[DMG_PLASMA] = "Plasma",
		[DMG_PREVENT_PHYSICS_FORCE] = "Physics force",
		[DMG_RADIATION] = "Radiation",
		[DMG_REMOVENORAGDOLL] = "REMOVENORAGDOLL",
		[DMG_SLOWBURN] = "SLOWBURN",
	}

	local text = "Different"
	if (DMG_ENUMS[data]) then
		text = DMG_ENUMS[data]
	end
	
	return text
end

function ITEM:getDesc()
	local desc = L(self.description or "noDesc")
	
	if self.invID ~= nil then
		desc = desc .. "\n Defence from: "
		
		local resist = self.resistData
		for k in pairs(resist) do
			if (resist[k] == 1) then continue end
			desc = desc .. "\n [*]"..GetDamageName(k)..": " .. math.Round(((1 - resist[k]) * 100), 1).. "%"
		end
		resist = nil
	end
	
	return desc
end