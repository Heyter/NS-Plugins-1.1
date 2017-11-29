local PLUGIN = PLUGIN
PLUGIN.name = "Groups"
PLUGIN.author = "Black Tea, Hikka (NS 1.1)"
PLUGIN.desc = "You can make the groups."

local pairs, ipairs, IsValid = pairs, ipairs, IsValid

-- make it like lib.
local charMeta = nut.meta.character
nut.group = nut.group or {}
nut.group.list = nut.group.list or {}

local GROUP_OWNER, GROUP_ADMIN, GROUP_NORMAL = 0, 1, 2
local NUT_CVAR_INVITE_PARTY = CreateClientConVar("nut_party_invite", 1, true, true)
local langkey = "russian"
do
	local l = {
		groupCreated = "Вы создали отряд %s.",
		groupDeleted = "Вы распустили отряд %s.",
		groupDismiss = "Отряд %s был распущен.",
		groupPermission = "У вас нет прав в этом отряде.",
		groupFail = "Такой отряд уже существует.",
		groupExists = "Вы уже состоите в отряде %s.",
		groupHUD = "Отряд: %s",
		groupGotKicked = "Вас исключили из отряда.",
		groupNotMember = "Данный участник не находится в вашем отряде.",
		groupKicked = "Вы исключили %s из вашего отряда.",
		groupShort = "Имя отряда слишком короткое. Минимум %s символа.",
		groupChar = "Вы %s в отряде %s.",
		groupFailInvited = "Нельзя пригласить самого себя",
		groupFailKicked = "Нельзя исключить самого себя",
		groupInvited = "Вас пригласили в отряд %s. /groupaccept - принять приглашение",
		groupInvitedWho = "Вы пригласили %s в ваш отряд",
		groupMyLeave = "Вы покинули отряд %s",
		groupNotMyGroup = "Вы не состоите в отряде",
		groupMember = "Участник",
		groupCreator = "Лидер",
		groupNameDesc = "Впишите имя отряда",
		groupNameBox = "Создать свой отряд",
		groupLong = "Имя отряда слишком длинное. Максимум %s символов",
		groupYourMember = "Данный участник уже состоит в вашем отряде",
		groupStopInvited = "%s запретил приглашать его в отряды",
		groupNotAccept = "У вас нет приглашений",
		groupInvitePending = "Данный игрок уже имеет приглашение",
		groupNoNoNo = "Вы не можете покинуть отряд. /groupdismiss - чтобы распустить отряд!",
		groupAcceptYES = "Вы вступили в отряд %s",
		groupInvalid = "Отряд не существует!"
	}

	table.Merge(nut.lang.stored[langkey], l)
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
				desc = "Временно созданный отряд",
				members = {
					[id] = GROUP_OWNER,
				}
			}

			nut.group.syncGroup(id)
			nut.group.save(id)
			hook.Add("OnGroupCreated", id)
			return id
		end

		return false
	end

	function nut.group.delete(groupID)
		local grp = nut.group.list[groupID]
		if (grp) then
			grp = nil

			nut.group.syncGroup(groupID)
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
				return false
			end
		else
			client:notify(L("groupExists", client, group.name))
		end

		return false
	end

	do
		function charMeta:dismissGroup()
			local client = self:getPlayer()
			local groupID = self:getGroup()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				local ranks = members[self:getID()]
				
				if (ranks and ranks == GROUP_OWNER) then
					client:notify(L("groupDeleted", client, group.name))
					
					local char, charID
					for _, v in ipairs(player.GetAll()) do
						char = v:getChar()
						if (char) then
							charID = char:getID()
							if (members[charID]) then
								v:notify(L("groupDismiss", v, group.name))
								char:setData("groupID", nil)
							end
						end
					end

					nut.group.delete(groupID)
					hook.Run("OnCharDeleteGroup", client, groupID)
					return true
				else
					client:notify(L("groupPermission", client))
					return false
				end
			else
				client:notify(L("groupNotMyGroup", client))
			end

			return false
		end
		
		function charMeta:kickGroup(kickerChar, groupID)
			local client = self:getPlayer()
			local kicker = kickerChar:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				local charRank = members[self:getID()]

				if (charRank) then
					if (members[kickerChar:getID()] == GROUP_OWNER) then
						self:setData("groupID", nil)
						return true
					else
						kicker:notify(L("groupPermission", kicker))
						return false
					end
				else
					kicker:notify(L("groupNotMember", kicker))
					return false
				end
			else
				kicker:notify(L("groupNotMyGroup", kicker))
			end

			return false
		end
		
		function charMeta:leaveGroup(groupID)
			local client = self:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)
				local charRank = members[self:getID()]

				if (charRank) then
					if charRank == GROUP_OWNER then
						client:notify(L("groupNoNoNo", client))
						return false
					end
					
					self:setData("groupID", nil)
					return true
				else
					client:notify(L("groupNotMyGroup", client))
					return false
				end
			else
				client:notify(L("groupNotMyGroup", client))
			end

			return false
		end
		
		function charMeta:joinGroup(client, groupID)
			local char = client:getChar()
			local kicker = char:getPlayer()
			local group = nut.group.list[groupID]

			if (group) then
				local members = nut.group.getMembers(groupID)

				if (!members[self:getChar():getID()]) then
					if (members[char:getID()] == GROUP_OWNER) then
						self.InviteToGroup = client
						self:ChatPrint("Вас пригласили в отряд "..group.name..". /groupaccept - принять приглашение")
						timer.Simple(25, function()
							if IsValid(self) then 
								self.InviteToGroup = nil 
								self:ChatPrint("Приглашение в "..group.name.." истекло")
							end
						end)

						return true
					else
						kicker:notify(L("groupPermission", kicker))
						return false
					end
				else
					kicker:notify(L("groupYourMember", kicker))
					return false
				end
			end

			return false
		end
	end

	function nut.group.syncGroup(groupID)
		local groupTable = nut.group.list[groupID]

		if (groupTable) then
			groupTable = table.Copy(groupTable)
		end

		netstream.Start(nil, "nutGroupSync", groupID, groupTable)
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
				groupTable = groupInfo
				char:setData("groupID", groupID)
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
			char:dismissGroup()
		end
	end

	function PLUGIN:PlayerDisconnected(client)
		local char = client:getChar()

		if (char) then
			local groupID = char:getGroup()
			local aliveMembers = nut.group.getAliveMembers(groupID)

			if (table.Count(aliveMembers) <= 1) then
				nut.group.save(groupID)
				nut.group.list[groupID] = nil
			end
		end
	end
