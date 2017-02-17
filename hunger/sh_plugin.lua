PLUGIN.name = "Hunger and Thirst (NS 1.1)"
PLUGIN.author = "Hikka (original author: LiGyH)"
PLUGIN.desc = "Saves the hunger and thirst of a character"

if (SERVER) then
	function PLUGIN:OnCharCreated(client, character)
		character:setData("hunger", 100)
		character:setData("thirst", 100)
	end
	
	function PLUGIN:PreCharDelete(client, char)
		if char then
			if timer.Exists("hunger"..client:SteamID()) then
				timer.Remove("hunger"..client:SteamID())
			end
			
			if timer.Exists("thirst"..client:SteamID()) then
				timer.Remove("thirst"..client:SteamID())
			end
			
			if timer.Exists("TakeDamage"..client:SteamID()) then
				timer.Remove("TakeDamage"..client:SteamID())
			end
		end
	end
	
	function PLUGIN:DoPlayerDeath(client, inflictor, attacker)
		local char = client:getChar()
		if IsValid(client) && char then
			char:setData("thirst", nil)
			char:setData("hunger", nil)
		end
	end
	
	function PLUGIN:PlayerSpawn(client) -- safe
		local char = client:getChar()
		if IsValid(client) && char then
			if char:getData("thirst", nil) == nil then
				char:setData("thirst", 100)
			end
			if char:getData("hunger", nil) == nil then
				char:setData("hunger", 100)
			end
		end
	end
	
	function PLUGIN:PostPlayerLoadout(client)
		local hungSpeed = 400
		local thirSpeed = 300
		local hungerID = "hunger"..client:SteamID()
		local thirstID = "thirst"..client:SteamID()
		local takeDMG = "TakeDamage"..client:SteamID()
		
		timer.Create(hungerID, hungSpeed, 0, function()
			if (IsValid(client)) then
				if client:Alive() && client:getChar():getData("hunger") > 0 then
					client:getChar():setData("hunger", client:getChar():getData("hunger") - 1)
				end
			else timer.Remove(hungerID) end
		end)
		
		timer.Create(thirstID, thirSpeed, 0, function()
			if (IsValid(client)) then
				if client:Alive() && client:getChar():getData("thirst") > 0 then
					client:getChar():setData("thirst", client:getChar():getData("thirst") - 2)
				end
			else timer.Remove(thirstID) end
		end)
		
		timer.Create(takeDMG, 5, 0, function()
			if (IsValid(client)) then
				if client:Alive() && client:getChar():getData("hunger", 0) < 1 or client:getChar():getData("thirst", 0) < 1 then
					client:TakeDamage(math.random(3,6))
				end
			else timer.Remove(takeDMG) end
		end)
	end
end