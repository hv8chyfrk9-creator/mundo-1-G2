-- ==========================================
-- DELTA HUB - Mundo 1 G2 - tab_player.lua
-- Solo pestaña Player
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

local playerPage = Instance.new("ScrollingFrame")
playerPage.Name = "PlayerPage"
playerPage.Parent = S.UI.ContentArea
playerPage.BackgroundTransparency = 1
playerPage.Size = UDim2.new(1, 0, 1, 0)
playerPage.CanvasSize = UDim2.new(0, 0, 0, 380)
playerPage.ScrollBarThickness = 4
playerPage.Visible = false
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Player = playerPage

local function makeToggle(parent, label, y, get, set)
	local row = Instance.new("TextButton")
	row.Parent = parent
	row.Position = UDim2.new(0, 4, 0, y)
	row.Size = UDim2.new(1, -8, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	row.Font = Enum.Font.GothamBold
	row.Text = label .. ": " .. (get() and "ON" or "OFF")
	row.TextColor3 = get() and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)
	row.TextSize = 12
	corner(row, 6)
	row.MouseButton1Click:Connect(function()
		set(not get())
		row.Text = label .. ": " .. (get() and "ON" or "OFF")
		row.TextColor3 = get() and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)
	end)
	return row
end

makeToggle(playerPage, "Speed", 8, function() return P.speedEnabled end, function(v) P.speedEnabled = v end)
makeToggle(playerPage, "Jump", 46, function() return P.jumpEnabled end, function(v) P.jumpEnabled = v end)
makeToggle(playerPage, "Noclip", 84, function() return P.noclipEnabled end, function(v)
	P.noclipEnabled = v
	if S.Signals and S.Signals.SetNoclip then S.Signals.SetNoclip(v) end
end)
makeToggle(playerPage, "Inf Jump", 122, function() return P.infJumpEnabled end, function(v) P.infJumpEnabled = v end)

local speedBox = Instance.new("TextBox")
speedBox.Parent = playerPage
speedBox.Position = UDim2.new(0, 4, 0, 160)
speedBox.Size = UDim2.new(0.5, -8, 0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
speedBox.Font = Enum.Font.Gotham
speedBox.Text = tostring(P.customSpeed)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderText = "Speed value"
corner(speedBox, 6)
speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n and n > 0 then P.customSpeed = n end
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

-- Noclip signal
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

-- Inf jump
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
