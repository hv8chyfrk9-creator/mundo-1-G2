-- ==========================================
-- DELTA HUB - Mundo 1 G2 - tab_extras.lua
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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
X.renderWhite = X.renderWhite ~= false
X.statsOn = X.statsOn or false
X.antiKey = X.antiKey or false

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end
local function notify(text)
	if S.notify then S.notify(text) else warn("[Delta Hub]", text) end
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

local function makeButton(parent, text, order)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1, -4, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = order or 1
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
	end)
	return row
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

local extrasPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Extras = extrasPage

local tabExtras = makeTabButton("Extras", 4)
tabExtras.MouseButton1Click:Connect(function()
	if S.UI.showOnlyPage then S.UI.showOnlyPage(extrasPage, "Extras") end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Extras" end
end)

local antiBody = section(extrasPage, "Anti lag", 1)
local decBtn = makeButton(antiBody, "Borrar Decorations + Props", 1)
decBtn.MouseButton1Click:Connect(function()
	local n = deleteNamed({ "Decorations", "Props", "Decoration" })
	notify("Borrados: " .. n)
end)
local hallBtn = makeButton(antiBody, "Borrar Halloween + HalloweenMeshes", 2)
hallBtn.MouseButton1Click:Connect(function()
	local n = deleteNamed({ "Halloween", "HalloweenMeshes", "HallowenMeshes" })
	notify("Halloween borrado: " .. n)
end)
makeToggleRow(antiBody, "Keycaps transparentes (loop)", 3, function() return X.antiKey end, function(v)
	X.antiKey = v
	if v then
		task.spawn(function()
			while X.antiKey do
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "key") or string.find(string.lower(obj.Name), "cap")) then
						pcall(function() obj.Transparency = 1; obj.CanCollide = false end)
					end
				end
				task.wait(2)
			end
		end)
	end
end)

local pantBody = section(extrasPage, "Pantalla", 2)
makeToggleRow(pantBody, "No render", 1, function() return X.renderOn end, function(v)
	X.renderOn = v
	pcall(function()
		local lighting = game:GetService("Lighting")
		if v then
			lighting.GlobalShadows = false
			lighting.FogEnd = 9e9
		else
			lighting.GlobalShadows = true
		end
	end)
end)
makeToggleRow(pantBody, "Stats", 2, function() return X.statsOn end, function(v) X.statsOn = v end)

setProgress(95, "Extras", "Extras listo")
if S.fadeAndDestroyLoading then task.delay(0.5, function() S.fadeAndDestroyLoading() end) end
print("[Delta Hub G2] tab_extras listo")
notify("G2 world listo")
