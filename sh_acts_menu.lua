local PLUGIN = PLUGIN
PLUGIN.name = "Acts menu for character"
PLUGIN.author = "Hikka (NS 1.1)"
PLUGIN.desc = "Добавляет меню с жестами"

PLUGIN.actsData = PLUGIN.actsData or {}
PLUGIN.actsData["sit"] = {
	["citizen_male"] = {name = {"Сесть"}},
	["citizen_female"] = {name = {"Сесть"}}
}
PLUGIN.actsData["injured"] = {
	["citizen_male"] = {name = {"Лечь на бок", "Лечь на спину #1", "Лечь на спину #2"}},
	["citizen_female"] = {name = {"Лечь на бок"}}
}
PLUGIN.actsData["arrest"] = {
	["citizen_male"] = {name = {"Поднять руки вверх"}},
}
PLUGIN.actsData["cheer"] = {
	["citizen_male"] = {name = {"Радоваться", "Хлопать", "Махать"}},
	["citizen_female"] = {name = {"Лечь на бок", "Махать"}}
}
PLUGIN.actsData["here"] = {
	["citizen_male"] = {name = {"Подозвать #1", "Подозвать #2"}},
	["citizen_female"] = {name = {"Подозвать #1", "Подозвать #2"}}
}
PLUGIN.actsData["sitwall"] = {
	["citizen_male"] = {name = {"Сесть у стены #1", "Сесть у стены #2"}},
	["citizen_female"] = {name = {"Сесть у стены #2", "Сесть у стены #2", "Сесть у стены #3"}}
}
PLUGIN.actsData["stand"] = {
	["citizen_male"] = {name = {"Стойка #1", "Стойка #2", "Стойка #3", "Стойка #4"}},
	["citizen_female"] = {name = {"Стойка #1", "Стойка #2", "Стойка #3"}},
	["metrocop"] = {{name = "Стойка #1"}}
}

local IsValid, pairs, LocalPlayer, color_white, TOP = IsValid, pairs, LocalPlayer, color_white, TOP

nut.command.add("acts", {
	onRun = function(client, arguments)
		if (IsValid(client)) then
			netstream.Start(client, "nutActsMenu", PLUGIN.actsData)
		end
	end
})

if (CLIENT) then
	local PANEL = {}
	function PANEL:Init()
		self:SetTitle("Меню жестов")
		self:SetSize(500, 400)
		self:Center()
		self:MakePopup()

		self.actList = self:Add("PanelList")
		self.actList:Dock(FILL)
		self.actList:DockMargin(0, 5, 0, 0)
		self.actList:SetSpacing(5)
		self.actList:SetPadding(5)
		self.actList:EnableVerticalScrollbar()
		
		self:loadActs()
	end

	local nutActsMenu, actData = nil, {}
	function PANEL:loadActs()
		if (IsValid(nutActsMenu)) then
			nutActsMenu:Remove()
		end
		
		local client = LocalPlayer()
		local class = nut.anim.getModelClass(client:GetModel())
		
		for k, v in pairs(actData) do
			local info = v[class]
			if (info) then
				local pack = info.name
				for i = 1, #pack do
					local acts = self.actList:Add("DButton")
					acts:SetFont("Default")
					acts:Dock(TOP)
					acts:SetTextColor(color_white)
					acts:SetTall(25)
					acts:DockMargin(0, 5, 0, 0)
					acts:SetText(pack[i])
					
					function acts:DoClick()
						nut.command.send("act"..k, i)
						nutActsMenu:Remove()
					end
					
					self.actList:AddItem(acts)
				end
			else
				nutActsMenu:Remove()
				chat.AddText(Color(255,125,125), "Нет жестов для данной модели!")
			end
		end
	end

	vgui.Register("nutActsMenu", PANEL, "DFrame")
	netstream.Hook("nutActsMenu", function(data)
		actData = data
		nutActsMenu = vgui.Create("nutActsMenu")
	end)
end