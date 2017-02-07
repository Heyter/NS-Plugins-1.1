local PLUGIN = PLUGIN
PLUGIN.name = "Group"
PLUGIN.author = "Black Tea, Hikka (NS 1.1)"
PLUGIN.desc = "You can make the groups."

-- make it like lib.
local charMeta = nut.meta.character
nut.group = nut.group or {}
nut.group.list = nut.group.list or {}

GROUP_OWNER = 0
GROUP_ADMIN = 1
GROUP_NORMAL = 2

local langkey = "russian"
do
	local langTable = {
		groupCreated = "Вы создали группу %s.",
		groupDeleted = "Вы распустили группу %s.",
		groupDismiss = "Группа %s была распущена.",
		groupPermission = "У вас нет прав в этой группе.",
		groupFail = "Такая группа уже существует.",
		groupExists = "Вы уже состоите в группе %s.",
		groupInvalid = "Такой группы не существует.",
		groupHUD = "Состоит в группе '%s'.",
		groupGotKicked = "Вас исключили из группы.",
		groupNotMember = "Данный участник не находится в вашей группе.",
		groupKicked = "Вы исключили %s из группы.",
		groupShort = "Имя группы слишком короткое. Минимум %s символа.",
		groupChar = "Вы %s в группе %s.",
		groupFailInvited = "Нельзя пригласить самого себя",
		groupFailKicked = "Нельзя исключить самого себя",
		groupInvited = "Вы были приглашены в группу %s",
		groupMyLeave = "Вы покинули группу %s",
		groupNotMyGroup = "Вы не состоите в группе",
		groupMember = "Участник",
		groupCreator = "Создатель",
		groupNameDesc = "Впишите имя группы",
		groupNameBox = "Создать свою группу",
		groupLong = "Имя группы слишком длинное. Максимум %s символов"
	}

	table.Merge(nut.lang.stored[langkey], langTable)
end

