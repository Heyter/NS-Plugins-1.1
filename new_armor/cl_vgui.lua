local Vector = Vector
local PANEL, mdlPreview = {}, nil
function PANEL:Init()
	self:SetSize(300, 400)
	self:Center()
	self:SetTitle("Armor Preview")
	self:MakePopup()
	self:SetSizable(false)
	self:SetDraggable(false)
	
	self.submit = self:Add("DButton")
	self.submit:Dock(BOTTOM)
	self.submit:SetTall(30)
	self.submit:SetText("Close")
	self.submit.DoClick = function()
		self:Close()
	end
	
	self.model = self:Add("DModelPanel")
	self.model:Dock(FILL)
	self.model:SetModel(mdlPreview)
	self.model:SetFOV(40)
	self.model:SetCamPos(self.model:GetCamPos() - Vector(0, 0, 0))
	
	self.model.LayoutEntity = function(self, ent)
		ent:SetIK(false)
		ent:SetCycle(.49)
		ent:SetAngles(Angle(0, 45 + RealTime()*70, 0))
		ent:SetPos(Vector(0, 0, 10))
	end
end

function PANEL:Think()
	self:MoveToFront()
end
vgui.Register("nutArmorPreview", PANEL, "DFrame")

netstream.Hook("nutArmorPreview", function(model)
	if (prevWind and prevWind:IsVisible()) then
		prevWind:Close()
		prevWind = nil
	end
	
	prevWind = vgui.Create("nutArmorPreview")
	mdlPreview = model
end)