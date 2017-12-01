local PLUGIN = PLUGIN
PLUGIN.name = "Hunger system"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Adding hunger"
PLUGIN.hungrySeconds = 1100

nut.config.add("hungerTime", 2, "The time of which is deducted from hunger when not eating.", nil, {
	data = {min = 0, max = 600},
	category = "schema"
})

nut.config.add("foodStack", 12, "Maximum foods stack in inventory.", nil, {
	data = {min = 1, max = 100},
	category = "schema"
})

local mathClamp, CurTime, IsValid, type, pairs = math.Clamp, CurTime, IsValid, type, pairs

local hungerID = "foodHunger"
local PLAYER = FindMetaTable("Player")
function PLAYER:getHunger()
	return (self:getNetVar(hungerID)) or 0
end

function PLAYER:addHunger(amount)
	local curHunger = CurTime() - self:getHunger()
	self:setNetVar(hungerID, CurTime() - mathClamp(math.min(curHunger, PLUGIN.hungrySeconds) - amount, 0, PLUGIN.hungrySeconds))
end

function PLAYER:getHungerPerc()
	return mathClamp(((CurTime() - self:getHunger()) / PLUGIN.hungrySeconds), 0, 1)
end

if (SERVER) then
	function PLUGIN:CharacterPreSave(char)
		local savedHunger = mathClamp(CurTime() - char.player:getHunger(), 0, self.hungrySeconds)
		char:setData(hungerID, savedHunger)
	end
	
	function PLUGIN:PlayerLoadedChar(client, char)
		local hunger = char:getData(hungerID)
		if (hunger) then
			client:setNetVar(hungerID, CurTime() - hunger)
		else
			client:setNetVar(hungerID, CurTime())
		end
	end
	
	function PLUGIN:PlayerDeath(client)
		if (!IsValid(client) and !client:IsPlayer()) then
			return
		end

		client.refillHunger = true
	end
	
	function PLUGIN:PlayerSpawn(client)
		if (!IsValid(client) and !client:IsPlayer()) then
			return
		end
		
		if (client.refillHunger) then
			client:setNetVar(hungerID, CurTime())
			client.refillHunger = false
		end
	end
	
	local hungThink = CurTime()
	function PLUGIN:PlayerPostThink(client)
		if (hungThink < CurTime()) then
			local percent = (1 - client:getHungerPerc())

			if (percent <= 0) then
				local hp = client:Health()
				if (client:Alive() and hp <= 0) then
					client:Kill()
				else
					client:SetHealth(mathClamp(hp - 1, 0, client:GetMaxHealth()))
				end
			end

			hungThink = CurTime() + nut.config.get("hungerTime")
		end
	end
else
	local LocalPlayer = LocalPlayer
	local color = Color(39, 174, 96)
	do
		nut.bar.add(function()
			return (1 - LocalPlayer():getHungerPerc())
		end, color, nil, "hunger")
	end
	
	local hungerBar, percHungr, waveHungr
	function PLUGIN:Think()
		hungerBar = hungerBar or nut.bar.get("hunger")
		percHungr = (1 - LocalPlayer():getHungerPerc())
		if (percHungr < .33) then
			waveHungr = math.abs(math.sin(RealTime()*5)*100)
			hungerBar.lifeTime = CurTime() + 1
			hungerBar.color = Color(color.r + waveHungr, color.g - waveHungr, color.b - waveHungr)
		else
			hungerBar.color = color
		end
	end
end

function PLUGIN:OnPlayerInteractItem(client, action, item)
	if (action != "take") then return end
	
	local char = client:getChar()
	if (type(item) == "Entity") then
		if (IsValid(item)) then
			local itemID = item.nutItemID
			item = nut.item.instances[itemID]
		end
	elseif (type(item) == "number") then
		item = nut.item.instances[item]
	end
	
	if (!item or !item.isFood) then return end
	
	local quantity = item:getData("quantity", 0)
	if (!quantity or quantity <= 0) then return end
	local stack = nut.config.get("foodStack")
	
	if (char) then
		local inventory = char:getInv():getItems()
		for _, v in pairs(inventory) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]
				if (itemTable) then
					if (itemTable.isFood and itemTable.name == item.name) then
						local quantityFood = itemTable:getData("quantity")
						if (quantityFood >= stack) then continue end
						local amt = quantityFood + quantity
						itemTable:setData("quantity", amt)
						
						if (amt - stack <= 1) then
							item:remove()
						else
							item:setData("quantity", amt - stack)
						end
						
						if (itemTable:getData("quantity") >= stack) then
							itemTable:setData("quantity", stack)
						end
						--item:remove()
						break
					end
				else
					client:notifyLocalized("tellAdmin", "wid!xt")
					break
				end
			end
		end
	end
end