if (SERVER) then
	file.CreateDir("nutscript/"..SCHEMA.folder.."/groups/")

	function PLUGIN:SaveData()
		nut.group.saveAll()
	end
	
	function nut.group.save(groupID)
		local save = nut.group.list[groupID]
		return nut.data.set("groups/" .. groupID, save, false, true)
	end
	
	function nut.group.saveAll()
		for k, v in pairs(nut.group.list) do
			nut.group.save(k)
		end
	end

	function nut.group.load(groupID)
		return nut.data.get("groups/" .. groupID, nil, false, true)
	end

	function nut.group.create(char, name)
		if (char) then
			local id = char:getID()
			nut.group.list[id] = {
				name = name,
				desc = "Временная созданая группа",
				members = {
					[id] = GROUP_OWNER,
				}
			}

			nut.group.syncGroup(id, nut.group.list[id])
			nut.group.save(id)
			hook.Add("OnGroupCreated", id)
			return id
		end

		return false
	end

	function nut.group.delete(groupID)
		if (nut.group.list[groupID]) then
			nut.group.list[groupID] = nil

			nut.group.syncGroup(groupID, nil)
			nut.data.delete("groups/" .. groupID, false, true)
			hook.Add("OnGroupDissmissed", groupID)
			return true
		end

		return false
	end

	function charMeta:createGroup(name)
		local client = self:getPlayer()
		local group = nut.group.list[self:getGroup()]

		if (!group) then
			local groupID = nut.group.create(self, name)

			if (groupID) then
				self:setData("groupID", groupID)
				group = nut.group.list[groupID]
				client:notify(L("groupCreated", client, group.name))
				hook.Run("OnCharCreateGroup", client, groupID)

				return true
			else
				client:notify(L("groupFail", client))
			end
		else
			client:notify(L("groupExists", client, nut.group.list[self:getGroup()].name))
		end

		return false
	end

	do
		function charMeta:dismissGroup(silent)
			local client = self:getPlayer()
			local groupID = self:getGroup()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				local ranks = members[self:getID()]
				
				if (ranks and ranks == GROUP_OWNER) then
					if (!silent) then client:notify(L("groupDeleted", client, group.name)) end
					
					for _, v in ipairs(player.GetAll()) do
						if (nut.group.getMembers(v:getChar())) then
							v:notify(L("groupDismiss", v, group.name))
						end
					end
						
					for k, v in ipairs(nut.group.getAliveMembers(id)) do
						self:setData("groupID", nil, nil, player.GetAll())
					end

					nut.group.delete(groupID)
					hook.Run("OnCharCreateGroup", client, groupID)
					return true
				else
					if (!silent) then client:notify(L("groupPermission", client)) end
				end
			else
				if (!silent) then 
					client:notify(L("groupInvalid", client))
				end
			end

			return false
		end
		
		function charMeta:kickGroup(kickerChar, groupID)
			local client = self:getPlayer()
			local kicker = kickerChar:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				--local kickerRank = (!kicker and 0 or members[kickerChar:getID()])
				local charRank = members[self:getID()]

				if (charRank) then
					--if (kickerRank < charRank) then
					if charRank == GROUP_OWNER then
						self:setData("groupID", nil, nil, player.GetAll())
						return true
					else
						kicker:notify(L("groupPermission", kicker))
					end
				else
					kicker:notify(L("groupNotMember", kicker))
				end
			else
				kicker:notify(L("groupInvalid", kicker))
			end

			return false
		end
		
		function charMeta:leaveGroup(kickerChar, groupID)
			local client = self:getPlayer()
			local kicker = kickerChar:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				--local kickerRank = (!kicker and 0 or members[kickerChar:getID()])
				local charRank = members[self:getID()]

				if (charRank) then
					self:setData("groupID", nil, nil, player.GetAll())
					return true
				else
					kicker:notify(L("groupNotMyGroup", kicker))
				end
			else
				kicker:notify(L("groupInvalid", kicker))
			end

			return false
		end
		
		function charMeta:joinGroup(kickerChar, groupID)
			local client = self:getPlayer()
			local kicker = kickerChar:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				local charRank = members[self:getID()]

				if (charRank) then
					if charRank == GROUP_OWNER then
						nut.group.list[groupID].members[self:getID()] = GROUP_NORMAL
						self:setData("groupID", groupID, nil, player.GetAll())
						return true
					else
						kicker:notify(L("groupPermission", kicker))
						return false
					end
				end
			end

			return false
		end

		/*function charMeta:joinGroup(groupID)
			local group = nut.group.list[groupID]

			if (group) then
				nut.group.list[groupID].members[self:getID()] = GROUP_NORMAL
				self:setData("groupID", groupID, nil, player.GetAll())
				return true
			end

			return false
		end*/ -- старая функция
	end

	function nut.group.syncGroup(groupID)
		groupTable = nut.group.list[groupID]

		if (groupTable) then
			groupTable = table.Copy(groupTable)
		end

		netstream.Start(player.GetAll(), "nutGroupSync", groupID, groupTable)
	end

	function nut.group.syncAll(client)
		for k, v in pairs(nut.group.list) do
			netstream.Start(client, "nutGroupSync", k, v)
		end
	end

	function PLUGIN:PlayerLoadedChar(client, curChar, prevChar)
		local char = client:getChar()
		local groupID = char:getGroup()
		local groupTable = nut.group.list[groupID]

		if (!groupTable) then
			local groupInfo = nut.group.load(groupID)

			if (groupInfo) then
				nut.group.list[groupID] = groupInfo
				char:setData("groupID", groupID, nil, player.GetAll())
			else
				if (groupID != 0) then
					char:setData("groupID", nil)
				end
			end
		end

		nut.group.syncAll(client)
	end

	function PLUGIN:PreCharDelete(client, char)
		if (char) then
			char:dismissGroup(true)
		end
	end

	function PLUGIN:PlayerDisconnected(client)
		local char = client:getChar()

		if (char) then
			local groupID = char:getGroup()
			local aliveMembers = nut.group.getAliveMembers(groupID)

			if (table.Count(aliveMembers) < 1) then
				nut.group.save(groupID)
				nut.group.list[groupID] = nil
			end
		end
	end
