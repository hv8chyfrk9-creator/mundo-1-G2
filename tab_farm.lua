-- DELTA HUB tab_farm G2: cerebro + UI (sin tsunami)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function reportOk(m)
	if S.reportOk then S.reportOk(m) end
end
local function reportError(step, detail)
	if S.reportError then S.reportError(step, detail) end
end

local function http(name)
	if S.httpGet then return S.httpGet(name) end
	return nil, "sin httpGet"
end

local function runFile(name, label, pct)
	setProgress(pct, "Farm", label)
	local body, herr = http(name)
	if not body then
		setProgress(pct, "Error", "No descargo: " .. name)
		reportError("descarga " .. name, herr or label)
		return false
	end
	reportOk(name .. " descargado (" .. #body .. "b)")
	local fn, lerr = loadstring(body)
	if not fn then
		reportError("loadstring " .. name, tostring(lerr))
		return false
	end
	local ok, runErr = pcall(fn)
	if not ok then
		reportError("ejecutar " .. name, tostring(runErr))
		return false
	end
	reportOk(name .. " OK")
	return true
end

if not runFile("farm_brain.lua", "Cargando cerebro...", 51) then return end
if not (S.Brain and S.Brain.startRoute) then
	reportError("farm_brain", "S.Brain.startRoute no existe")
	return
end
if not runFile("farm_ui.lua", "Cargando pestaña Farm...", 54) then return end
if not (S.UI and S.UI.ContentArea) then
	reportError("farm_ui", "ContentArea no existe")
	return
end
setProgress(58, "Farm", "Pestaña Farm lista")

task.spawn(function()
	task.wait(0.15)
	if not runFile("tab_player.lua", "Cargando Player...", 60) then return end
	task.wait(0.3)
	runFile("runtime_fixes.lua", "Parches UI...", 64)
end)
