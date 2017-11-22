PLUGIN.name = "Health player"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Saves the health of a character." -- Изменяет текущую систему ХП, т.е если игрок вышел с 50HP, то при заходе у него будет 50HP :D

local HealthID = "saveHealth" -- переменная которая хранит ID сохраняемого здоровья.

function PLUGIN:DoPlayerDeath(client)
	if (!IsValid(client) and !client:IsPlayer()) then
		return
	end

	local char = client:getChar()
	if (char) then 
		char:setData(HealthID, nil) 
	end
end

function PLUGIN:PlayerSpawn(client) -- safe
	if (!IsValid(client) and !client:IsPlayer()) then
		return
	end

	local char = client:getChar()
	if (char) then
		local hp = char:getData(HealthID)
		local hpAmount = client:GetMaxHealth()
		if (!hp or hp < 1) then
			char:setData(HealthID, hpAmount)
			return
		end
		
		client:SetHealth(math.Clamp(hp, 0, hpAmount))
	end
end

function PLUGIN:OnCharCreated(client, char)
	char:setData(HealthID, client:GetMaxHealth())
end

function PLUGIN:CharacterPreSave(character)
	local client = character:getPlayer()

	if (IsValid(client)) then
		local hp = client:Health()
		if (hp > 0) then
			character:setData(HealthID, hp)
		end
	end
end

function PLUGIN:PlayerLoadedChar(client)
	timer.Simple(0.25, function()
		if (IsValid(client)) then
			local character = client:getChar()
			
			if (!character) then
				return
			end
		
			local hpData = character:getData(HealthID)
			local hpAmount = client:GetMaxHealth()
			if (!hpData or hpData < 1) then
				char:setData(HealthID, hpAmount)
			elseif (hpData and hpData > 0) then
				client:SetHealth(math.Clamp(hpData, 0, hpAmount))
			end
		end
	end)
end