ITEM.name = "Food base"
ITEM.desc = "This is test food."
ITEM.category = "Consumeable"
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.hungerAmount = 5
ITEM.staminaAmount = 5
ITEM.quantity = 1
ITEM.isFood = true

function ITEM:getDesc()
	local str = L(self.desc or "noDesc")
	local h = Format("\n[++%d hunger]", self.hungerAmount)
	
	local stm, s = self.staminaAmount, ""
	if (stm) then
		s = Format("\n[++%d stamina]", stm)
	end
	
	return str..h..s
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		local quantity = item:getData("quantity", item.quantity)

		if (quantity > 1) then
			draw.SimpleText(quantity, "DermaDefault", 5, h-5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
		end
	end
else
	function ITEM:onInstanced(index, x, y, item)
		item:setData("quantity", item.quantity)
	end
end

ITEM:hook("use", function(item)
	item.player:EmitSound("items/battery_pickup.wav")
end)

ITEM.functions.use = {
	name = "Eat",
	tip = "useTip",
	icon = "icon16/cup.png",
	onRun = function(item)
		local client = item.player
		local quantity = item:getData("quantity", item.quantity)
		client:addHunger(item.hungerAmount) 
		
		if (item.staminaAmount) then
			client:restoreStamina(item.staminaAmount)
		end
		
		quantity = quantity - 1
		if (quantity >= 1) then
			item:setData("quantity", quantity)
			return false
		end

		return true
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}