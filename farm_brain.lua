-- DELTA HUB farm_brain G2 (hitbox start/finish, sin CLAIM_WAIT fijo)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

S.Farm = S.Farm or {}
S.Brain = S.Brain or {}
S.Signals = S.Signals or {}
local F = S.Farm
local B = S.Brain

B.busy = false
B.routeRunning = false
F.routeRunning = false
F.routeMode = F.routeMode or "normal"
F.routeSpeed = F.routeSpeed or 250
F.infinite = F.infinite or false
F.delayTime = F.delayTime or 0
F.selectedRealName = F.selectedRealName or "WinBlock1"

-- Cola de eventos encontrados durante el recorrido
B.pendingEvent = nil -- { pos = Vector3, cf = CFrame, kind = string, obj = Instance? }

local function notify(msg)
	if S.Farm and S.Farm.notify then S.Farm.notify(msg) return end
	pcall(function() print("[Brain]", msg) end)
end

local function approachSpeed(distance, nextDist)
	local maxSpeed = tonumber(F.routeSpeed) or 250
	local mode = F.routeMode or "normal"
	local floorSpeed = 0
	if mode == "fast" then floorSpeed = 50
	elseif mode == "ultra" or mode == "super" then floorSpeed = 150 end
	local brake = 18
	if nextDist and nextDist < 12 then brake = 10 end
	if distance >= brake then return maxSpeed end
	local t = math.clamp(distance / brake, 0, 1)
	return math.max(maxSpeed * t * t, floorSpeed)
end

local function findWinBlockPos(wbName)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == wbName then
			if obj:IsA("BasePart") then return obj.Position, obj end
			local okp, piv = pcall(function() return obj:GetPivot() end)
			if okp and piv then return piv.Position, obj end
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			if part then return part.Position, obj end
		end
	end
	return nil, nil
end

local function clearBV(hrp)
	if not hrp then return end
	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if bv then bv:Destroy() end
	hrp.AssemblyLinearVelocity = Vector3.zero
end

-- Hitbox 10x10x10 no colisionable en el primer CFrame
local function ensureStartHitbox(cf)
	local folder = Workspace:FindFirstChild("DeltaHubG2Hitbox")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "DeltaHubG2Hitbox"
		folder.Parent = Workspace
	end
	local box = folder:FindFirstChild("StartFinishBox")
	if not box then
		box = Instance.new("Part")
		box.Name = "StartFinishBox"
		box.Size = Vector3.new(10, 10, 10)
		box.Anchored = true
		box.CanCollide = false
		box.CanQuery = true
		box.CanTouch = false
		box.Transparency = 1
		box.Parent = folder
	end
	box.CFrame = cf
	return box
end

local function playerInHitbox(hrp, box)
	if not hrp or not box or not box.Parent then return false end
	local rel = box.CFrame:PointToObjectSpace(hrp.Position)
	local half = box.Size * 0.5
	return math.abs(rel.X) <= half.X and math.abs(rel.Y) <= half.Y and math.abs(rel.Z) <= half.Z
end

function B.stopRoute(hard)
	F.routeRunning = false
	B.routeRunning = false
	B.busy = false
	B._leftStartBox = false
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	clearBV(hrp)
	if S.Signals.SetNoclip then S.Signals.SetNoclip(false) end
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(false) end
	if hard then notify("Recorrido detenido") end
end

-- Llamado por events: "encontré algo en este CFrame"
function B.reportFoundEvent(data)
	if type(data) ~= "table" then return end
	if not data.pos and data.cf then data.pos = data.cf.Position end
	if not data.pos then return end
	B.pendingEvent = data
	notify("Evento guardado para después del recorrido")
end

local function goCollectPending()
	local pend = B.pendingEvent
	B.pendingEvent = nil
	if not pend or not pend.pos then return false end

	-- Re-check si sigue ahí (si tenemos referencia de objeto)
	local stillThere = true
	if pend.obj and pend.obj.Parent == nil then
		stillThere = false
	end
	-- Si no hay obj, intentamos TP al pos y ver cerca
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local returnCf = hrp.CFrame
	pcall(function()
		hrp.CFrame = CFrame.new(pend.pos + Vector3.new(0, 3, 0))
		hrp.AssemblyLinearVelocity = Vector3.zero
	end)
	task.wait(0.25)

	-- Si el objeto ya no existe, volver
	if pend.obj and pend.obj.Parent == nil then
		stillThere = false
	end
	if not stillThere then
		pcall(function() hrp.CFrame = returnCf end)
		notify("Evento ya no está, se omite")
		return false
	end

	-- Pequeña espera para tocar / recoger
	task.wait(0.6)
	notify("Evento recogido")
	return true
end

