PLUGIN.name = "Health player"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Change alternative HP system" -- Изменяет текущую систему ХП, т.е если игрок вышел с 50HP, то при заходе у него будет 50HP :D

function PLUGIN:DoPlayerDeath(client, inflictor, attacker)
	local char = client:getChar()
	if IsValid(client) && char then char:setData("health", 0) end
end

function PLUGIN:PlayerSpawn(client) -- safe
	local char = client:getChar()
	if IsValid(client) && char then
		local health = char:getData("health")
		if health < 1 then
			char:setData("health", 100)
			client:SetHealth(health)
		end
	end
end

function PLUGIN:OnCharCreated(client, char)
	char:setData("health", 100)
end

function PLUGIN:CharacterPreSave(character)
	local client = character:getPlayer()

	if (IsValid(client)) then
		character:setData("health", client:Health())
	end
end

function PLUGIN:PlayerLoadedChar(client, character, lastChar)
	timer.Simple(0, function()
		if (IsValid(client)) then
			local health = character:getData("health")
			if health then
				client:SetHealth(health)
			end
		end
	end)
end