else
	netstream.Hook("nutGroupSync", function(id, groupTable)
		nut.group.list[id] = groupTable
	end)
	
	function PLUGIN:DrawCharInfo(client, character, info)
		local groupID = character:getGroup()
		local group = nut.group.list[groupID]
		if (group) then
			info[#info + 1] = {L("groupHUD", group.name), Color(0, 255, 255)}
		end
	end

	function PLUGIN:CreateCharInfoText(self)
		local client = LocalPlayer()
		local group = client:getChar():getGroup()
		local grp = nut.group.list[group]
		if (grp) then
			self.group = self.info:Add("DLabel")
			self.group:Dock(TOP)
			self.group:SetFont("nutMediumFont")
			self.group:SetTextColor(color_white)
			self.group:SetExpensiveShadow(1, Color(0, 0, 0, 150))
			self.group:DockMargin(0, 10, 0, 0)
			local char = client:getChar()
			local groupID = char:getGroup()
			local members = nut.group.getMembers(groupID)
			local ranks = members[char:getID()]
			
			local rank = L("groupMember")
			if ranks and ranks == GROUP_OWNER then
				rank = L("groupCreator")
			end
			
			self.group:SetText(L("groupChar", rank, grp.name or "ERROR"))
		end
	end
	
	function PLUGIN:SetupQuickMenu(menu)
		 local button = menu:addCheck("Приглашать Вас в отряды?", function(panel, state)
		 	if (state) then
		 		RunConsoleCommand("nut_party_invite", "1")
		 	else
		 		RunConsoleCommand("nut_party_invite", "0")
		 	end
		 end, NUT_CVAR_INVITE_PARTY:GetBool())

		 menu:addSpacer()
	end
end

function charMeta:getGroup()
	return self:getData("groupID", 0)
end

function nut.group.getMembers(id)
	local grp = nut.group.list[id]
	return (grp and (grp.members or {}) or {})
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
				local grpTable = nut.group.list[groupID]
				
				if (grpTable) then
					return client:notify(L("groupExists", client, grpTable.name))
				end
				
				if (groupName:utf8len() > 14) then
					return client:notify(L("groupLong", client, 14))
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
		onRun = function(client, arguments)
			local char = client:getChar()

			if (char) then				
				char:dismissGroup()
			end
		end
	})

	nut.command.add("groupinvite", {
		syntax = "<string name>",
		onRun = function(client, args)
			local charName = args[1]
			if (!charName) then
				return client:notify(L("invalidArg", client, 1))
			end

			local target = nut.command.findPlayer(client, charName)

			if (IsValid(target) and target:getChar()) then
				if (target == client) then
					return client:notify(L("groupFailInvited", client))
				end
				
				if (target:GetInfoNum("nut_party_invite", 0) < 1) then
					return client:notify(L("groupStopInvited", client, target:Name()))
				end
				
				if (target.InviteToGroup) then
					return client:notify(L("groupInvitePending", client))
				end
			
				local groupID = client:getChar():getGroup()
				local group = nut.group.list[groupID]
				
				if (!group) then
					return client:notify(L("groupNotMyGroup", client))
				end
				
				if (target:joinGroup(client, groupID)) then
					target:notify(L("groupInvited", client, group.name))
					client:notify(L("groupInvitedWho", client, target:Name()))
				end
			end
				
		end
	})
	
	/*nut.command.add("groupmeinvite", {
		syntax = "<string name>",
		onRun = function(client, args)
			local charName = args[1]
			if (!charName) then
				return client:notify(L("invalidArg", client, 1))
			end

			local target = nut.command.findPlayer(client, charName)

			if (IsValid(target) and target:getChar()) then
				
				if target.InviteToGroup then
					client:notify(L("groupInvitePending", client))
					return
				end
			
				target.InviteToGroup = client
				timer.Simple(25, function()
					if IsValid(target) then 
						target.InviteToGroup = nil 
						target:ChatPrint("Приглашение истекло")
					end
				end)
			end
				
		end
	})*/

	nut.command.add("groupkick", {
		syntax = "<string name>",
		onRun = function(client, args)
			local name = args[1]
			if (!name) then
				return client:notify(L("invalidArg", client, 1))
			end

			local target = nut.command.findPlayer(client, name)
			
			local targChar = target:getChar()
			if (IsValid(target) and targChar) then
				if (target == client) then
					return client:notify(L("groupFailKicked", client))
				end
				
				local char = client:getChar()
				local groupID = char:getGroup()

				if (targChar:kickGroup(char, groupID)) then
					client:notify(L("groupKicked", client, target:Name()))	
					target:notify(L("groupGotKicked", target))	
				end
			end
		end
	})
	
	nut.command.add("groupleave", {
		onRun = function(client)
			local char = client:getChar()
			if (IsValid(client) and char) then
				local groupID = char:getGroup()
				if (char:leaveGroup(groupID)) then
					client:notify(L("groupMyLeave", client, nut.group.list[groupID].name))		
				end
			end
		end
	})
	
	nut.command.add("groupaccept", {
		onRun = function(client)
			local invite = client.InviteToGroup
			if (!invite) then
				return client:notify(L("groupNotAccept", client))
			end
			
			local inviteChar = invite:getChar()
			local groupID = inviteChar:getGroup()
			local group = nut.group.list[groupID]
			
			if (!group) then
				return client:notify(L("groupInvalid", client))
			end
			
			local myChar = client:getChar()
			local myGroup = nut.group.list[myChar:getGroup()]
			local myID = myChar:getID()
			
			myChar:setData("groupID", groupID)
			myGroup.members[myID] = GROUP_NORMAL
			nut.group.syncGroup(myID)
			client:notify(L("groupAcceptYES", client, group.name))
		end
	})
end

-- https://music.yandex.ru/artist/4712699/tracks