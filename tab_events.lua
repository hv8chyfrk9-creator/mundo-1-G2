-- DELTA HUB tab_events G2 (nombre EXACTO; BattleCoin + número 1-4000)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_events: falta hub")
	return
end

S.Events = S.Events or {}
local E = S.Events
E.chocolate = E.chocolate or false
E.candy = E.candy or false
E.coin = E.coin or false
E.xp = E.xp or false
E.collectMode = E.collectMode or "Tween"
E.queue = E.queue or {}
E.seen = E.seen or {}
E.autoSpecialKeys = E.autoSpecialKeys or false
E.searchInterval = 1
E.busy = false
E.priority = E.priority or { "chocolate", "battlecoin", "xp", "candy", "specialkeys" }

-- Nombres EXACTOS (no contains). BattleCoin se maneja aparte con número.
local EXACT = {
	chocolate = { "ChocolateHunt", "Chocolate Hunt" },
	candy = { "EventCoin", "CandyCorn", "Candy Corn" },
	xp = { "ElectrifiedKeycap", "XPEventKey", "XP Event Key" },
	specialkeys = { "SpecialKey", "Special Key" },
}

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function notify(t)
	if S.Farm and S.Farm.notify then S.Farm.notify(t)
	elseif S.notify then S.notify(t)
	else warn("[Delta Hub]", t) end
end
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = p
	return c
end

setProgress(76, "Events", "Creando Events...")

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
	end)
	return row
end

local eventsPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Events = eventsPage

local tabEvents = makeTabButton("Events", 3)
tabEvents.MouseButton1Click:Connect(function()
	if S.UI.showOnlyPage then S.UI.showOnlyPage(eventsPage, "Events") end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Events" end
end)

local adminBody = section(eventsPage, "Admin abuse", 1)
makeToggleRow(adminBody, "Auto Chocolate Hunt", 1, function() return E.chocolate end, function(v) E.chocolate = v end)
makeToggleRow(adminBody, "Auto Battle Coin", 2, function() return E.coin end, function(v) E.coin = v end)
makeToggleRow(adminBody, "Auto XP Event Key", 3, function() return E.xp end, function(v) E.xp = v end)

local limitedBody = section(eventsPage, "Limited Time", 2)
makeToggleRow(limitedBody, "Auto Candy Corn", 1, function() return E.candy end, function(v) E.candy = v end)

local dailyBody = section(eventsPage, "Daily", 3)
makeToggleRow(dailyBody, "Auto Special Keys", 1, function() return E.autoSpecialKeys end, function(v) E.autoSpecialKeys = v end)

local modeBtn = Instance.new("TextButton")
modeBtn.Parent = eventsPage
modeBtn.Size = UDim2.new(1, -8, 0, 30)
modeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
modeBtn.Font = Enum.Font.Gotham
modeBtn.Text = "Modo: " .. (E.collectMode or "Tween")
modeBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
modeBtn.TextSize = 12
modeBtn.LayoutOrder = 99
corner(modeBtn, 6)
modeBtn.MouseButton1Click:Connect(function()
	E.collectMode = (E.collectMode == "Tween") and "TP" or "Tween"
	modeBtn.Text = "Modo: " .. E.collectMode
end)

-- ===== Búsqueda: exacto + BattleCoinN (1-4000) =====
local function objectPosition(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj.Position end
	local ok, piv = pcall(function() return obj:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = obj:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

local function exactKind(name)
	if not name then return nil end

	-- BattleCoin siempre lleva número (1..4000)
	local nstr = name:match("^BattleCoin(%d+)$")
		or name:match("^CoinBattleCoin(%d+)$")
		or name:match("^Battle Coin(%d+)$")
	if nstr then
		local n = tonumber(nstr)
		if n and n >= 1 and n <= 4000 then
			return "coin"
		end
	end

	for kind, list in pairs(EXACT) do
		for _, exact in ipairs(list) do
			if name == exact then return kind end
		end
	end
	return nil
end

local function anyOn()
	return E.chocolate or E.candy or E.coin or E.xp or E.autoSpecialKeys
end

local function rememberEvent(obj)
	local kind = exactKind(obj.Name)
	if not kind then return false end
	if kind == "chocolate" and not E.chocolate then return false end
	if kind == "candy" and not E.candy then return false end
	if kind == "coin" and not E.coin then return false end
	if kind == "xp" and not E.xp then return false end
	if kind == "specialkeys" and not E.autoSpecialKeys then return false end
	local pos = objectPosition(obj)
	if not pos then return false end
	local id = tostring(obj:GetFullName())
	if E.seen[id] then return false end
	E.seen[id] = true

	if S.Brain and S.Brain.routeRunning and S.Brain.reportFoundEvent then
		S.Brain.reportFoundEvent({ pos = pos, kind = kind, obj = obj })
		return true
	end

	table.insert(E.queue, { obj = obj, pos = pos, kind = kind })
	return true
end

local function goToPos(hrp, dest)
	if not hrp or not dest then return end
	if E.collectMode == "TP" then
		hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3, 0))
	else
		local bv = hrp:FindFirstChildOfClass("BodyVelocity")
		if not bv then
			bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Parent = hrp
		end
		local t0 = tick()
		while hrp.Parent and (hrp.Position - dest).Magnitude > 3 and tick() - t0 < 12 do
			bv.Velocity = (dest - hrp.Position).Unit * 80
			task.wait()
		end
		bv.Velocity = Vector3.zero
	end
end

if not S._eventsLoopsStarted then
	S._eventsLoopsStarted = true
	task.spawn(function()
		while true do
			task.wait(E.searchInterval or 1)
			if not anyOn() then continue end
			if S.Farm and S.Farm.routeRunning then
				for _, obj in ipairs(Workspace:GetDescendants()) do
					rememberEvent(obj)
				end
				continue
			end
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end
			E.queue = {}
			E.seen = {}
			for _, obj in ipairs(Workspace:GetDescendants()) do
				rememberEvent(obj)
			end
			if #E.queue == 0 then E.searchInterval = 1; continue end
			local order = {}
			for i, n in ipairs(E.priority) do order[n] = i end
			local function kk(k) return k == "coin" and "battlecoin" or k end
			table.sort(E.queue, function(a, b) return (order[kk(a.kind)] or 99) < (order[kk(b.kind)] or 99) end)
			E.busy = true
			E.searchInterval = 0.3
			local returnPos = hrp.Position
			while #E.queue > 0 and anyOn() and not (S.Farm and S.Farm.routeRunning) do
				local item = table.remove(E.queue, 1)
				if not item or not item.pos then continue end
				if item.obj and not item.obj.Parent then continue end
				if item.obj and exactKind(item.obj.Name) == nil then continue end
				local pos = objectPosition(item.obj) or item.pos
				goToPos(hrp, pos)
				task.wait(0.4)
				hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then break end
			end
			if hrp and returnPos then
				if E.collectMode == "TP" then
					hrp.CFrame = CFrame.new(returnPos + Vector3.new(0, 3, 0))
				else
					goToPos(hrp, returnPos)
				end
			end
			E.busy = false
			E.searchInterval = 1
		end
	end)
end

setProgress(82, "Events", "Events listo")
print("[Delta Hub G2] tab_events listo (BattleCoinN 1-4000)")

task.spawn(function()
	task.wait(0.2)
	local body = S.httpGet and select(1, S.httpGet("tab_extras.lua"))
	if body then
		local fn = loadstring(body)
		if fn then pcall(fn) end
	end
end)
