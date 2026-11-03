-- ==========================================
-- DELTA HUB - Mundo 1 G2 - tab_extras.lua
-- Anti-lag unificado + selector colapsable
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_extras: falta hub")
	return
end

S.Extras = S.Extras or {}
local X = S.Extras
X.renderOn = X.renderOn or false
X.statsOn = X.statsOn or false
X.antiLagOn = X.antiLagOn or false
X.antiOpts = X.antiOpts or { decorations = true, halloween = true, keycaps = true }
X.antiSelOpen = X.antiSelOpen or false

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end
local function notify(text)
	if S.Farm and S.Farm.notify then S.Farm.notify(text)
	elseif S.notify then S.notify(text)
	else warn("[Delta Hub]", text) end
end
local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end

setProgress(88, "Extras", "Creando Extras...")

local function section(parent, title, order)
	local wrap = Instance.new("Frame")
	wrap.Parent = parent
	wrap.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	wrap.BackgroundTransparency = 0.25
	wrap.Size = UDim2.new(1, -8, 0, 0)
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.LayoutOrder = order or 1
	corner(wrap, 8)
	local lay = Instance.new("UIListLayout")
	lay.Parent = wrap
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 6)
	local pad = Instance.new("UIPadding")
	pad.Parent = wrap
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	local head = Instance.new("TextLabel")
	head.Parent = wrap
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 20)
	head.Font = Enum.Font.GothamBold
	head.Text = title
	head.TextColor3 = Color3.fromRGB(255, 255, 255)
	head.TextSize = 13
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 0
	return wrap
end

local function createScrollingPage(parent)
	local sc = Instance.new("ScrollingFrame")
	sc.Parent = parent
	sc.BackgroundTransparency = 1
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.ScrollBarThickness = 4
	sc.Visible = false
	local lay = Instance.new("UIListLayout")
	lay.Parent = sc
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 8)
	local pad = Instance.new("UIPadding")
	pad.Parent = sc
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 8)
	return sc
end

local function makeTabButton(name, order)
	local b = Instance.new("TextButton")
	b.Parent = S.UI.Sidebar
	b.Size = UDim2.new(0, 92, 0, 42)
	b.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
	b.Font = Enum.Font.GothamBold
	b.Text = name
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 14
	b.LayoutOrder = order
	corner(b, 6)
	return b
end

local function makeToggleRow(parent, text, order, get, set)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 34)
	row.LayoutOrder = order or 1
	corner(row, 6)
	local label = Instance.new("TextLabel")
	label.Parent = row
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	local btn = Instance.new("TextButton")
	btn.Parent = row
	btn.Size = UDim2.new(0, 50, 0, 22)
	btn.Position = UDim2.new(1, -56, 0.5, -11)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	local function refresh()
		local on = get()
		btn.Text = on and "ON" or "OFF"
		btn.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		btn.BackgroundColor3 = on and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(50, 40, 40)
	end
	refresh()
	corner(btn, 6)
	btn.MouseButton1Click:Connect(function()
		set(not get())
		refresh()
		if S.Config and S.Config.markDirty then S.Config.markDirty() end
	end)
	return row, btn, refresh
end

