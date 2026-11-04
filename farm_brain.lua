-- DELTA HUB farm_brain G2 (thin reload)
local S = getgenv().DeltaHub
local url = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/_g2_farm_brain.lua"
local ok, body = pcall(function() return game:HttpGet(url) end)
if ok and type(body) == "string" and #body > 100 then
	local fn, err = loadstring(body)
	if fn then
		local okRun, runErr = pcall(fn)
		if not okRun then warn("[G2 Brain] run", runErr) end
	else
		warn("[G2 Brain] loadstring", err)
	end
else
	warn("[G2 Brain] no se pudo descargar cerebro")
end
