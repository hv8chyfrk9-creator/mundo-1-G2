-- tab_config.lua loader G2
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/mundo-1-G2/main/"
local urls = { BASE .. "tab_config_ui.lua" }
for _, url in ipairs(urls) do
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 80 then
		local head = string.lower(string.sub(body, 1, 60))
		if not string.find(head, "<html", 1, true) then
			local fn, err = loadstring(body)
			if fn then
				local okRun, runErr = pcall(fn)
				if okRun then print("[Delta Hub] config from", url) return end
				warn("[Config] run", runErr)
			else warn("[Config] loadstring", err) end
		end
	end
end
warn("[Config] no se pudo cargar")
if S.fadeAndDestroyLoading then pcall(S.fadeAndDestroyLoading) end
S.scriptReady = true
