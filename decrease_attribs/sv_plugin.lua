local PLUGIN = PLUGIN
PLUGIN.name = "Decrease attributes"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Decrease random attributes when player dies"

local cMeta, mRand = nut.meta.character, math.random
function cMeta:decrAttributes(c, f)
	local at, ce = nut.attribs.list, 100 * mRand()
	for k, v in SortedPairsByMemberValue(at, "name") do
		local a = self:getAttrib(k, 0)
		if (a > 0 and ce < c) then
			local d = a * 0.01 * (100 - f)
			self:setAttrib(k, d)
		end
	end
end

function PLUGIN:DoPlayerDeath(client)
	if (!IsValid(client) and !client:IsPlayer()) then
		return
	end
	
	local char = client:getChar()
	if (char) then
		char:decreaseAttribs(100, math.random(10, 20)) -- Chance = 100%, min decrease = 10, max decrease = 20
	end
end