local function runOneLap()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then return false end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(true) end

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end
	if not activeRoute or #activeRoute == 0 then notify("Sin CFrames") return false end

	local startCf = activeRoute[1]
	local hitbox = ensureStartHitbox(startCf)
	B._leftStartBox = false

	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end

	-- TP al primer CFrame
	hrp.CFrame = startCf
	hrp.AssemblyLinearVelocity = Vector3.zero
	task.wait(0.1)

	local wbName = F.selectedRealName or "WinBlock1"
	local targetRouteIndex = #activeRoute
	local winPos = nil
	local lastWbSearch = 0

	local function searchWin()
		local pos = select(1, findWinBlockPos(wbName))
		if not pos then return end
		winPos = pos
		local bestI, bestD = 1, math.huge
		for ri = 1, #activeRoute do
			local d = (activeRoute[ri].Position - pos).Magnitude
			if d < bestD then bestD, bestI = d, ri end
		end
		targetRouteIndex = bestI
	end
	searchWin()

	-- Recorrido por CFrames
	for i = 2, #activeRoute do
		if not F.routeRunning then break end
		if i > targetRouteIndex then break end

		-- Detectar salida de hitbox (recorrido en marcha)
		if not B._leftStartBox and hrp and not playerInHitbox(hrp, hitbox) then
			B._leftStartBox = true
		end

		if hum.Health <= 0 then
			if S.waitAliveHrp then
				hrp = S.waitAliveHrp(activeRoute[math.max(1, i - 1)])
				hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hrp then
					bv = hrp:FindFirstChildOfClass("BodyVelocity")
					if not bv then
						bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = hrp
					end
				else
					return false
				end
			else
				return false
			end
		end

		if tick() - lastWbSearch >= 1 then
			lastWbSearch = tick()
			searchWin()
			if i > targetRouteIndex then break end
		end

		local targetPos = activeRoute[i].Position
		local guard = 0
		while hrp and hrp.Parent and (hrp.Position - targetPos).Magnitude > 2.5 and F.routeRunning and hum and hum.Health > 0 and guard < 600 do
			guard = guard + 1
			if not B._leftStartBox and not playerInHitbox(hrp, hitbox) then
				B._leftStartBox = true
			end
			if tick() - lastWbSearch >= 1 then
				lastWbSearch = tick()
				searchWin()
				if i > targetRouteIndex then break end
			end
			local dist = (hrp.Position - targetPos).Magnitude
			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			if dist > 0.05 then bv.Velocity = (targetPos - hrp.Position).Unit * spd else bv.Velocity = Vector3.zero end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	-- Empuje corto al WinBlock (sin espera fija después)
	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		local t0 = tick()
		while hrp and hrp.Parent and (hrp.Position - winPos).Magnitude > 3 and tick() - t0 < 6 and F.routeRunning do
			if not bv or not bv.Parent then
				bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = hrp
			end
			bv.Velocity = (winPos - hrp.Position).Unit * 22
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	clearBV(hrp)
	if S.Signals.SetNoclip then S.Signals.SetNoclip(false) end

	-- Esperar a que el jugador RE-ENTRE a la hitbox del primer CFrame
	-- (eso marca el fin del recorrido de forma natural)
	if F.routeRunning and B._leftStartBox then
		local tEnd = tick()
		while F.routeRunning and tick() - tEnd < 25 do
			hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp and playerInHitbox(hrp, hitbox) then
				break -- re-entró → recorrido terminado
			end
			-- Si hay pending event y ya salimos del recorrido hacia el WinBlock, no forzamos más
			task.wait(0.08)
		end
	end

	return true
end

function B.startRoute()
	if B.routeRunning then return false end
	F.routeRunning = true
	B.routeRunning = true
	B.busy = true
	B._leftStartBox = false
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(true) end
	task.spawn(function()
		repeat
			runOneLap()
			if not F.routeRunning then break end

			-- Si hay evento pendiente → ir a por él (con re-check)
			if B.pendingEvent then
				goCollectPending()
		end

			-- Delay entre recorridos (usuario): mantener en el primer CFrame quieto
			if F.infinite and F.delayTime and F.delayTime > 0 then
				local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode)) or S.routeCFrames
				local startCf = activeRoute and activeRoute[1]
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and startCf then
					pcall(function()
						hrp.CFrame = startCf
						hrp.AssemblyLinearVelocity = Vector3.zero
					end)
				end
				-- El jugador puede moverse solo; no lo forzamos cada frame
				task.wait(F.delayTime)
			end
		until not F.infinite or not F.routeRunning
		B.stopRoute(false)
	end)
	return true
end

function B.requestMove(opts)
	opts = opts or {}
	if B.routeRunning then
		if F.infinite then B._queuedMove = opts; return false, "route_infinite_queue" end
		return false, "route_busy"
	end
	B.busy = true
	task.spawn(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and opts.cf then hrp.CFrame = opts.cf
		elseif hrp and opts.pos then hrp.CFrame = CFrame.new(opts.pos) end
		task.wait(opts.hold or 0.3)
		B.busy = false
		if B._queuedMove and not B.routeRunning then
			local q = B._queuedMove; B._queuedMove = nil; B.requestMove(q)
		end
	end)
	return true, "ok"
end

function B.isBusy()
	return B.busy or B.routeRunning
end

print("[Delta Hub G2] farm_brain listo (hitbox)")
