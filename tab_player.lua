-- ==========================================
-- DELTA HUB - Mundo 1 G2 - tab_player.lua
-- Solo pestaña Player | 62.5% -> 75%
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_player: falta hub (tab_farm/init)")
	return
end

S.Player = S.Player or {}
local P = S.Player
P.speedEnabled = P.speedEnabled or false
P.jumpEnabled = P.jumpEnabled or false
P.noclipEnabled = P.noclipEnabled or false
P.infJumpEnabled = P.infJumpEnabled or false
P.customSpeed = P.customSpeed or 16
P.customJump = P.customJump or 50

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/mundo-1-G2/main/"
local NEXT_URL = BASE .. "tab_events.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

setProgress(64, "Player", "Creando pestaña Player...")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end

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

local function makeSwitch(parent, text, order)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 36)
	row.LayoutOrder = order or 1
	corner(row, 6)
	local label = Instance.new("TextLabel")
	label.Parent = row
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -58, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	local hit = Instance.new("TextButton")
	hit.Parent = row
	hit.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
	hit.Position = UDim2.new(1, -46, 0.5, -11)
	hit.Size = UDim2.new(0, 36, 0, 22)
	hit.Text = ""
	corner(hit, 99)
	local knob = Instance.new("Frame")
	knob.Parent = hit
	knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 2, 0.5, -9)
	corner(knob, 99)
	return row, hit, knob, label
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

-- Page
local playerPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Player = playerPage

local tabPlayer = makeTabButton("Player", 2)
tabPlayer.MouseButton1Click:Connect(function()
	if S.UI.showOnlyPage then
		S.UI.showOnlyPage(playerPage, "Player")
	end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Player" end
end)

local mov = section(playerPage, "Movimiento", 1)

local function setSwitch(row, hit, knob, on)
	if on then
		hit.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
		knob.Position = UDim2.new(1, -20, 0.5, -9)
	else
		hit.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
		knob.Position = UDim2.new(0, 2, 0.5, -9)
	end
end

local speedRow, speedHit, speedKnob = makeSwitch(mov, "Speed boost", 1)
setSwitch(speedRow, speedHit, speedKnob, P.speedEnabled)
speedHit.MouseButton1Click:Connect(function()
	P.speedEnabled = not P.speedEnabled
	setSwitch(speedRow, speedHit, speedKnob, P.speedEnabled)
end)

local speedBox = Instance.new("TextBox")
speedBox.Parent = mov
speedBox.Size = UDim2.new(1, -4, 0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
speedBox.Text = tostring(P.customSpeed or 16)
speedBox.TextColor3 = Color3.fromRGB(240, 240, 245)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.LayoutOrder = 2
corner(speedBox, 6)
speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n and n > 0 then P.customSpeed = n end
end)

local jumpRow, jumpHit, jumpKnob = makeSwitch(mov, "Jump power", 3)
setSwitch(jumpRow, jumpHit, jumpKnob, P.jumpEnabled)
jumpHit.MouseButton1Click:Connect(function()
	P.jumpEnabled = not P.jumpEnabled
	setSwitch(jumpRow, jumpHit, jumpKnob, P.jumpEnabled)
end)

local jumpBox = Instance.new("TextBox")
jumpBox.Parent = mov
jumpBox.Size = UDim2.new(1, -4, 0, 28)
jumpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
jumpBox.Text = tostring(P.customJump or 50)
jumpBox.TextColor3 = Color3.fromRGB(240, 240, 245)
jumpBox.Font = Enum.Font.Gotham
jumpBox.TextSize = 12
jumpBox.LayoutOrder = 4
corner(jumpBox, 6)
jumpBox.FocusLost:Connect(function()
	local n = tonumber(jumpBox.Text)
	if n and n > 0 then P.customJump = n end
end)

local noclipRow, noclipHit, noclipKnob = makeSwitch(mov, "Noclip", 5)
setSwitch(noclipRow, noclipHit, noclipKnob, P.noclipEnabled)
noclipHit.MouseButton1Click:Connect(function()
	P.noclipEnabled = not P.noclipEnabled
	setSwitch(noclipRow, noclipHit, noclipKnob, P.noclipEnabled)
	if S.Signals and S.Signals.SetNoclip then S.Signals.SetNoclip(P.noclipEnabled) end
end)

local infRow, infHit, infKnob = makeSwitch(mov, "Infinite jump", 6)
setSwitch(infRow, infHit, infKnob, P.infJumpEnabled)
infHit.MouseButton1Click:Connect(function()
	P.infJumpEnabled = not P.infJumpEnabled
	setSwitch(infRow, infHit, infKnob, P.infJumpEnabled)
end)

-- Apply loops
task.spawn(function()
	while true do
		task.wait(0.1)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			if P.speedEnabled then hum.WalkSpeed = P.customSpeed else hum.WalkSpeed = 16 end
			if P.jumpEnabled then hum.JumpPower = P.customJump end
		end
	end
end)

S.Signals.SetNoclip = function(on)
	P.noclipEnabled = on
	task.spawn(function()
		while P.noclipEnabled do
			local char = player.Character
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
			RunService.Stepped:Wait()
		end
	end)
end

UserInputService.JumpRequest:Connect(function()
	if P.infJumpEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

setProgress(70, "Player", "Player listo")
print("[Delta Hub G2] tab_player listo")

-- Chain next
task.spawn(function()
	task.wait(0.2)
	local body = S.httpGet and select(1, S.httpGet("tab_events.lua"))
	if body then
		local fn = loadstring(body)
		if fn then pcall(fn) end
	end
end)
