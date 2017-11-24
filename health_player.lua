local PLUGIN = PLUGIN
PLUGIN.name = "Health player"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Saves the health of a character." -- Изменяет текущую систему ХП, т.е если игрок вышел с 50HP, то при заходе у него будет 50HP :D

local HealthID = "saveHealth" -- переменная которая хранит ID сохраняемого здоровья.

local playerMeta = FindMetaTable("Player")
function playerMeta:getHealth()
	return (self:getNetVar(HealthID)) or 0
end

if (SERVER) then
	local IsValid = IsValid
	function PLUGIN:PlayerDeath(client)
		if (!IsValid(client) and !client:IsPlayer()) then
			return
		end

		client.refillHealth = true
	end

	function PLUGIN:PlayerSpawn(client)
		if (!IsValid(client) and !client:IsPlayer()) then
			return
		end
		
		if (client.refillHealth) then
			local hpAmount = client:GetMaxHealth()
			client:setNetVar(HealthID, hpAmount)
			client.refillHealth = false
		end
	end

	function PLUGIN:CharacterPreSave(character)
		local client = character:getPlayer()
		local savedHealth = client:Health()
		local maxHealth = client:GetMaxHealth()
		character:setData(HealthID, math.Clamp(savedHealth, 0, maxHealth))
	end

	function PLUGIN:PlayerLoadedChar(client, character)
		local hpData = character:getData(HealthID)
		local hpAmount = client:GetMaxHealth()
		if (hpData) then
			if (hpData <= 0) then
				client:setNetVar(HealthID, hpAmount)
				client:SetHealth(hpAmount)
				return
			end
			
			client:setNetVar(HealthID, math.Clamp(hpData, 0, hpAmount))
			client:SetHealth(math.Clamp(hpData, 0, hpAmount))
		else
			client:setNetVar(HealthID, hpAmount)
		end
	end
end
