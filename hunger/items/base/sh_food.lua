ITEM.name = "Food base"
ITEM.desc = "A food."
ITEM.category = "food"
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"
ITEM.hunger = 5
ITEM.thirst = 5
ITEM.empty = false
ITEM.functions.Eat = {
	onRun = function(item)
	local client = item.player
	if item.hunger > 0 then client:getChar():setData("hunger", math.Clamp(client:getChar():getData("hunger", 0) + item.hunger, 0, 100)) end
	if item.thirst > 0 then client:getChar():setData("thirst", math.Clamp(client:getChar():getData("thirst", 0) + item.thirst, 0, 100)) end
	client:EmitSound( "physics/flesh/flesh_bloody_break.wav", 75, 200 )
	if !item.empty then client:getChar():getInv():add(item.uniqueID.."_empty") end
		return true
	end,
	onCanRun = function(item)
		return (!item.empty)
	end,
	icon = "icon16/cup.png",
	name = "Употребить"
}
ITEM.permit = "food"