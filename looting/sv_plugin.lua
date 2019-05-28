local PLUGIN = PLUGIN

local function item2world(inv, item, pos)
	item.invID = 0

	inv:remove(item.id, false, true)
	nut.db.query("UPDATE nut_items SET _invID = 0 WHERE _itemID = "..item.id)

	local ent = item:spawn(pos)	
	
	if (IsValid(ent)) then
		timer.Simple(0, function()
			local phys = ent:GetPhysicsObject()
			
			if (IsValid(phys)) then
				phys:EnableMotion(true)
				phys:Wake()
			end
		end)
	end

	return ent
end

function PLUGIN:PlayerDeath(client, inflicter, attacker)
	local char = client:getChar()
	if (not char) then return end
	
	client:resetParts()
	
	local inv = char:getInv()
	local items = inv:getItems()
	local dropItems = {}
	local dmgType = 0
	
	if (table.Count(items) > 0) then
		for k, v in pairs(items) do
			if self.ignored[v.uniqueID] then continue end
			
			if (v.isWeapon and v:getData("equip")) then
				v:setData("equip", nil)
				local ent = item2world(inv, v, client:GetPos() + Vector(0, 0, 10))
				continue
			end
			
			if (v:getData("equip")) then
				v:setData("equip", nil)
			end
			
			if (v:transfer(nil, nil, nil, client, nil, true)) then
				dropItems[v:getID()] = {uid = v.uniqueID, data = v.data}
			end
		end
		
		local loots = ents.Create("nut_loots")
		loots.items = dropItems
		loots:SetPos(client:GetPos() + Vector(0, 0, 10))
		loots:Spawn()
		loots:Activate()
	end
end

netstream.Hook("lootExit", function(client)
	client.nutLoot.looted = nil
	client.nutLoot = nil
end)

netstream.Hook("lootUse", function(client, itemID, drop)
	local entity = client.nutLoot
	local itemTable = nut.item.instances[itemID]

	if (itemTable and IsValid(entity)) then
		if (entity:GetPos():Distance(client:GetPos()) > 128) then
			client.nutLoot = nil
			return
		end

		entity.items[itemID] = nil

		if (drop) then
			itemTable:spawn(entity:GetPos() + Vector(0, 0, 16))
		else
			local status, fault = itemTable:transfer(client:getChar():getInv():getID(), nil, nil, client)
	
			if (!status) then
				return client:notifyLocalized("noFit")
			end
		end

		if (entity:getItemCount() < 1) then
			entity:GibBreakServer(Vector(0, 0, 0.5))
			entity:Remove()
		end
	end
end)