else
	netstream.Hook("nutGroupSync", function(id, groupTable)
		nut.group.list[id] = groupTable
	end)

	local tx, ty 
	function PLUGIN:DrawCharInfo(character, x, y, alpha)
		local groupID = character:getGroup()
		local group = nut.group.list[groupID] 

		if (group) then
			tx, ty = nut.util.drawText(L("groupHUD", group.name), x, y, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			y = y + ty
		end

		return x, y
	end

	function PLUGIN:CreateCharInfoText(self)
		local group = LocalPlayer():getChar():getGroup()

		if (nut.group.list[group]) then
			self.group = self.info:Add("DLabel")
			self.group:Dock(TOP)
			self.group:SetFont("nutMediumFont")
			self.group:SetTextColor(color_white)
			self.group:SetExpensiveShadow(1, Color(0, 0, 0, 150))
			self.group:DockMargin(0, 10, 0, 0)
			local char = LocalPlayer():getChar()
			local groupID = char:getGroup()
			local members = nut.group.getMembers(groupID)
			local ranks = members[char:getID()]
			if ranks && ranks == GROUP_OWNER then
				rank = L("groupCreator")
			else
				rank = L("groupMember")
			end
			self.group:SetText(L("groupChar", rank, nut.group.list[group].name or "ERROR"))
		end
	end
end

function charMeta:getGroup()
	return self:getData("groupID", 0)
end

function nut.group.getMembers(id)
	return (nut.group.list[id] and (nut.group.list[id].members or {}) or {})
end

function nut.group.getAliveMembers(id)
	local groupMembers = nut.group.getMembers(id)
	local aliveMembers = {}
	local char, charID

	for k, v in ipairs(player.GetAll()) do
		char = v:getChar()
		
		if (char) then
			charID = char:getID()
			if (groupMembers[charID]) then
				table.insert(aliveMembers, charID)
			end
		end
	end

	return aliveMembers
end

do
	nut.command.add("groupcreate", {
		syntax = "<string name>",
		onRun = function(client, arguments)
			local char = client:getChar()

			if (char and hook.Run("CanCharCreateGroup", char) != false) then
				local groupName = table.concat(arguments, " ")
				local char = client:getChar()
				local groupID = char:getGroup()
				
				if nut.group.list[groupID] then
					client:notify(L("groupExists", client, nut.group.list[groupID].name))
					return
				end
				
				if groupName:utf8len() > 14 then
					client:notify(L("groupLong", client, 14))
					return
				elseif (groupName != "") then
					char:createGroup(groupName)
				else
					if (groupName:utf8len() == 0) then
						return client:requestString("@groupNameBox", "@groupNameDesc", function(text)
							nut.command.run(client, "groupcreate", {text})
						end, "")
					elseif (groupName:utf8len() < 4) then
						client:notify(L("groupShort", client, 4))
					end
				end
			end
		end
	})

	nut.command.add("groupdismiss", {
		syntax = "",
		onRun = function(client, arguments)
			local char = client:getChar()

			if (char and hook.Run("CanCharDismissGroup", char) != false) then				
				char:dismissGroup()
			end
		end
	})

	nut.command.add("groupinvite", {
		syntax = "<string name>",
		onRun = function(client, arguments)
			if (!arguments[1]) then
				return client:notify(L("invalidArg", client, 1))
			end

			local target = nut.command.findPlayer(client, arguments[1])

			if (IsValid(target) and target:getChar()) then
				--if target == client then
					--client:notify(L("groupFailInvited", client))
					--return
				--end
			
				local char = client:getChar()
				local groupID = char:getGroup()
				local tChar = target:getChar()
				
				--tChar:joinGroup(groupID)
				if (tChar:joinGroup(char, groupID)) then
					client:notify(L("groupInvited", client, nut.group.list[groupID].name))
				end
			end
				
		end
	})

	nut.command.add("groupkick", {
		syntax = "<string name>",
		onRun = function(client, arguments)
			if (!arguments[1]) then
				return client:notify(L("invalidArg", client, 1))
			end

			local target = nut.command.findPlayer(client, arguments[1])

			if (IsValid(target) and target:getChar()) then
				if target == client then
					client:notify(L("groupFailKicked", client))
					return
				end
				
				local char = client:getChar()
				local groupID = char:getGroup()
				local tChar = target:getChar()

				if (tChar:kickGroup(char, groupID)) then
					client:notify(L("groupKicked", client, target:Name()))	
					target:notify(L("groupGotKicked", target))	
				end
			end
		end
	})
	
	nut.command.add("groupleave", {
		onRun = function(client, arguments)
			if (IsValid(client) and client:getChar()) then
				local char = client:getChar()
				local groupID = char:getGroup()
				if (char:leaveGroup(char, groupID)) then
					client:notify(L("groupMyLeave", client, nut.group.list[groupID].name))		
				end
			end
		end
	})
end