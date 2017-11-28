local Vector = Vector
local PANEL, prevWind, mdlPreview = {}, nil, nil
function PANEL:Init()
	self:SetSize(300, 450)
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
	self.model:SetModel(mdlPreview or "models/error.mdl")
	self.model:SetFOV(50)
	self.model:SetCamPos(self.model:GetCamPos() - Vector(0, 0, 0))
	
	self.model.LayoutEntity = function(self, ent)
		ent:SetIK(false)
		ent:SetCycle(.49)
		ent:SetAngles(Angle(0, 45 + RealTime()*70, 0))
		ent:SetPos(Vector(0, 0, 5))
	end
end

function PANEL:Think()
	self:MoveToFront()
end
vgui.Register("nutArmorPreview", PANEL, "DFrame")

netstream.Hook("nutArmorPreview", function(mdl)
	if (prevWind and prevWind:IsVisible()) then
		prevWind:Close()
		prevWind = nil
	end
	
	mdlPreview = mdl
	prevWind = vgui.Create("nutArmorPreview")
end)