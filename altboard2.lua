print("ALTBOARD by droke loading... :D")

altboard = {}
altboard.groups = {}

altboard.MaxTeamForCustom = 25 // donator and above

altboard.newlinechar = "$"

local groups_default = "superadmin,admin,operator,user"

function altboard.getTeamName(ply, getall)
	local fallback = ""
	local nw = ply:GetNWString("altTeamName", fallback)
	
	if nw and nw != fallback and ply:Team() <= altboard.MaxTeamForCustom then
		
		if !getall then
			local split = string.Explode(altboard.newlinechar, nw, false)
			
			nw = split[1]
		end
		
		return nw
	end
		
	return team.GetName(ply:Team())
end

function altboard.getTeamColour(ply)
	local fallback = Vector(-1,-1,-1)
	local nw = ply:GetNWVector("altTeamColour", fallback)
	
	if nw and nw != fallback and ply:Team() <= altboard.MaxTeamForCustom then
		return Color(nw.x, nw.y, nw.z)
	end
	
	return team.GetColor(ply:Team())
end

CreateConVar("altboard_name", "gmod gmod", {FCVAR_REPLICATED, FCVAR_ARCHIVE})	
CreateConVar("altboard_desc", "it's a hell of a town", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("altboard_colour_r", "100", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("altboard_colour_g", "100", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("altboard_colour_b", "100", {FCVAR_REPLICATED, FCVAR_ARCHIVE})	
CreateConVar("altboard_groups", groups_default, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("altboard_maxteamforcustom", altboard.MaxTeamForCustom, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

if SERVER then
	AddCSLuaFile()
	
	local settings = {}
		
	function altboard.InitializePlayer(ply)
		if ply:Team() <= altboard.MaxTeamForCustom then		
			timer.Create(ply:SteamID(), 3, 1, function()
				local r,g,b = altboard.loadTeamColour(ply)
				local name = altboard.loadTeamName(ply)
				
				-- if colour then
					-- print(r,g,b)
				if r and g and b then
					altboard.setTeamColour(ply, Color(r, g, b), false)
				end
				
				if name then
					altboard.setTeamName(ply, name, false)
				end
			end)
		end
	end
	
	hook.Add("PlayerSpawn", "altboard", function(ply)
		-- print(ply, ply:Team())
		altboard.InitializePlayer(ply)
	
	end)
	
	hook.Add("PlayerInitialSpawn", "altboard", function(ply)
		-- print(ply, ply:Team())
		altboard.InitializePlayer(ply)
	
	end)
	
	
	function altboard.loadTeamColour(ply)
		local r = ply:GetPData("altTeamColourR")
		local g = ply:GetPData("altTeamColourG")
		local b = ply:GetPData("altTeamColourB")

		if r and g and b then		
			return r, g, b
		end
		
		return false
		-- return loaded
	end
	
	function altboard.loadTeamName(ply)
		local loaded = ply:GetPData("altTeamName")		
		return loaded
	end
	
	function altboard.setTeamColour(ply, colour, set)
		ply:SetNWVector("altTeamColour", Vector(colour.r, colour.g, colour.b))
		if set then 
			ply:SetPData("altTeamColourR", colour.r) 
			ply:SetPData("altTeamColourG", colour.g) 
			ply:SetPData("altTeamColourB", colour.b) 
		end
	end
	
	function altboard.setTeamName(ply, name, set)
		name = string.sub(name, 1, math.Min(string.len(name), 128)) // max of 128
	
		ply:SetNWString("altTeamName", name)
		if set then ply:SetPData("altTeamName", name) end
	end
	
	concommand.Add("altboard_teamcolour", function(ply, cmd, args)
		local r,g,b = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])

		
		if r and g and b then
			altboard.setTeamColour(ply, Color(r,g,b), true)
		end
		
	end)
	
	concommand.Add("altboard_teamname", function(ply, cmd, args)
		local name = string.Implode(" ", args)
		
		if name then
			altboard.setTeamName(ply, name, true)
		end
		
	end)
		
	return
end

altboard.pages = {
	"Scoreboard",
	"Rules",
	"About Us"
}

altboard.page_URLs = {
nil,
"http://pastebin.com/raw/GPPbEdNJ",
"http://pastebin.com/raw/ayEAcsMj"
}

altboard.nextCheck = 0
-- hook.Add("Think", "altboard", function(ply)
	-- if (ply

-- end)



local hostname_spacer = " | "

local counts = { // these are the only ones i could be bothered with, enjoy!
	"props",
	"balloons",
	"dynamite",	
	"hoverballs",
	"thrusters",
	"emitters",
	"lamps",
	"lights",
	"wheels",
	"ragdolls",
	"npcs",
	"sents",
	"wire_expressions",
	"wire_egps",
	"gmod_wire_gpulib_controller"	
}

altboard.CommandPrefix = "ulx"	
	
function altboard.GetSessionTime(p)	
	if p.GetUTimeSessionTime then
		return p:GetUTimeSessionTime()
	end
	
	return 0
end
	
function altboard.GetTime(p)
	if ulx then // ulx
		return p:GetUTimeTotalTime()
	elseif fusion then
		local time = p.Time or 0
		local lastupdate = p.LastUpdate or 0		
		local predict = time + ( CurTime() - lastupdate )		
		return predict
	elseif evolve then // evolve
		return p.PlayTime
	end
	
	return 0
end

local function timeToStr( time, verbose ) // droked up?
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	local format = ""
	if w>0 then
		format = format .. "w "	
	end
	
	if d>0 then
		format = format .. "d "	
	end
	
	if h>0 then
		format = format .. "h "	
	end
	
	if m>0 then
		format = format .. "m "	
	end
	
	if s>0 and (!(w>0) or verbose) then
		format = format .. "s "	
	end	
	
	format = string.gsub(format, "w", w .. "w")
	format = string.gsub(format, "d", d .. "d")
	format = string.gsub(format, "h", h .. "h")
	format = string.gsub(format, "m", m .. "m")
	format = string.gsub(format, "s", math.Round(s) .. "s")
	
	format = string.TrimLeft(format)
	format = string.TrimRight(format)
	
	return format
end

local font = "Arial" //"Mondale"
local bigFont = "coolvetica" //"Andale Mono" //"Arial" // "Georgia" //"Courier New" // "akbar" // 

surface.CreateFont( "alt1", 
	{
		font      = bigFont,
		size      = 48,
		antialias = true,
		weight    = 700,
	}
)

surface.CreateFont( "alt1_glow", 
	{
		font      = bigFont,
		size      = 48,
		antialias = true,
		weight    = 700,		
		blursize = 5
		-- shadow 	  = true
	}
)

surface.CreateFont( "alt2", 
	{
		font      = font,
		size      = 16,
		antialias = true,
		weight    = 400,
		-- blursize = 1
		-- shadow 	  = true
	}
)

surface.CreateFont( "alt2_glow", 
	{
		font      = font,
		size      = 16,
		antialias = true,
		weight    = 400,
		blursize = 6
		-- shadow 	  = true
	}
)

surface.CreateFont( "alt3", 
	{
		font      = font,
		size      = 14,
		antialias = true,
		weight    = 400,
	}
)

surface.CreateFont( "alt_tooltip", 
	{
		font      = font,
		size      = 14,
		antialias = true,
		weight    = 400,
	}
)

function altboard.mouseInRegion(x,y,w,h)
	local mx, my = gui.MouseX(), gui.MouseY()
	return mx > x and mx < x+w and my > y and my < y+h	
end



-- print("altboard loadededededed")

altboard.defaultspeed = 500

CreateClientConVar( "altboard_speed", altboard.defaultspeed .. "", true, false )

function altboard.create()
	
	if evolve then
		altboard.CommandPrefix = "ev"
	elseif fusion then
		altboard.CommandPrefix = "fusion"
	elseif ulx then
		altboard.CommandPrefix = "ulx"
	end
	
	if altboard.avatars then
		for k,v in pairs(altboard.avatars) do
			v:Remove()		
		end
	end

	altboard.avatars = {}

	altboard.gradient = surface.GetTextureID( "gui/gradient" )
	altboard.gradient_down = surface.GetTextureID( "gui/gradient_down" )
	altboard.gradient_cen = surface.GetTextureID( "gui/center_gradient" )

	altboard.user_icon = Material( "icon16/user.png" )
	altboard.admin_icon = Material( "icon16/shield.png" )
	altboard.mod_icon = Material( "icon16/wrench.png" )
	
	
	altboard.speedicon = Material( "icon16/wrench.png" )
	
	altboard.minwidth = 16
	
	altboard.data_values = {}
	
	-- table.insert(altboard.data_values, {						
		-- tooltip = "health",
		-- width = altboard.minwidth,
		-- hoverwidth = 100,
		-- get = function(p) 
			-- return p:Health()
			-- return 9999 .. "ms"
			
		-- end
	-- })	
		
	colorvar = Color(200,200,200)	
	table.insert(altboard.data_values, {						
		tooltip = "their name!",
		tooltipfunc = function(p) 
			
			-- local color = team.GetColor(p:Team())
			-- local colorvar = Color(200,200,200)
			
			local str = "Name: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Name() .. "</color>\n"
			         .. "Usergroup: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:GetUserGroup() .. "</color>\n"
					 .. "Health: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Health() .. "</color>\n"
					 .. "Armour: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Armor() .. "</color>\n" 
					 .. "Ping: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Ping() .. "ms</color>\n"
					 .. "Session Time: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. timeToStr( altboard.GetSessionTime(p), true) .. "</color>\n"  
					 .. "Total Time: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. timeToStr( altboard.GetTime(p), true) .. "</color>\n" 
					 .. "UserID: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:UserID() .. "</color>\n" 
					 .. "EntIndex: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:EntIndex() .. "</color>\n"  
					 .. "Kills: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Frags() .. "</color>\n"		 
					 .. "Deaths: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. p:Deaths() .. "</color>"

					 
					 -- .. "Name: " .. p:Name() .. "\n"
			
			return str
		
		end,
		width = 180,
		get = function(p) 
			local name = p:Name()
			
			if string.len(name) > 18 then
				name = string.sub(name, 1, 16) .. ".."
			end
		
			return name
			
		end
	})
	table.insert(altboard.data_values, {						
		-- tooltip = "teamname",
		tooltipfunc = function(p) 
			local name = altboard.getTeamName(p, true)
			
			local split = string.Explode(altboard.newlinechar, name, false)			
			
			-- PrintTable(split)
			
			if (#split == 1) then
				name = split[1]
			else
				name = split[1] .. "\n<color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. table.concat( split, "\n", 2, #split ) .. "</color>"
			end			
			
			-- name = string.Trim(name)
			
			return name 
		end,
		width = 250,
		get = function(p) 
			local name = altboard.getTeamName(p)
			
			-- name = string.gsub(name, "%b()", "")
			-- name = string.gsub(name, "%b''", "")
			
			-- name = string.Trim(name)
			
			if string.len(name) > 24 then
				name = string.sub(name, 1, 22) .. ".."
			end
		
			return name			
		end
	})
	
	table.insert(altboard.data_values, {						
		tooltip = "k / d",
		width = 50, //altboard.minwidth,
		-- hoverwidth = 100,
		get = function(p) 
			return p:Frags() .. " / " .. p:Deaths()
			-- return 9999 .. "ms"
			
		end
	})	
	
	
	table.insert(altboard.data_values, {					
		tooltip = "entities spawned",
		width = 50,
		get = function(p) 

			if p.cachedcount and p.cachedcountdie and p.cachedcountdie > CurTime() then
	
			else
				local entscount = 0
		
				for i = 1, #counts do entscount = entscount + p:GetCount(counts[i]) end
	
				p.cachedcount = entscount
				p.cachedcountdie = CurTime() + 0.5
		
			end
			
			return p.cachedcount or 0
		end
	})
	table.insert(altboard.data_values, {						
		tooltip = "ping in milliseconds",
		width = 60,
		get = function(p) 
			return p:Ping() .. "ms"
			-- return 9999 .. "ms"
			
		end
	})
	table.insert(altboard.data_values, {
		tooltip = "time spent playing on this server",
		tooltipfunc = function(p) 
			return "Session Time: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. timeToStr( altboard.GetSessionTime(p), true) .. "</color>\n"  
					 .. "Total Time: <color="..colorvar.r..","..colorvar.g..","..colorvar.b..">" .. timeToStr( altboard.GetTime(p), true) .. "</color>" 
		end,
		width = 170,
		get = function(p) 
			return timeToStr(altboard.GetTime(p))
		end
	})

	altboard.name = GetConVarString("altboard_name") or "error in altboard_name"
	local r,g,b = GetConVarNumber("altboard_colour_r") or 100, GetConVarNumber("altboard_colour_g") or 100, GetConVarNumber("altboard_colour_b") or 100

	altboard.colour = Color(r,g,b)
	altboard.desc = GetConVarString("altboard_desc") or "error in altboard_desc"
	 
	local groups = GetConVarString("altboard_groups")or groups_default
	altboard.groups = string.Explode(",", groups)

	local maxwidth = 0//170 + 4 + 30
	local scrw = ScrW()-100
	
	for k,v in pairs(altboard.data_values) do
		if maxwidth < scrw and maxwidth + v.width < scrw then
			maxwidth = maxwidth + v.width
		else
			table.remove(altboard.data_values, k)
		end
	end
	
	local width = maxwidth+155 // math.Clamp(ScrW() * 0.7, 600, maxwidth)
	local buffer = 60
	local boxbuffer = 15
	
	local bar = 28//24 // 25px
	altboard.playerlist = {}	
	-- altboard.playerlist = table.SortByKey(altboard.playerlist, "Team")

	local players = player.GetAll()
	for k,v in pairs(player.GetAll()) do
		local time = altboard.GetTime(v) or 0
	
		altboard.playerlist[k] = {Player = v, SortVal = tonumber(v:Team())*10000000000 - time}
	end
	
	table.SortByMember(altboard.playerlist, "SortVal", true)
	
	
	
	altboard.MyMessage = "droke"
	
	-- height = buffer + buffer + bar*#altboard.playerlist
	
	altboard.MousePresses = {}	
	
	altboard.panel = vgui.Create("DPanel")
	altboard.panel:MouseCapture(true)
	-- altboard.panel:SetSize( width, height)
	-- altboard.panel:SetPos( ScrW() / 2 - ( width / 2 ), ScrH() / 2 - ( height / 2 ) )	
	altboard.panel:SetSize( width, ScrH())
	altboard.panel:SetPos( ScrW() / 2 - ( width / 2 ), 0 )	
	altboard.panel:SetVisible( true )
	altboard.panel:SetMouseInputEnabled(true)
	-- altboard.panel:SetKeyboardInputEnabled(false)
	-- altboard.panel:RequestFocus()
	altboard.panel:MakePopup()
	altboard.panel:SetKeyboardInputEnabled(false)
	
	
	altboard.phrase = altboard.desc
	
	
	
	altboard.panel.OnKeyCodePressed = function(key)
		return false
	end
	
	altboard.panel.OnMousePressed = function(vg, key)
		altboard.MousePresses[key] = CurTime() + 0.1
	end
	
	altboard.WasMousePressed = function(key)	// kek
		-- print(altboard.MousePresses[key], key)
		-- PrintTable(altboard.MousePresses)
		if altboard.MousePresses[key] and altboard.MousePresses[key] > CurTime() then
			
			altboard.MousePresses[key] = nil
			return true
		else
			return false
		end
		
	end
	
	
	
	altboard.IsOnScoreboard = function() return altboard.SelectedPage == 1 or !altboard.SelectedPage end

	altboard.SetToolTip = function(text)
		altboard.ToolTip = text
		altboard.ToolTipParsed = markup.Parse("<font=alt_tooltip>" .. altboard.ToolTip .. "</font>" )
		altboard.ToolTipDieTime = CurTime() + 0.1
	end	
	
	altboard.DrawToolTip = function()
		if altboard.ToolTip and altboard.ToolTipDieTime and altboard.ToolTipDieTime > CurTime() then
		
			local text = altboard.ToolTip
			
			surface.SetFont("alt_tooltip")
			local x,y = gui.MouseX() + 8, gui.MouseY()
			local w,h = surface.GetTextSize(text)
			
			
			
			local margin = 5
			
			x = math.Clamp(x, w+margin*2, ScrW() - (w+margin*2))
			
			draw.RoundedBox(6, x-w - margin, y-h - margin, w + margin*2, h + margin*2, Color(0,0,0,220))
			
			-- surface.SetTextColor( 255, 255, 255, 200 )
			-- surface.SetTextPos( x,y)
			-- surface.DrawText(text )
			
			altboard.ToolTipParsed:Draw( x-w, y-h ) // TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			
					
			
		end
		
	end	
	
	altboard.panel.Paint = function()
		if !altboard.panel or !altboard.panel:IsValid() then return false end
	
		local w2 = altboard.panel:GetWide()
		local h2 = altboard.panel:GetTall()
		
		local x2, y2 = altboard.panel:GetPos()
	
		local x = buffer
		local y = buffer
		local w = w2 - (buffer*2)
		
		local animspeed = GetConVarNumber("altboard_speed") or altboard.defaultspeed
		
		local targetH = bar*#altboard.playerlist
		if (!altboard.IsOnScoreboard()) then
			targetH = buffer + buffer + 200 // pageheight?
		end
		
		altboard.CurHeight = math.Approach(altboard.CurHeight or 0, targetH, FrameTime() * animspeed)
		
		if (animspeed > 1500) then
			altboard.CurHeight = targetH
		end
		
		-- local height_at_target = altboard.CurHeight == targetH
		
		local h = altboard.CurHeight
		
		
		y = ScrH()/2 - h/2
	
		if (#altboard.avatars > #players) then
			altboard.avatars[1]:Remove()
			table.remove(altboard.avatars,1)
		end
		
		draw.RoundedBox( 6, x-1 - 5, y - buffer - 5, w+2 + 10, h + buffer + 10, Color(altboard.colour.r,altboard.colour.g,altboard.colour.b,250)) // outer
		
		draw.RoundedBox( 0, x-1, y - buffer, w+2, buffer, Color(0,0,0,50)) // header
		
		draw.RoundedBox( 0, x-1, y, w+2, h, Color(0,0,0,50)) // body
		
		
		

		
		
		surface.SetTexture(altboard.gradient_cen)
		surface.SetDrawColor(Color(altboard.colour.r,altboard.colour.g,altboard.colour.b,200))
		surface.DrawTexturedRect(0, y-buffer-5, w2, buffer)
		-- surface.DrawTexturedRect(x, y+h+5-2, w, 2)
		
		//box
		
		-- draw.RoundedBox( 16, x-boxbuffer, y-boxbuffer, w+boxbuffer*2, h+boxbuffer*2, Color(50,50, 50,255) )
		
		local tabY = y - buffer
		local tabW = 80
		local tabX = x + w - (tabW*#altboard.pages) + 5
		
		
		draw.RoundedBox( 4, x-6, tabY - 5, w+12, 24 - 10, Color(0,0,0,150) )
		
		for i = 1, #altboard.pages do
			local page = altboard.pages[i]
			
			-- local tabX = tabX + 5
			local tabY = tabY - 5 
			
			local isSelected = false
			local isHovered = false

			if altboard.mouseInRegion(x2+tabX, y2+tabY, tabW-1, 24) then				
				isHovered = true				
			end
			
			-- draw.RoundedBox( 4, tabX, tabY, tabW-1, 24, Color(50,50,50,100) )
			
		
			
			surface.SetDrawColor(Color(50,75,100,200))
			if altboard.SelectedPage == i or (!altboard.SelectedPage and i == 1) then
				surface.SetDrawColor(Color(200,150,0,20))
				
				
				isSelected = true
			end
			
			draw.RoundedBox( 4, tabX + 5, tabY, tabW-1 - 10, 24 - 10, Color(80,80,80,50) )
			if isHovered then
				draw.RoundedBox( 4, tabX + 5, tabY, tabW-1 - 10, 24 - 10, Color(255,180,0,20) )
			
				surface.SetDrawColor(Color(255,180,0,20))	
			end
			
			surface.SetTexture(altboard.gradient_cen)
			surface.DrawTexturedRect(tabX + 15, tabY, tabW - 30, 14)
			
			
			
			-- draw.RoundedBox( 4, tabX+2, tabY, tabW-1-4, 24-4, Color(150,150,150,100) )
			
			
		
			
			if isHovered then
				if altboard.WasMousePressed(MOUSE_LEFT) then
					altboard.SelectedPage = i
					
					for i = 1, #altboard.avatars do
						altboard.avatars[i]:Remove()
					end
					
					altboard.avatars = {}
					
					if altboard.page and altboard.page:IsValid() then
						altboard.page:Remove()
						altboard.page = nil
					end
					
					if altboard.page_URLs[i] then
					
						altboard.page = vgui.Create( "HTML", altboard.panel )
						altboard.page:SetPos( x-1, y+2 )
						altboard.page:SetSize( w+2, h+2 )
						
						altboard.page:MouseCapture(false)
						altboard.page:SetMouseInputEnabled(false)
						altboard.page:SetKeyboardInputEnabled(false)
						altboard.page:SetZPos(100)
						-- altboard.page:MakePopup(true)
						
						altboard.page:OpenURL( altboard.page_URLs[i] ) 
					
					elseif page == "Options" then
						// make a regular panel with options in it
						
						altboard.page = vgui.Create( "DPanel", altboard.panel )
						altboard.page:SetPos( x-1, y+2 )
						altboard.page:SetSize( w+2, h+2 )
						
						altboard.page:MouseCapture(false)
						altboard.page:SetMouseInputEnabled(false)
						altboard.page:SetKeyboardInputEnabled(false)
						altboard.page:SetZPos(100)
						
						altboard.page.Paint = function(w,h)
							draw.RoundedBox( 4, 0, 0, w, h, Color(150,150,150,100) )	
						end
						
					end
					
					
				end
			end
			
			draw.SimpleText( page, "alt3", tabX+tabW/2, tabY+8, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
			
			tabX = tabX + tabW
		end
		
		
		// buttons
		
		
		
		
		
		///
		
		
		-- draw.RoundedBox( 2, x-1, y+2, w+2, h+2 , Color(100,100,100,150) )
		
		surface.SetTexture(altboard.gradient_cen)
		surface.SetDrawColor(Color(100,100,100,100))
		surface.DrawTexturedRect(x + w*0.2, y-buffer-5, w * 0.6, buffer+5)
		
		local bump = 4
		
		altboard.name = string.Trim(altboard.name)
		
		surface.SetFont("alt1")
		local text_w, text_h = surface.GetTextSize(altboard.name)
		
		local hsv = HSVToColor(math.sin(CurTime() % 180) * 180, 1, 1)
		draw.SimpleText( altboard.name, "alt1_glow", x + 5, y-buffer+4 + bump, Color(hsv.r, hsv.g, hsv.b, 10), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		
		draw.SimpleText( altboard.name, "alt1_glow", x, y-buffer+5 + bump, altboard.colour, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText( altboard.name, "alt1", x + 5 + 1, y-buffer+5 + 1 + bump, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText( altboard.name, "alt1", x + 5, y-buffer+5 + bump, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		
		
		
		
		draw.SimpleText( altboard.phrase, "alt2", x +1+text_w + 12, tabY+10+1 + bump, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText( altboard.phrase, "alt2", x +text_w + 12, tabY+10 + bump, Color(200,200,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		
		// lined things
		surface.SetTexture(altboard.gradient_cen)
		surface.SetDrawColor(Color(255,255,255,25 ))
		surface.DrawTexturedRect(x, y-3+1, w, 2)
		surface.DrawTexturedRect(x, y+h+3-3, w, 2)
		
		-- print(timeToStr)
		local uptime = timeToStr(CurTime(), true)	
		-- local uptime = fusion.ConvertTime(CurTime())	
		local uptime_x, uptime_y = x +1+text_w + 12, tabY+10 + 22
		
		surface.SetFont("alt2")
		local uptime_w, uptime_h = surface.GetTextSize(uptime)
		
		if altboard.mouseInRegion(x2 + uptime_x, y2 + uptime_y,uptime_w,uptime_h) then
			
			draw.RoundedBox(4, uptime_x-2, uptime_y-2, uptime_w + 4, uptime_h + 4, Color(255,255,255,10))		
			-- print("asdads")
			
			altboard.SetToolTip("uptime")
			
		end	
		
		
		draw.SimpleText( uptime, "alt2", uptime_x+1, uptime_y+1, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText( uptime, "alt2", uptime_x, uptime_y, Color(200,200,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		
		local droke = "altboard by droke"
		-- local uptime = fusion.ConvertTime(CurTime())	
		local droke_x, droke_y = x+2, y-buffer-4
		
		surface.SetFont("alt3")
		local droke_w, droke_h = surface.GetTextSize(droke)
		
		if altboard.mouseInRegion(x2 + droke_x, y2 + droke_y,droke_w,droke_h) then
			
			draw.RoundedBox(4, droke_x-2, droke_y-2, droke_w + 4, droke_h + 4, Color(255,255,255,10))		
			-- print("asdads")
			
			-- altboard.SetToolTip("")
			
			draw.SimpleText( droke, "alt3", droke_x, droke_y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		end	
		
		
		-- draw.SimpleText( altboard.MyMessage, "alt3", x+w+2, 4, Color(0,0,0,255), TEXT_ALIGN_RIGHT)
		draw.SimpleText( droke, "alt3", droke_x, droke_y, Color(255,255,255,2), TEXT_ALIGN_LEFT)
		
		local userGroupX = 0.35
		local fragsX = 0.55
		local entsX = 0.65
		local pingX = 0.75
		local timeX = 0.99		
		
		if (altboard.IsOnScoreboard()) then
			-- draw.SimpleText( "K/D", "alt2", x+w*fragsX +1, y-25+1, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			-- draw.SimpleText( "K/D", "alt2", x+w*fragsX, y-25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- draw.SimpleText( "Entities", "alt2", x+w*entsX +1, y-25+1, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			-- draw.SimpleText( "Entities", "alt2", x+w*entsX, y-25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			
			-- draw.SimpleText( "Time Played", "alt2", x+w*timeX +1, y-25 + 1, Color(0,0,0,100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			-- draw.SimpleText( "Time Played", "alt2", x+w*timeX, y-25, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			
			-- draw.SimpleText( "Ping", "alt2", x+w*pingX +1, y-25 + 1, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			-- draw.SimpleText( "Ping", "alt2", x+w*pingX, y-25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
			y=y+0
			for i = 1, #altboard.playerlist do
				
				local myAlpha = 1 //math.Clamp((y-400) / altboard.CurHeight, 0, 1)// 0-1
				
				-- print(i, (y-buffer*2), i, altboard.CurHeight)
			
				if (i*bar > altboard.CurHeight) then myAlpha = 0 end
						
			
				local p = altboard.playerlist[i].Player
				
				if (p:IsValid()) then
					
					local pcolour = altboard.getTeamColour(p)
					
					//team.GetColor(p:Team())	
					
					local avatar = altboard.avatars[i]
					
					if (myAlpha > 0) then
					if avatar and avatar:IsValid() then	
						
						avatar:SetPos(x+0,y+1)
						avatar:SetVisible(true)
						
						avatar:SetPlayer(p)
					else
						local avatar = vgui.Create("AvatarImage", altboard.panel)
						avatar:SetZPos(100)
						avatar:SetPlayer(p)
						avatar:SetSize(bar-2, bar-2)
						avatar:SetPos(0, 0)
						avatar:SetVisible(false)
						avatar:MouseCapture(false)
						avatar:SetMouseInputEnabled(false)
						avatar:SetKeyboardInputEnabled(false)

						
						altboard.avatars[i] = avatar
					end
					end
					
					local mouseOver = false
					
							
				
					
					
					
				
					//usergroup
					
					
					local usergroup = altboard.getTeamName(p) // team.GetName(p:Team())
					if altboard.mouseInRegion(x2+x, y2+y, w, bar) then
						
						-- usergroup = team.GetName(p:Team())//p:GetNWString("usergroup")	
						usergroup = p:GetNWString("usergroup")	
						pcolour = team.GetColor(p:Team()) //altboard.getTeamColour(p)
						
						mouseOver = true				
				
						if altboard.WasMousePressed(MOUSE_RIGHT) then
							altboard.dropmenu = DermaMenu()
							
													
							
							altboard.dropmenu = DermaMenu()
							
							local goto = altboard.dropmenu:AddOption( "Goto", function() RunConsoleCommand(altboard.CommandPrefix, "goto", target) end )
							goto:SetIcon( "icon16/arrow_switch.png" )							
							
							local steam_profile = altboard.dropmenu:AddOption( "Steam Profile", function() p:ShowProfile() end )
							steam_profile:SetIcon( "icon16/application_osx_terminal.png" )
							
							if (p:IsMuted()) then
								local mute = altboard.dropmenu:AddOption( "Unmute", function() p:SetMuted(false) end )
								mute:SetIcon( "icon16/sound_low.png" ) 
							end
							
							if (!p:IsMuted()) then
								local mute = altboard.dropmenu:AddOption( "Mute", function() p:SetMuted(true) end )
								mute:SetIcon( "icon16/sound_mute.png" ) 
							end
								
								local target = "$" .. p:UserID()		

								if fusion then
									target = p:SteamID()
								end
							
							-- if (LocalPlayer():IsAdmin()) then
								local subMenu, dropMenuOption = altboard.dropmenu:AddSubMenu( "Utility" )
								dropMenuOption:SetIcon( "icon16/wand.png" )
								
								subMenu:AddOption( "Goto", function() RunConsoleCommand(altboard.CommandPrefix, "goto", target) end )
								subMenu:AddOption( "Bring", function() RunConsoleCommand(altboard.CommandPrefix, "bring", target) end )
								subMenu:AddOption( "Print Details", function() 
									
									print("ID: " .. p:UserID(), "Name: " ..p:Name())
									print("Usergroup: " .. p:GetNWString("usergroup"), "SteamID: " ..p:SteamID())
									print("Ping: " .. p:Ping())
									
									local time = altboard.GetTime(p)
									local timespent = timeToStr( time, true)
									
									print("Timespent: " .. timespent)
									print("Frags: " .. p:Frags(), "Deaths: " .. p:Deaths(), p:Frags()/p:Deaths())
									
									print("Spawned:")
									for i = 1, #counts do								
										print(p:GetCount(counts[i]) .. "\t" .. counts[i])
									end
									
									

								end )
								
							-- end
							
							if (LocalPlayer():IsAdmin() or LocalPlayer():IsUserGroup("trialdef")) then
								local subMenu, dropMenuOption = altboard.dropmenu:AddSubMenu( "Punish" )
								dropMenuOption:SetIcon( "icon16/user_red.png" )
								subMenu:AddOption( "Kick", function() RunConsoleCommand(altboard.CommandPrefix, "kick", target) end )
								subMenu:AddOption( "Jail", function() RunConsoleCommand(altboard.CommandPrefix, "jail", target) end )
								subMenu:AddOption( "Unjail", function() RunConsoleCommand(altboard.CommandPrefix, "unjail", target) end )						
								subMenu:AddOption( "JailTP", function() RunConsoleCommand(altboard.CommandPrefix, "jailtp", target) end )
								subMenu:AddOption( "Gag", function() RunConsoleCommand(altboard.CommandPrefix, "gag", target) end )
								subMenu:AddOption( "Ungag", function() RunConsoleCommand(altboard.CommandPrefix, "ungag", target) end )
								subMenu:AddOption( "Ragdoll", function() RunConsoleCommand(altboard.CommandPrefix, "ragdoll", target) end )
								subMenu:AddOption( "Unragdoll", function() RunConsoleCommand(altboard.CommandPrefix, "unragdoll", target) end )
								subMenu:AddOption( "Slay", function() RunConsoleCommand(altboard.CommandPrefix, "slay", target) end )
								subMenu:AddOption( "Slap", function() RunConsoleCommand(altboard.CommandPrefix, "slap", target) end )
								subMenu:AddOption( "Spectate", function() RunConsoleCommand(altboard.CommandPrefix, "spectate", target) end )
								
								
								subMenu:AddOption( "CExec", function() 
								
								Derma_StringRequest(
									"CExec -> " .. p:Name(),
									"Input command.",
									"say Well done droke!",
									function( text ) RunConsoleCommand(altboard.CommandPrefix, "cexec", target, "" .. text .. "")  end,
									function( text ) end
								 )
								
								
								
								end )
												
							
								local subMenu, dropMenuOption = altboard.dropmenu:AddSubMenu( "Ban" )
								dropMenuOption:SetIcon( "icon16/bomb.png" )
								subMenu:AddOption( "5 minutes", function() RunConsoleCommand(altboard.CommandPrefix, "ban", target, "5") end )
								subMenu:AddOption( "1 hour", function() RunConsoleCommand(altboard.CommandPrefix, "ban", target, "60") end )
								subMenu:AddOption( "1 day", function() RunConsoleCommand(altboard.CommandPrefix, "ban", target, "1440") end )
								subMenu:AddOption( "Permanent", function() RunConsoleCommand(altboard.CommandPrefix, "ban", target, "0") end )
							end
							
							if (LocalPlayer():IsSuperAdmin()) then					
								local subMenu, dropMenuOption = altboard.dropmenu:AddSubMenu( "Rank" )
								dropMenuOption:SetIcon( "icon16/shield.png" )
								
								for i = 1, #altboard.groups do
								subMenu:AddOption( altboard.groups[i], function() RunConsoleCommand(altboard.CommandPrefix, "adduser", target, altboard.groups[i]) end )
								end
						
							end
							
							altboard.dropmenu:Open()
						end
						
						
					end
					
					draw.RoundedBox( 0, x, y+1, w, bar-2, Color(150,150,150,50*myAlpha) )
					
					draw.RoundedBox( 0, x, y+1 + (bar-2) / 2, w, (bar-2) / 2, Color(9,9,9,100*myAlpha) ) // shadow???
					
					draw.RoundedBox( 0, x, y+1, w, bar-2, Color(pcolour.r, pcolour.g, pcolour.b, 100*myAlpha))
					
					surface.SetTexture(altboard.gradient_cen)
					surface.SetDrawColor(Color(pcolour.r, pcolour.g, pcolour.b, 150*myAlpha))
					surface.DrawTexturedRect(x, y, w, bar)
					
					
					-- what
					surface.SetTexture(altboard.gradient_cen)
					surface.SetDrawColor(Color(pcolour.r, pcolour.g, pcolour.b, 50*myAlpha))			
					surface.DrawTexturedRect(x - buffer, y, w2, bar)
					
							
					
					-- render.SetScissorRect( x2+x, y2+y, w, bar, true ) -- Enable the rect
				
					//altboard.currentlyhovered = altboard.currentlyhovered or nil
					
					local curX = x+30
					for i = 1, #altboard.data_values do
				
						local data = altboard.data_values[i]
						local width = data.width
		
						surface.SetFont("alt2")					
						local myX, myY = curX, y+bar/2
						local myText = data.get(p)
						local myW, myH = surface.GetTextSize(myText)	
						
						local noText = false
						if altboard.currentlyhovered and i!=altboard.currentlyhovered then
							width = altboard.minwidth
							noText = true
							
						end							
							
						-- draw.RoundedBox(0, myX, myY - myH/2, width, myH, Color(255,255,255,5*myAlpha))			
						if altboard.mouseInRegion(x2 + myX, y2 + myY - myH/2,width,myH) then
							
							if data.hoverwidth then altboard.currentlyhovered = i end
							
							width = data.hoverwidth or width
							
							draw.RoundedBox(4, myX, myY - myH/2, width, myH, Color(255,255,255,30*myAlpha))		
							-- print("asdads")
							
							if data.tooltipfunc then							
								altboard.SetToolTip(data.tooltipfunc(p))
							else
								altboard.SetToolTip(data.tooltip)
							end
							
						elseif altboard.currentlyhovered == i then	
							altboard.currentlyhovered = nil
						end
						
						if (!data.hoverwidth or data.hoverwidth == width) and !noText then
							
						
							draw.SimpleText( myText, "alt2_glow", myX + width/2, myY, Color(0,0,0,255*myAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							draw.SimpleText( myText, "alt2", myX + width/2+1, myY+1, Color(0,0,0,100*myAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							draw.SimpleText( myText, "alt2", myX + width/2, myY, Color(255,255,255,255*myAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						else
							draw.RoundedBox(2, myX, myY - myH/2, width, myH, Color(60,60,60,60*myAlpha))	
							draw.RoundedBox(2, myX+1, myY - myH/2+1, width-2, myH-2, Color(255,255,255,60*myAlpha))	
						end

						curX = curX + width	
					end
					
					-- render.SetScissorRect( 0, 0, 0, 0, false ) 
					
					-- if p:IsSuperAdmin() then			
						-- surface.SetMaterial(altboard.admin_icon)
					-- elseif p:IsAdmin() then
						-- surface.SetMaterial(altboard.mod_icon)
					-- else
						-- surface.SetMaterial(altboard.user_icon)
					-- end
					
					-- surface.SetDrawColor(Color(pcolour.r, pcolour.g, pcolour.b, 200))
					-- surface.SetDrawColor(Color(255, 255, 255, 200))
					-- surface.DrawTexturedRect(x+5, y+4, 16, 16)
					
					if (mouseOver) then
						surface.SetTexture(altboard.gradient_cen)
						-- surface.SetDrawColor(Color(pcolour.r, pcolour.g, pcolour.b, 200))
						surface.SetDrawColor(Color(255, 255, 255, 10*myAlpha))
						surface.DrawTexturedRect(x, y, w, bar)
					end
					
					
					y = y + bar
				end
			end
		else
			if altboard.SelectedPage then
			
				draw.SimpleText( altboard.pages[altboard.SelectedPage], "alt2", x+w-5 + 1, y-25 + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				draw.SimpleText( altboard.pages[altboard.SelectedPage], "alt2", x+w-5, y-25, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				
			end
		end
		
		-- if altboard.drawPage then
			-- altboard.drawPage(x,y,w,h)
		-- end
		
	end
	-- 
	
	-- if altboard.oldx and altboard.oldy then
		-- gui.SetMousePos(ScrW()/2, ScrH()/2 - 200)
	-- end
	
	
	
end

hook.Add("DrawOverlay", "altboard", function()
	if altboard and altboard.DrawToolTip then altboard.DrawToolTip() end
end)

function altboard.destroy()
	altboard.CurHeight = 0
	
	if (altboard.panel and altboard.panel:IsValid()) then
		altboard.panel:Remove()
	end
	
	if altboard.avatars then
		for k,v in pairs(altboard.avatars) do
			v:Remove()		
		end
	end
	
	if altboard.page then
		altboard.page:Remove()
		altboard.page = nil
	end
	
	if altboard.dropmenu and altboard.dropmenu:IsValid() then
		-- altboard.dropmenu:SetVisible(false)
		altboard.dropmenu:Remove()
	end
		
	altboard.panel = nil
end

concommand.Add("altboard_open", function(ply, cmd, args) altboard.create() end)
concommand.Add("altboard_close", function(ply, cmd, args) altboard.destroy() end)


hook.Add("ScoreboardShow", "altboard", function()
	altboard.create()
	
	return false
end)

hook.Add("ScoreboardHide", "altboard", function()
	-- altboard.oldx = gui.MouseX()
	-- altboard.oldy = gui.MouseY()
	
	altboard.SelectedPage = nil
	
	altboard.destroy()
	
	return false
end)