-- DELTA HUB G2 tab_events (sin tsunami)
local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then return end

S.UI.Pages = S.UI.Pages or {}
local page = Instance.new("ScrollingFrame")
page.Name = "EventsPage"
page.Parent = S.UI.ContentArea
page.BackgroundTransparency = 1
page.Size = UDim2.new(1, 0, 1, 0)
page.CanvasSize = UDim2.new(0, 0, 0, 200)
page.Visible = false
S.UI.Pages.Events = page

local label = Instance.new("TextLabel")
label.Parent = page
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, -10, 0, 40)
label.Position = UDim2.new(0, 5, 0, 10)
label.Font = Enum.Font.GothamBold
label.Text = "Events (G2)\nSin tsunami - eventos basicos"
label.TextColor3 = Color3.fromRGB(200, 200, 210)
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left

print("[Delta Hub G2] tab_events listo")

-- chain extras
task.spawn(function()
	task.wait(0.15)
	if S.httpGet then
		local body = select(1, S.httpGet("tab_extras.lua"))
		if body then local fn = loadstring(body); if fn then pcall(fn) end end
	end
end)