local function deleteNamed(prefixes)
	local count = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local name = obj.Name
		for _, pref in ipairs(prefixes) do
			if string.sub(name, 1, #pref) == pref or name == pref then
				pcall(function() obj:Destroy() end)
				count = count + 1
				break
			end
		end
	end
	return count
end

local function applyKeycaps()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local ln = string.lower(obj.Name)
			if string.find(ln, "key") or string.find(ln, "cap") then
				pcall(function() obj.Transparency = 1; obj.CanCollide = false end)
			end
		end
	end
end

local function runAntiLagOnce()
	local n = 0
	if X.antiOpts.decorations then n = n + deleteNamed({ "Decorations", "Props", "Decoration" }) end
	if X.antiOpts.halloween then n = n + deleteNamed({ "Halloween", "HalloweenMeshes", "HallowenMeshes" }) end
	if X.antiOpts.keycaps then applyKeycaps() end
	return n
end

local extrasPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Extras = extrasPage

local tabExtras = makeTabButton("Extras", 4)
tabExtras.MouseButton1Click:Connect(function()
	if S.UI.showOnlyPage then S.UI.showOnlyPage(extrasPage, "Extras") end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Extras" end
end)

local antiBody = section(extrasPage, "Anti lag", 1)

local optLabels = {
	{ key = "decorations", text = "Decorations / Props" },
	{ key = "halloween", text = "Halloween / Meshes" },
	{ key = "keycaps", text = "Keycaps transparentes" },
}

local function countSelected()
	local c = 0
	for _, v in pairs(X.antiOpts) do if v then c = c + 1 end end
	return c
end

local function summaryText()
	local parts = {}
	for _, info in ipairs(optLabels) do
		if X.antiOpts[info.key] then table.insert(parts, info.text) end
	end
	if #parts == 0 then return "Ninguna" end
	return table.concat(parts, ", ")
end

local selHeader = Instance.new("TextButton")
selHeader.Parent = antiBody
selHeader.Size = UDim2.new(1, -4, 0, 30)
selHeader.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
selHeader.Font = Enum.Font.Gotham
selHeader.TextSize = 12
selHeader.TextColor3 = Color3.fromRGB(240, 240, 245)
selHeader.TextXAlignment = Enum.TextXAlignment.Left
selHeader.LayoutOrder = 1
corner(selHeader, 6)

local selList = Instance.new("Frame")
selList.Parent = antiBody
selList.BackgroundTransparency = 1
selList.Size = UDim2.new(1, 0, 0, 0)
selList.AutomaticSize = Enum.AutomaticSize.Y
selList.Visible = X.antiSelOpen
selList.LayoutOrder = 2
local selLay = Instance.new("UIListLayout")
selLay.Parent = selList
selLay.SortOrder = Enum.SortOrder.LayoutOrder
selLay.Padding = UDim.new(0, 4)

local function refreshHeader()
	local arrow = X.antiSelOpen and "▼" or "▶"
	selHeader.Text = "  " .. arrow .. "  Opciones: " .. summaryText()
	selList.Visible = X.antiSelOpen
end

local antiSwitchRefresh

for i, info in ipairs(optLabels) do
	local row = Instance.new("TextButton")
	row.Parent = selList
	row.Size = UDim2.new(1, -4, 0, 28)
	row.BackgroundColor3 = X.antiOpts[info.key] and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(36, 36, 44)
	row.Font = Enum.Font.Gotham
	row.Text = (X.antiOpts[info.key] and "[x] " or "[ ] ") .. info.text
	row.TextColor3 = Color3.fromRGB(240, 240, 245)
	row.TextSize = 12
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.LayoutOrder = i
	corner(row, 6)
	row.MouseButton1Click:Connect(function()
		local was = X.antiOpts[info.key]
		if was and countSelected() <= 1 then
			notify("Debe quedar al menos 1 opción")
			return
		end
		X.antiOpts[info.key] = not was
		row.BackgroundColor3 = X.antiOpts[info.key] and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(36, 36, 44)
		row.Text = (X.antiOpts[info.key] and "[x] " or "[ ] ") .. info.text
		refreshHeader()
		if X.antiLagOn then
			X.antiLagOn = false
			if antiSwitchRefresh then antiSwitchRefresh() end
			notify("Anti lag OFF (cambiaste opciones)")
		end
		if S.Config and S.Config.markDirty then S.Config.markDirty() end
	end)
end

selHeader.MouseButton1Click:Connect(function()
	X.antiSelOpen = not X.antiSelOpen
	refreshHeader()
end)
refreshHeader()

local _, antiBtn, refreshAnti
_, antiBtn, refreshAnti = makeToggleRow(antiBody, "Anti lag activo", 10, function() return X.antiLagOn end, function(v)
	X.antiLagOn = v
	if v then
		runAntiLagOnce()
		notify("Anti lag ON")
		task.spawn(function()
			while X.antiLagOn do
				if X.antiOpts.keycaps then applyKeycaps() end
				if X.antiOpts.decorations or X.antiOpts.halloween then runAntiLagOnce() end
				task.wait(0.5)
			end
		end)
	else
		notify("Anti lag OFF")
	end
end)
antiSwitchRefresh = refreshAnti

local pantBody = section(extrasPage, "Pantalla", 2)
makeToggleRow(pantBody, "No render", 1, function() return X.renderOn end, function(v)
	X.renderOn = v
	pcall(function()
		local lighting = game:GetService("Lighting")
		if v then lighting.GlobalShadows = false; lighting.FogEnd = 9e9
		else lighting.GlobalShadows = true end
	end)
end)
makeToggleRow(pantBody, "Stats", 2, function() return X.statsOn end, function(v) X.statsOn = v end)

refreshHeader()

setProgress(95, "Extras", "Cargando Configuración...")
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/mundo-1-G2/main/"
local ok, body = pcall(function() return game:HttpGet(BASE .. "tab_config.lua") end)
if ok and type(body) == "string" and #body > 40 then
	local head = string.lower(string.sub(body, 1, 80))
	if not string.find(head, "<html", 1, true) then
		local fn, err = loadstring(body)
		if fn then
			local okRun, runErr = pcall(fn)
			if not okRun then warn("[Delta Hub] tab_config run", runErr) end
		else
			warn("[Delta Hub] tab_config loadstring", err)
		end
	end
else
	if S.fadeAndDestroyLoading then task.delay(0.5, function() S.fadeAndDestroyLoading() end) end
	S.scriptReady = true
	notify("G2 listo (sin config)")
end
print("[Delta Hub G2] tab_extras listo")
