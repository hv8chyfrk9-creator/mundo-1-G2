-- DELTA HUB farm_ui: UI + señales al cerebro (sin mover al jugador)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.UI = S.UI or {}
S.Farm = S.Farm or {}
S.Signals = S.Signals or {}
local F = S.Farm

F.routeMode = F.routeMode or "normal"
F.routeSpeed = F.routeSpeed or 250
F.infinite = F.infinite or false
F.delayTime = F.delayTime or 0
F.selectedRealName = F.selectedRealName or "WinBlock1"
F.selectedDisplayName = F.selectedDisplayName or "+1 Wins"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
setProgress(54, "Farm", "Creando pestaña Farm...")

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = o
	return c
end

function F.notify(msg)
	pcall(function()
		local sg = S.UI.ScreenGui
		if not sg then return end
		local n = Instance.new("TextLabel")
		n.Parent = sg
		n.Size = UDim2.new(0, 220, 0, 28)
		n.Position = UDim2.new(0.5, -110, 0.12, 0)
		n.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		n.TextColor3 = Color3.fromRGB(240, 240, 245)
		n.Font = Enum.Font.Gotham
		n.TextSize = 12
		n.Text = tostring(msg)
		corner(n, 6)
		task.delay(2, function() pcall(function() n:Destroy() end) end)
	end)
end

local function ensureHub()
	if S.UI.ScreenGui and S.UI.ScreenGui.Parent then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "DeltaHubMinimal"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 999
	sg.Parent = playerGui
	S.UI.ScreenGui = sg

	local main = Instance.new("Frame")
	main.Name = "MainFrame"
	main.Parent = sg
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	main.BackgroundTransparency = 0.12
	main.Position = UDim2.new(0.5, -200, 0.5, -180)
	main.Size = UDim2.new(0, 400, 0, 360)
	main.Active = true
	main.Draggable = true
	main.Visible = false
	corner(main, 10)
	S.UI.MainFrame = main

	local top = Instance.new("Frame")
	top.Parent = main
	top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	top.Size = UDim2.new(1, 0, 0, 36)
	corner(top, 10)
	local title = Instance.new("TextLabel")
	title.Parent = top
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 12, 0, 0)
	title.Size = UDim2.new(0, 180, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.Text = "Delta Hub · G2"
	title.TextColor3 = Color3.fromRGB(230, 230, 240)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left

	local closeBtn = Instance.new("TextButton")
	closeBtn.Parent = top
	closeBtn.BackgroundTransparency = 1
	closeBtn.Position = UDim2.new(1, -36, 0, 0)
	closeBtn.Size = UDim2.new(0, 36, 1, 0)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	closeBtn.TextSize = 14
	closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

	local tabBar = Instance.new("Frame")
	tabBar.Parent = main
	tabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	tabBar.Position = UDim2.new(0, 0, 0, 36)
	tabBar.Size = UDim2.new(1, 0, 0, 32)
	S.UI.TabBar = tabBar

	local content = Instance.new("Frame")
	content.Name = "ContentArea"
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 8, 0, 72)
	content.Size = UDim2.new(1, -16, 1, -80)
	S.UI.ContentArea = content
	S.UI.Pages = S.UI.Pages or {}

	-- Floating open button
	local openBtn = Instance.new("TextButton")
	openBtn.Parent = sg
	openBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 160)
	openBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
	openBtn.Size = UDim2.new(0, 48, 0, 48)
	openBtn.Font = Enum.Font.GothamBold
	openBtn.Text = "DH"
	openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	openBtn.TextSize = 14
	openBtn.Active = true
	openBtn.Draggable = true
	corner(openBtn, 24)
	openBtn.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)
	S.UI.OpenBtn = openBtn
end

ensureHub()

-- Page switch helper
function S.showOnlyPage(name)
	if not S.UI.Pages then return end
	for n, page in pairs(S.UI.Pages) do
		if page and page.Parent then
			page.Visible = (n == name)
		end
	end
end

-- Farm page
local farmPage = Instance.new("ScrollingFrame")
farmPage.Name = "FarmPage"
farmPage.Parent = S.UI.ContentArea
farmPage.BackgroundTransparency = 1
farmPage.Size = UDim2.new(1, 0, 1, 0)
farmPage.CanvasSize = UDim2.new(0, 0, 0, 420)
farmPage.ScrollBarThickness = 4
farmPage.Visible = true
S.UI.Pages.Farm = farmPage

local function makeLabel(parent, text, y)
	local l = Instance.new("TextLabel")
	l.Parent = parent
	l.BackgroundTransparency = 1
	l.Position = UDim2.new(0, 4, 0, y)
	l.Size = UDim2.new(1, -8, 0, 20)
	l.Font = Enum.Font.GothamBold
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200, 200, 210)
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

