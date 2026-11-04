-- G2 uses same UI module from Hallowen raw with FILE override via getgenv
getgenv()._DeltaHubConfigFile = "DeltaHub_G2_Configs.json"
getgenv()._DeltaHubConfigWorld = "g2"
local ok, body = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/tab_config_ui.lua")
end)
if ok and type(body) == "string" and #body > 80 then
	body = body:gsub('local FILE = "DeltaHub_HW_Configs.json"', 'local FILE = "DeltaHub_G2_Configs.json"')
	body = body:gsub('world="hallowen"', 'world="g2"')
	body = body:gsub('Hallowen world listo', 'G2 world listo')
	local fn, err = loadstring(body)
	if fn then pcall(fn) else warn("[G2 Config]", err) end
else
	warn("[G2 Config] no UI")
	local S = getgenv().DeltaHub
	if S then S.scriptReady = true if S.fadeAndDestroyLoading then pcall(S.fadeAndDestroyLoading) end end
end
