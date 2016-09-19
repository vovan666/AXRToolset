-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	CallbackRegister("OnApplicationBeginEnd",OnApplicationBeginEnd)
end

function OnApplicationBeginEnd()
	Get():Show(true)
end

function AddPluginButton(text,name,func,...)
	Get():AddPluginButton(text,name,func,...)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cMainMenu:new()
	end
	return UI
end

function GetAndShow()
	Get():Show(true)
end
-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
local inherited = UIBase.cUIBase
cMainMenu = Class("cMainMenu",inherited)
function cMainMenu:initialize(id)
	inherited.initialize(self,id)
	self.plugins = {}
end

function cMainMenu:Reinit()
	inherited.Reinit(self)
	
	self.y = 75
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720|Plugins^Settings")
	self:Gui("Tab|Plugins")
	
		-- Buttons 
		-- register plugin buttons
		for name,t in spairs(self.plugins) do 
			self:Gui("Add|Button|gOnScriptControlAction x370 y%s w230 h20 v%s|%s",self.y,name,t.text)
			self.y = self.y + 25
		end
	
		-- GroupBox
		self:Gui("Add|GroupBox|x360 y50 w250 h660|Plugins Launcher")
	
	self:Gui("Tab|Settings")
	
		-- GroupBox
		self:Gui("Add|GroupBox|x10 y50 w510 h75|Gamedata Path")
	
		-- Buttons 
		self:Gui("Add|Button|gOnScriptControlAction x485 y80 w25 h20 vUIMainBrowseGamedata|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUIMainSaveSettings|Save Settings")
	
		-- Editbox 
		self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUIMainGamedataPath|") -- Edit System.ltx
		
	self:Gui("Show|w1024 h720|AXR Toolset")
	
	GuiControl(self.ID,"","UIMainGamedataPath",gSettings:GetValue("core","Gamedata_Path") or "")
end 

function cMainMenu:AddPluginButton(text,name,func,...)
	self.plugins[name] = {text=text,f=func,p={...}}
end

function cMainMenu:OnScriptControlAction(hwnd,event,info)
	if (hwnd == "") then 
		return 
	end 
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIMainBrowseGamedata")) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("core","Gamedata_Path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UIMainGamedataPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIMainSaveSettings")) then 
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","Gamedata_Path",ahkGetVar("UIMainGamedataPath"))
		gSettings:Save()
	end
	
	for name,t in pairs(self.plugins) do 
		if (t.f and hwnd == GuiControlGet(self.ID,"hwnd",name)) then
			t.f(unpack(t.p),hwnd,event,info)
		end
	end
end

function cMainMenu:OnGuiClose(idx)
	GoSub("OnExit")
end

function cMainMenu:Show(bool)
	inherited.Show(self,bool)
	--cMainMenu:Test()
end

function cMainMenu:Test()
	local smarts = {}
	local fname = "start_positions.ltx"
	for line in io.lines(fname) do
		line = trim(trim_comment(line))
		if (line ~= "" and line ~= "\n") then
			local p = str_explode(line,"=")
			if (p[1] and p[2]) then
				local smart_name = trim(p[2])
				if not (smarts[smart_name]) then 
					smarts[smart_name] = {}
				end
				
				local squad_section = trim(p[1])
				table.insert(smarts[smart_name],squad_section)
			end
		end 
	end
	
	local str = ""
	
	for smart,t in spairs(smarts) do 
		str = str .. "[" .. smart .. "]\n"
		table.sort(t)
		for i=1,#t do 
			if (string.find(t[i],"sim")) then
				str = str .. addTab(t[i],40) .. "= 1\n"
			else 
				str = str .. t[i] .. "\n"
			end
		end
		str = str .. "\n"
	end
	
	local f = io.open("new_start_positions.ltx","wb")
	if (f) then 
		f:write(str)
		f:close()
	end
end