makeLabel(farmPage, "Modo de ruta", 4)
local modeRow = Instance.new("Frame")
modeRow.Parent = farmPage
modeRow.BackgroundTransparency = 1
modeRow.Position = UDim2.new(0, 0, 0, 26)
modeRow.Size = UDim2.new(1, 0, 0, 32)
local modes = { {k="normal", t="Normal"}, {k="fast", t="Fast"}, {k="super", t="Super"} }
for i, m in ipairs(modes) do
	local b = Instance.new("TextButton")
	b.Parent = modeRow
	b.Size = UDim2.new(0.32, -4, 1, 0)
	b.Position = UDim2.new((i-1)*0.33, 2, 0, 0)
	b.BackgroundColor3 = (F.routeMode == m.k) and Color3.fromRGB(50, 120, 200) or Color3.fromRGB(40, 40, 50)
	b.Font = Enum.Font.GothamBold
	b.Text = m.t
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 12
	corner(b, 6)
	b.MouseButton1Click:Connect(function()
		F.routeMode = m.k
		for _, child in ipairs(modeRow:GetChildren()) do
			if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
		end
		b.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
	end)
end

makeLabel(farmPage, "Velocidad", 64)
local speedBox = Instance.new("TextBox")
speedBox.Parent = farmPage
speedBox.Position = UDim2.new(0, 4, 0, 86)
speedBox.Size = UDim2.new(0.5, -8, 0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
speedBox.Font = Enum.Font.Gotham
speedBox.Text = tostring(F.routeSpeed)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
corner(speedBox, 6)
speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n and n > 0 then F.routeSpeed = n end
end)

makeLabel(farmPage, "WinBlock", 122)
local wbList = Instance.new("ScrollingFrame")
wbList.Parent = farmPage
wbList.Position = UDim2.new(0, 4, 0, 144)
wbList.Size = UDim2.new(1, -8, 0, 120)
wbList.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
wbList.CanvasSize = UDim2.new(0, 0, 0, 0)
wbList.ScrollBarThickness = 3
corner(wbList, 6)

local function rebuildWbList()
	for _, c in ipairs(wbList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	local ordered = S.orderedWinBlocks or {}
	local y = 2
	for _, wb in ipairs(ordered) do
		local b = Instance.new("TextButton")
		b.Parent = wbList
		b.Size = UDim2.new(1, -6, 0, 24)
		b.Position = UDim2.new(0, 3, 0, y)
		b.BackgroundColor3 = (F.selectedRealName == wb.real) and Color3.fromRGB(40, 100, 160) or Color3.fromRGB(36, 36, 44)
		b.Font = Enum.Font.Gotham
		b.Text = wb.display or wb.real
		b.TextColor3 = Color3.fromRGB(240, 240, 245)
		b.TextSize = 12
		b.TextXAlignment = Enum.TextXAlignment.Left
		corner(b, 4)
		b.MouseButton1Click:Connect(function()
			F.selectedRealName = wb.real
			F.selectedDisplayName = wb.display
			rebuildWbList()
		end)
		y = y + 26
	end
	wbList.CanvasSize = UDim2.new(0, 0, 0, y)
end
rebuildWbList()

local startBtn = Instance.new("TextButton")
startBtn.Parent = farmPage
startBtn.Position = UDim2.new(0, 4, 0, 276)
startBtn.Size = UDim2.new(0.48, -6, 0, 36)
startBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
startBtn.Font = Enum.Font.GothamBold
startBtn.Text = "Iniciar Ruta"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 13
corner(startBtn, 8)
startBtn.MouseButton1Click:Connect(function()
	if S.Brain and S.Brain.startRoute then
		S.Brain.startRoute()
		F.notify("Ruta iniciada")
	end
end)

local stopBtn = Instance.new("TextButton")
stopBtn.Parent = farmPage
stopBtn.Position = UDim2.new(0.52, 2, 0, 276)
stopBtn.Size = UDim2.new(0.48, -6, 0, 36)
stopBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Text = "Detener"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 13
corner(stopBtn, 8)
stopBtn.MouseButton1Click:Connect(function()
	if S.Brain and S.Brain.stopRoute then S.Brain.stopRoute(true) end
end)

local infToggle = Instance.new("TextButton")
infToggle.Parent = farmPage
infToggle.Position = UDim2.new(0, 4, 0, 320)
infToggle.Size = UDim2.new(1, -8, 0, 30)
infToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
infToggle.Font = Enum.Font.GothamBold
infToggle.Text = "Infinito: OFF"
infToggle.TextColor3 = Color3.fromRGB(255, 120, 120)
infToggle.TextSize = 12
corner(infToggle, 6)
infToggle.MouseButton1Click:Connect(function()
	F.infinite = not F.infinite
	infToggle.Text = "Infinito: " .. (F.infinite and "ON" or "OFF")
	infToggle.TextColor3 = F.infinite and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)
end)

-- Tab buttons
local function makeTab(name, label, x)
	local b = Instance.new("TextButton")
	b.Parent = S.UI.TabBar
	b.Size = UDim2.new(0, 70, 1, -4)
	b.Position = UDim2.new(0, x, 0, 2)
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
	b.Font = Enum.Font.GothamBold
	b.Text = label
	b.TextColor3 = Color3.fromRGB(220, 220, 230)
	b.TextSize = 11
	corner(b, 6)
	b.MouseButton1Click:Connect(function()
		S.showOnlyPage(name)
	end)
	return b
end
makeTab("Farm", "Farm", 6)
makeTab("Player", "Player", 80)
makeTab("Events", "Events", 154)
makeTab("Extras", "Extras", 228)

S.UI.MainFrame.Visible = true
setProgress(58, "Farm", "Pestaña Farm lista")
if S.fadeAndDestroyLoading then task.delay(0.8, function() S.fadeAndDestroyLoading() end) end
print("[Delta Hub G2] farm_ui listo")
