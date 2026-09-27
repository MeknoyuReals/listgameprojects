-- [[ ULTRA MEKNOYU GUI (LOCKED & PROTECTED) ]] --
local plr = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local mps = game:GetService("MarketplaceService")
local lighting = game:GetService("Lighting")
local guiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local HapticService = game:GetService("HapticService")
local Stats = game:GetService("Stats")
local cam = workspace.CurrentCamera
local mouse = plr:GetMouse()

-- // KONFIGURASI DISCORD WEBHOOK //
local DISCORD_WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL_HERE" -- Masukkan URL Webhook Discord Anda di sini

-- // FUNGSI PEMBUAT GRADIENT //
local function applyBlackGreyGradient(instance)
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 65, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
    })
    uiGradient.Parent = instance
    return uiGradient
end

-- // SCREEN GUI UTAMA //
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Mekno_Clean_Final"
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui and gethui()) or plr:WaitForChild("PlayerGui")

-- ==========================================
--        FITUR BARU: NOTIFICATION CUSTOM UI
-- ==========================================
local notifContainer = Instance.new("Frame", screenGui)
notifContainer.Name = "NotifContainer"
notifContainer.Size = UDim2.new(0, 250, 1, 0)
notifContainer.Position = UDim2.new(1, -260, 0, 20)
notifContainer.BackgroundTransparency = 1

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 8)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function createNotification(title, text, duration)
    duration = duration or 4
    local notifFrame = Instance.new("Frame", notifContainer)
    notifFrame.Size = UDim2.new(1, 0, 0, 60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notifFrame.Position = UDim2.new(1, 300, 0, 0)
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 6)
    applyBlackGreyGradient(notifFrame)

    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(0, 255, 128)

    local notifTitle = Instance.new("TextLabel", notifFrame)
    notifTitle.Size = UDim2.new(1, -15, 0, 20)
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 13
    notifTitle.TextColor3 = Color3.fromRGB(0, 255, 128)
    notifTitle.Text = title
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left

    local notifText = Instance.new("TextLabel", notifFrame)
    notifText.Size = UDim2.new(1, -15, 0, 30)
    notifText.Position = UDim2.new(0, 10, 0, 25)
    notifText.BackgroundTransparency = 1
    notifText.Font = Enum.Font.GothamMedium
    notifText.TextSize = 11
    notifText.TextColor3 = Color3.fromRGB(230, 230, 230)
    notifText.Text = text
    notifText.TextWrapped = true
    notifText.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(duration, function()
        local closeTween = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1.5, 0, 0, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

-- ==========================================
--        FITUR BARU: FPS AND MS TRACKER
-- ==========================================
local statGui = Instance.new("Frame", screenGui)
statGui.Name = "FPS_MS_Tracker"
statGui.Size = UDim2.new(0, 140, 0, 25)
statGui.Position = UDim2.new(0.5, -70, 0, 5)
statGui.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
statGui.Active = true
statGui.Draggable = true
Instance.new("UICorner", statGui).CornerRadius = UDim.new(0, 6)
applyBlackGreyGradient(statGui)

local statStroke = Instance.new("UIStroke", statGui)
statStroke.Thickness = 1.5
rs.RenderStepped:Connect(function()
    statStroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)
end)

local statLabel = Instance.new("TextLabel", statGui)
statLabel.Size = UDim2.new(1, 0, 1, 0)
statLabel.BackgroundTransparency = 1
statLabel.Font = Enum.Font.Code
statLabel.TextSize = 11
statLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statLabel.Text = "FPS: 60 | MS: 0"

local lastFpsCheck = tick()
local frameCount = 0

rs.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastFpsCheck >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastFpsCheck))
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        statLabel.Text = string.format("FPS: %d | MS: %d", fps, ping)
        frameCount = 0
        lastFpsCheck = currentTime
    end
end)

-- ==========================================
--        FITUR BARU: DISCORD WEBHOOK LOGIC
-- ==========================================
local function sendDiscordWebhook()
    if DISCORD_WEBHOOK_URL == "" or DISCORD_WEBHOOK_URL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then return end

    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not requestFunc then return end

    local executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor"
    local payload = {
        ["embeds"] = {{
            ["title"] = "🚀 Meknoyu GUI Executed!",
            ["color"] = 65280,
            ["fields"] = {
                {["name"] = "Player", ["value"] = plr.Name .. " (" .. plr.UserId .. ")", ["inline"] = true},
                {["name"] = "Executor", ["value"] = executor, ["inline"] = true},
                {["name"] = "Game ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "Job ID", ["value"] = tostring(game.JobId), ["inline"] = false}
            },
            ["footer"] = {["text"] = "Meknoyu System Logs"},
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    pcall(function()
        requestFunc({
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
end

-- ==========================================
--        MAIN MEKNOYU ENGINE LOAD
-- ==========================================
local function mainEngineLoad()
sendDiscordWebhook()

local states = {god=false, noclip=false, esp=false, tracer=false, fling=false, antifling=false, infJump=false, speed=false, fps=false, antirag=false, antijail=false, bypassac=false, tooltp=false, antitel=false, aimbot=false, aimActive=false, antirobux=false, savepos=false, disco=false, hcxxr=false, addpart=false, xray=false, tpKill=false, antiafk=false, invis=false, antivoid=false, antilag=false}
local originalTransparencies = {}
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid", 10)
local hrp = char:WaitForChild("HumanoidRootPart", 10)
local godConnection, lastPos, savedPos = nil, nil, nil
local platformPart = nil
local voidPart = nil
local invisOffset = -100

-- LOGIKA ANTI DETECT BARU
local oldIndex, oldNewIndex
local connection1, connection2

local function scanAndBypassLocalScripts(root)
    for _, obj in pairs(root:GetDescendants()) do
        if obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name:find("anticheat") or name:find("cheat") or name:find("detector") or name:find("adonis") or name:find("kick") then
                pcall(function()
                    obj.Disabled = true
                    obj:Destroy()
                end)
            end
        end
    end
end

local function applyAntiDetect(state)
    if state then
        local gmt = getrawmetatable(game)
        setreadonly(gmt, false)
        oldIndex = gmt.__index
        oldNewIndex = gmt.__newindex

        gmt.__index = newcclosure(function(self, key)
            if not checkcaller() then
                if tostring(self) == "Humanoid" and (key == "WalkSpeed" or key == "JumpPower") then
                    return 16
                end
                if tostring(self) == "HumanoidRootPart" and key == "CFrame" then
                    return oldIndex(self, "CFrame")
                end
            end
            return oldIndex(self, key)
        end)

        gmt.__newindex = newcclosure(function(self, key, value)
            if not checkcaller() then
                if (key == "Disabled" or key == "Parent") and (self:IsA("LocalScript") or self:IsA("ModuleScript")) then
                    if checkcaller() then 
                        return oldNewIndex(self, key, value)
                    else
                        return nil
                    end
                end
            end
            return oldNewIndex(self, key, value)
        end)
        setreadonly(gmt, true)

        pcall(function()
            scanAndBypassLocalScripts(plr.PlayerGui)
            scanAndBypassLocalScripts(plr.StarterGear)
        end)

        connection1 = workspace.DescendantAdded:Connect(function(v)
            if (v.Name:lower():find("anticheat") or v.Name:lower():find("detector") or v.Name:lower():find("cheat")) then
                pcall(function()
                    if v:IsA("BasePart") then v.CanTouch = false; v.CanQuery = false; v.CanCollide = false
                    elseif v:IsA("Script") or v:IsA("LocalScript") then v.Disabled = true end
                end)
            end
        end)

        connection2 = plr.PlayerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("LocalScript") then
                local name = descendant.Name:lower()
                if name:find("cheat") or name:find("kick") or name:find("detector") then
                    descendant.Disabled = true
                    descendant:Destroy()
                end
            end
        end)
    else
        if oldIndex and oldNewIndex then
            local gmt = getrawmetatable(game)
            setreadonly(gmt, false)
            gmt.__index = oldIndex
            gmt.__newindex = oldNewIndex
            setreadonly(gmt, true)
        end
        if connection1 then connection1:Disconnect() end
        if connection2 then connection2:Disconnect() end
    end
end

createNotification("Meknoyu GUI", "System Fully Loaded!", 5)

--// LANGIT MEKNOYU TEAMS //--
local discoSky = Instance.new("Sky")
discoSky.Name = "MeknoDiscoSky"
discoSky.SkyboxBk = "http://www.roblox.com/asset/?id=10134830810"
discoSky.SkyboxDn = "http://www.roblox.com/asset/?id=10134830810"
discoSky.SkyboxFt = "http://www.roblox.com/asset/?id=10134830810"
discoSky.SkyboxLf = "http://www.roblox.com/asset/?id=10134830810"
discoSky.SkyboxRt = "http://www.roblox.com/asset/?id=10134830810"
discoSky.SkyboxUp = "http://www.roblox.com/asset/?id=10134830810"

local skyGui = Instance.new("ScreenGui", screenGui)
skyGui.Name = "MeknoSkyTitle"
local skyText = Instance.new("TextLabel", skyGui)
skyText.Size = UDim2.new(1, 0, 0, 100)
skyText.Position = UDim2.new(0, 0, 0.05, 0)
skyText.BackgroundTransparency = 1
skyText.Text = "Meknoyu Teams >:)"
skyText.TextColor3 = Color3.fromRGB(200, 0, 0)
skyText.Font = Enum.Font.LuckiestGuy
skyText.TextSize = 65
skyText.Visible = false

local oldAmbient = lighting.Ambient
local oldOutdoor = lighting.OutdoorAmbient
local oldFog = lighting.FogColor

local virtualUser = game:GetService("VirtualUser")
pcall(function()
    plr.Idled:Connect(function()
        if states.antiafk then
            virtualUser:Button2Down(Vector2.new(0,0), cam.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0,0), cam.CFrame)
        end
    end)
end)

local function giveTpTool()
    local oldTool = plr.Backpack:FindFirstChild("Mekno TP Tool") or (char and char:FindFirstChild("Mekno TP Tool"))
    if oldTool then oldTool:Destroy() end
    local tpTool = Instance.new("Tool")
    tpTool.Name = "Mekno TP Tool"
    tpTool.RequiresHandle = false
    tpTool.Activated:Connect(function()
        if mouse.Hit and hrp then
            lastPos = CFrame.new(mouse.Hit.p + Vector3.new(0, 5, 0))
            hrp.CFrame = lastPos
        end
    end)
    tpTool.Parent = plr.Backpack
end

local function setupChar(c)
    char = c; hum = c:WaitForChild("Humanoid", 10); hrp = c:WaitForChild("HumanoidRootPart", 10)
    if hrp then lastPos = hrp.CFrame end
    if states.tooltp then task.defer(giveTpTool) end
end
if plr.Character then setupChar(plr.Character) end
plr.CharacterAdded:Connect(setupChar)

--// TELEPORT BACK GUI //--
local tpBackGui = Instance.new("Frame", screenGui); tpBackGui.Size = UDim2.new(0, 160, 0, 100); tpBackGui.Position = UDim2.new(0.8, 0, 0.5, 0); tpBackGui.BackgroundColor3 = Color3.fromRGB(255,255,255); tpBackGui.BackgroundTransparency = 0; tpBackGui.Visible = false; tpBackGui.Active = true; tpBackGui.Draggable = true; Instance.new("UICorner", tpBackGui); applyBlackGreyGradient(tpBackGui)
local saveBtn = Instance.new("TextButton", tpBackGui); saveBtn.Size = UDim2.new(0, 160 * 0.9, 0, 100 * 0.4); saveBtn.Position = UDim2.new(0.05, 0, 0.05, 0); saveBtn.Text = "Save Pos : OFF"; saveBtn.BackgroundColor3 = Color3.fromRGB(255,255,255); saveBtn.BackgroundTransparency = 0; saveBtn.TextTransparency = 0; saveBtn.TextColor3 = Color3.fromRGB(255,255,255); saveBtn.TextStrokeTransparency = 0; saveBtn.TextStrokeColor3 = Color3.new(0,0,0); Instance.new("UICorner", saveBtn); applyBlackGreyGradient(saveBtn)
local clickTpBtn = Instance.new("TextButton", tpBackGui); clickTpBtn.Size = UDim2.new(0, 160 * 0.9, 0, 100 * 0.4); clickTpBtn.Position = UDim2.new(0.05, 0, 0.55, 0); clickTpBtn.Text = "Click TP Back"; clickTpBtn.BackgroundColor3 = Color3.fromRGB(255,255,255); clickTpBtn.BackgroundTransparency = 0; clickTpBtn.TextTransparency = 0; clickTpBtn.TextColor3 = Color3.fromRGB(255,255,255); clickTpBtn.TextStrokeTransparency = 0; clickTpBtn.TextStrokeColor3 = Color3.new(0,0,0); Instance.new("UICorner", clickTpBtn); applyBlackGreyGradient(clickTpBtn)
saveBtn.MouseButton1Click:Connect(function() states.savepos = not states.savepos; saveBtn.Text = "Save Pos : " .. (states.savepos and "ON" or "OFF"); if states.savepos and hrp then savedPos = hrp.CFrame; lastPos = savedPos end end)
clickTpBtn.MouseButton1Click:Connect(function() if savedPos and hrp then savedPos = savedPos; wait(0.1); hrp.CFrame = savedPos end end)

-- // MAIN GUI STRUCTURE //
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 450, 0, 300)
main.Position = UDim2.new(0.5, -225, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BackgroundTransparency = 0
main.Active = true; main.Draggable = true; Instance.new("UICorner", main)
applyBlackGreyGradient(main)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5

local miniBtn = Instance.new("TextButton", screenGui)
miniBtn.Size = UDim2.new(0, 120, 0, 32)
miniBtn.Position = UDim2.new(0.5, -60, 0.12, 0)
miniBtn.Text = "Meknoyu GUI"
miniBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
miniBtn.BackgroundTransparency = 0
miniBtn.TextTransparency = 0
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.TextStrokeTransparency = 0
miniBtn.TextStrokeColor3 = Color3.new(0,0,0)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 12
miniBtn.Draggable = true
miniBtn.Visible = false
applyBlackGreyGradient(miniBtn)

local miniCorner = Instance.new("UICorner", miniBtn)
miniCorner.CornerRadius = UDim.new(0, 6)

local miniStroke = Instance.new("UIStroke", miniBtn)
miniStroke.Thickness = 1.8

local isRainbow = true
local rainbowConnection
rainbowConnection = rs.RenderStepped:Connect(function() 
    if isRainbow then
        local hue = (tick() * 0.15) % 1
        stroke.Color = Color3.fromHSV(hue, 0.8, 1) 
        miniStroke.Color = Color3.fromHSV(hue, 0.8, 1)
    end
end)

local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, -110, 0, 25); header.Position = UDim2.new(0, 110, 0, 5)
header.Text = "MEKNOYU GUI | HUB"; header.BackgroundTransparency = 1; header.TextTransparency = 0; header.TextColor3 = Color3.new(1,1,1); header.Font = Enum.Font.GothamBold; header.TextSize = 18; header.TextXAlignment = Enum.TextXAlignment.Left

local keySystemLabel = Instance.new("TextLabel", main)
keySystemLabel.Size = UDim2.new(1, -110, 0, 15)
keySystemLabel.Position = UDim2.new(0, 110, 0, 26)
keySystemLabel.BackgroundTransparency = 1
keySystemLabel.TextTransparency = 0
keySystemLabel.Font = Enum.Font.GothamMedium
keySystemLabel.TextSize = 11
keySystemLabel.TextXAlignment = Enum.TextXAlignment.Left
if plr.Name == "Meknoyu" then
    keySystemLabel.Text = "KEY: OWNER"
    keySystemLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
else
    keySystemLabel.Text = "KEY: FREE"
    keySystemLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
end

local closeBtn = Instance.new("TextButton", main); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 7); closeBtn.Text = "X"; closeBtn.TextTransparency = 0; closeBtn.TextColor3 = Color3.new(1,0,0); closeBtn.TextStrokeTransparency = 0; closeBtn.TextStrokeColor3 = Color3.new(0,0,0); closeBtn.BackgroundColor3 = Color3.fromRGB(255,255,255); closeBtn.BackgroundTransparency = 0; Instance.new("UICorner", closeBtn); applyBlackGreyGradient(closeBtn)

-- ==========================================
--        SISTEM ANIMASI TWEEN (OPEN/CLOSE)
-- ==========================================
local originalMainSize = UDim2.new(0, 450, 0, 300)
local originalMainPos = UDim2.new(0.5, -225, 0.5, -150)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

closeBtn.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(main.Position.X.Scale, main.Position.Y.Offset + (main.Size.Y.Offset/2), main.Position.Y.Scale, main.Position.Y.Offset + (main.Size.Y.Offset/2))
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        main.Visible = false
        miniBtn.Visible = true
        main.Size = originalMainSize
        main.Position = originalMainPos
    end)
end)

miniBtn.MouseButton1Click:Connect(function()
    miniBtn.Visible = false
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = originalMainPos
    main.Visible = true
    
    local openTween = TweenService:Create(main, tweenInfo, {
        Size = originalMainSize,
        Position = originalMainPos
    })
    openTween:Play()
end)

local tabContainer = Instance.new("ScrollingFrame", main)
tabContainer.Size = UDim2.new(0, 100, 1, -85)
tabContainer.Position = UDim2.new(0, 5, 0, 5)
tabContainer.BackgroundTransparency = 1
tabContainer.ScrollBarThickness = 0
tabContainer.CanvasSize = UDim2.new(0, 0, 1.8, 0)
local UIList = Instance.new("UIListLayout", tabContainer); UIList.Padding = UDim.new(0, 5)

-- ==========================================
--        SISTEM PROFIL POJOK KIRI BAWAH
-- ==========================================
local profileFrame = Instance.new("Frame", main)
profileFrame.Size = UDim2.new(0, 100, 0, 70)
profileFrame.Position = UDim2.new(0, 5, 1, -75)
profileFrame.BackgroundTransparency = 1

local profilePic = Instance.new("ImageLabel", profileFrame)
profilePic.Size = UDim2.new(0, 32, 0, 32)
profilePic.Position = UDim2.new(0, 2, 0, 5)
profilePic.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
profilePic.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=150&height=150&format=png"
Instance.new("UICorner", profilePic).CornerRadius = UDim.new(1, 0)

local profileStroke = Instance.new("UIStroke", profilePic)
profileStroke.Thickness = 1.5

rs.RenderStepped:Connect(function()
    profileStroke.Color = Color3.fromHSV((tick() * 0.3) % 1, 0.8, 1)
end)

local displayNameLabel = Instance.new("TextLabel", profileFrame)
displayNameLabel.Size = UDim2.new(0, 60, 0, 12)
displayNameLabel.Position = UDim2.new(0, 38, 0, 8)
displayNameLabel.BackgroundTransparency = 1
displayNameLabel.TextTransparency = 0
displayNameLabel.Text = "Name: " .. plr.DisplayName
displayNameLabel.TextColor3 = Color3.fromRGB(160, 32, 240)
displayNameLabel.Font = Enum.Font.GothamBold
displayNameLabel.TextSize = 8
displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local useridLabel = Instance.new("TextLabel", profileFrame)
useridLabel.Size = UDim2.new(0, 60, 0, 12)
useridLabel.Position = UDim2.new(0, 38, 0, 20)
useridLabel.BackgroundTransparency = 1
useridLabel.TextTransparency = 0
useridLabel.Text = "UserID: " .. plr.UserId
useridLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
useridLabel.Font = Enum.Font.GothamMedium
useridLabel.TextSize = 7
useridLabel.TextXAlignment = Enum.TextXAlignment.Left

local pages = Instance.new("Frame", main); pages.Size = UDim2.new(1, -115, 1, -50); pages.Position = UDim2.new(0, 110, 0, 45); pages.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("ScrollingFrame", pages); p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.ScrollBarThickness = 2; p.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    local grid = Instance.new("UIGridLayout", p); grid.CellSize = UDim2.new(0.48, 0, 0, 35); grid.CellPadding = UDim2.new(0, 5, 0, 5)
    return p
end

local pageMain = createPage("Main")
local pageNoToggle = createPage("NoToggle")
local pageSelectAnti = createPage("SelectAnti")
local pageInfo = Instance.new("ScrollingFrame", pages); pageInfo.Name = "Info"; pageInfo.Size = UDim2.new(1, 0, 1, 0); pageInfo.Visible = false; pageInfo.BackgroundTransparency = 1; pageInfo.ScrollBarThickness = 2; pageInfo.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local pageGames = createPage("Games")
local pageServer = createPage("Server")

local pageCustomize = Instance.new("ScrollingFrame", pages)
pageCustomize.Name = "Customize"
pageCustomize.Size = UDim2.new(1, 0, 1, 0)
pageCustomize.Visible = false
pageCustomize.BackgroundTransparency = 1
pageCustomize.ScrollBarThickness = 2
pageCustomize.CanvasSize = UDim2.new(0, 0, 3.5, 0)
local custLayout = Instance.new("UIListLayout", pageCustomize)
custLayout.Padding = UDim.new(0, 8)
custLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi Tambah Tab
local function addTab(name, targetPage)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.BackgroundTransparency = 0
    btn.TextTransparency = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextStrokeTransparency = 0.5
    btn.TextStrokeColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 2
    Instance.new("UICorner", btn)
    applyBlackGreyGradient(btn)
    
    local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tInfo, {TextTransparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tInfo, {TextTransparency = 0}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() 
        btn.Size = UDim2.new(0.9, 0, 0, 24)
        local clickTween = TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 26)})
        clickTween:Play()
        
        for _, v in pairs(pages:GetChildren()) do v.Visible = false end; 
        targetPage.Visible = true 
    end)
end

addTab("Main", pageMain)
addTab("Visuals", pageNoToggle)
addTab("Select Anti", pageSelectAnti)
addTab("Customize", pageCustomize)
addTab("Info", pageInfo)
addTab("Games", pageGames)
addTab("Server", pageServer)

local selectedPlayerName = ""
local selectedFriendName = ""

-- ==========================================
--        ISI KONTEN TAB CUSTOMIZE
-- ==========================================

-- --- DROPDOWN 1: CUSTOM UI ---
local dropUIFrame = Instance.new("Frame", pageCustomize)
dropUIFrame.Size = UDim2.new(0.95, 0, 0, 35)
dropUIFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
dropUIFrame.BackgroundTransparency = 0
Instance.new("UICorner", dropUIFrame).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(dropUIFrame)
local dropUIStroke = Instance.new("UIStroke", dropUIFrame)
dropUIStroke.Thickness = 2

rs.RenderStepped:Connect(function()
    dropUIStroke.Color = Color3.fromHSV((tick() * 0.1) % 1, 0.8, 1)
end)

local dropUIText = Instance.new("TextButton", dropUIFrame)
dropUIText.Size = UDim2.new(1, 0, 1, 0)
dropUIText.BackgroundTransparency = 1
dropUIText.TextTransparency = 0
dropUIText.Text = "  Custom UI"
dropUIText.TextColor3 = Color3.fromRGB(255, 255, 255)
dropUIText.TextStrokeTransparency = 0.5
dropUIText.TextStrokeColor3 = Color3.new(0, 0, 0)
dropUIText.Font = Enum.Font.GothamBold
dropUIText.TextSize = 12
dropUIText.TextXAlignment = Enum.TextXAlignment.Left

local dropUIArrow = Instance.new("TextLabel", dropUIFrame)
dropUIArrow.Size = UDim2.new(0, 30, 1, 0)
dropUIArrow.Position = UDim2.new(1, -30, 0, 0)
dropUIArrow.BackgroundTransparency = 1
dropUIArrow.TextTransparency = 0
dropUIArrow.Text = "V"
dropUIArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
dropUIArrow.TextStrokeTransparency = 0.5
dropUIArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
dropUIArrow.Font = Enum.Font.GothamBold
dropUIArrow.TextSize = 11

local contentUIFrame = Instance.new("Frame", pageCustomize)
contentUIFrame.Size = UDim2.new(0.95, 0, 0, 75)
contentUIFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
contentUIFrame.BackgroundTransparency = 0
contentUIFrame.Visible = false
Instance.new("UICorner", contentUIFrame).CornerRadius = UDim.new(0, 5)

local sliderTitle = Instance.new("TextLabel", contentUIFrame)
sliderTitle.Size = UDim2.new(1, 0, 0, 20)
sliderTitle.Position = UDim2.new(0, 10, 0, 5)
sliderTitle.BackgroundTransparency = 1
sliderTitle.TextTransparency = 0
sliderTitle.Text = "Transparency UI"
sliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderTitle.TextStrokeTransparency = 0.5
sliderTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
sliderTitle.Font = Enum.Font.GothamSemibold
sliderTitle.TextSize = 11
sliderTitle.TextXAlignment = Enum.TextXAlignment.Left

local sliderTrack = Instance.new("Frame", contentUIFrame)
sliderTrack.Size = UDim2.new(0.85, 0, 0, 5)
sliderTrack.Position = UDim2.new(0.075, 0, 0, 32)
sliderTrack.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
sliderTrack.BorderSizePixel = 0

local sliderThumb = Instance.new("TextButton", sliderTrack)
sliderThumb.Size = UDim2.new(0, 12, 0, 12)
sliderThumb.Position = UDim2.new(0, -6, 0.5, -6)
sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderThumb.Text = ""
sliderThumb.TextTransparency = 0
sliderThumb.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", sliderThumb).CornerRadius = UDim.new(1, 0)

local sliderValueLabel = Instance.new("TextLabel", contentUIFrame)
sliderValueLabel.Size = UDim2.new(1, 0, 0, 20)
sliderValueLabel.Position = UDim2.new(0, 0, 0, 43)
sliderValueLabel.BackgroundTransparency = 1
sliderValueLabel.TextTransparency = 0
sliderValueLabel.Text = "Transparency: 0"
sliderValueLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
sliderValueLabel.TextStrokeTransparency = 0.5
sliderValueLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
sliderValueLabel.Font = Enum.Font.GothamMedium
sliderValueLabel.TextSize = 11

local uiOpen = false
dropUIText.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    contentUIFrame.Visible = uiOpen
    dropUIArrow.Text = uiOpen and "^" or "V"
end)

local sliding = false
local function updateSlider()
    if not sliding then return end
    local mX = UIS:GetMouseLocation().X
    local tX = sliderTrack.AbsolutePosition.X
    local tW = sliderTrack.AbsoluteSize.X
    local pct = math.clamp((mX - tX) / tW, 0, 1)
    
    sliderThumb.Position = UDim2.new(pct, -6, 0.5, -6)
    local rawVal = math.round(pct * 10) / 10
    sliderValueLabel.Text = "Transparency: " .. rawVal
    
    main.BackgroundTransparency = rawVal
end
sliderThumb.MouseButton1Down:Connect(function() sliding = true end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)
rs.RenderStepped:Connect(updateSlider)

-- --- DROPDOWN 2: COLORS UI ---
local dropColFrame = Instance.new("Frame", pageCustomize)
dropColFrame.Size = UDim2.new(0.95, 0, 0, 35)
dropColFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
dropColFrame.BackgroundTransparency = 0
Instance.new("UICorner", dropColFrame).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(dropColFrame)
local dropColStroke = Instance.new("UIStroke", dropColFrame)
dropColStroke.Thickness = 2

rs.RenderStepped:Connect(function()
    dropColStroke.Color = Color3.fromHSV((tick() * 0.1) % 1, 0.8, 1)
end)

local dropColText = Instance.new("TextButton", dropColFrame)
dropColText.Size = UDim2.new(1, 0, 1, 0)
dropColText.BackgroundTransparency = 1
dropColText.TextTransparency = 0
dropColText.Text = "  Colors UI"
dropColText.TextColor3 = Color3.fromRGB(255, 255, 255)
dropColText.TextStrokeTransparency = 0.5
dropColText.TextStrokeColor3 = Color3.new(0, 0, 0)
dropColText.Font = Enum.Font.GothamBold
dropColText.TextSize = 12
dropColText.TextXAlignment = Enum.TextXAlignment.Left

local dropColArrow = Instance.new("TextLabel", dropColFrame)
dropColArrow.Size = UDim2.new(0, 30, 1, 0)
dropColArrow.Position = UDim2.new(1, -30, 0, 0)
dropColArrow.BackgroundTransparency = 1
dropColArrow.TextTransparency = 0
dropColArrow.Text = "V"
dropColArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
dropColArrow.TextStrokeTransparency = 0.5
dropColArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
dropColArrow.Font = Enum.Font.GothamBold
dropColArrow.TextSize = 11

local contentColFrame = Instance.new("Frame", pageCustomize)
contentColFrame.Size = UDim2.new(0.95, 0, 0, 75)
contentColFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
contentColFrame.BackgroundTransparency = 0
contentColFrame.Visible = false
Instance.new("UICorner", contentColFrame).CornerRadius = UDim.new(0, 5)

local contentColStroke = Instance.new("UIStroke", contentColFrame)
contentColStroke.Thickness = 1.5
rs.RenderStepped:Connect(function()
    contentColStroke.Color = Color3.fromHSV((tick() * 0.1) % 1, 0.8, 1)
end)

local colGrid = Instance.new("UIGridLayout", contentColFrame)
colGrid.CellSize = UDim2.new(0, 22, 0, 22)
colGrid.CellPadding = UDim2.new(0, 8, 0, 6)
colGrid.SortOrder = Enum.SortOrder.LayoutOrder

local padingGrid = Instance.new("UIPadding", contentColFrame)
padingGrid.PaddingTop = UDim.new(0, 6)
padingGrid.PaddingLeft = UDim.new(0, 10)

local colorPalette = {
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 128, 0), Color3.fromRGB(128, 0, 255),
    Color3.fromRGB(255, 0, 128), Color3.fromRGB(0, 255, 128), Color3.fromRGB(15, 15, 15)
}

for i, color in ipairs(colorPalette) do
    local colorBox = Instance.new("TextButton", contentColFrame)
    colorBox.Text = ""
    colorBox.TextTransparency = 0
    colorBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBox.BackgroundColor3 = color
    colorBox.BorderSizePixel = 0
    Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 4)
    
    colorBox.MouseButton1Click:Connect(function()
        main.BackgroundColor3 = color
    end)
end

local colOpen = false
dropColText.MouseButton1Click:Connect(function()
    colOpen = not colOpen
    contentColFrame.Visible = colOpen
    dropColArrow.Text = colOpen and "^" or "V"
end)

-- --- DROPDOWN 3: TELEPORT TO PLAYERS ---
local dropPlayerFrame = Instance.new("Frame", pageCustomize)
dropPlayerFrame.Size = UDim2.new(0.95, 0, 0, 35)
dropPlayerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
dropPlayerFrame.BackgroundTransparency = 0
Instance.new("UICorner", dropPlayerFrame).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(dropPlayerFrame)
local dropPlayerStroke = Instance.new("UIStroke", dropPlayerFrame)
dropPlayerStroke.Thickness = 2
rs.RenderStepped:Connect(function()
    dropPlayerStroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.8, 1)
end)

local dropPlayerText = Instance.new("TextButton", dropPlayerFrame)
dropPlayerText.Size = UDim2.new(1, 0, 1, 0)
dropPlayerText.BackgroundTransparency = 1
dropPlayerText.TextTransparency = 0
dropPlayerText.Text = "  Teleport To Players"
dropPlayerText.TextColor3 = Color3.fromRGB(255, 255, 255)
dropPlayerText.TextStrokeTransparency = 0.5
dropPlayerText.TextStrokeColor3 = Color3.new(0, 0, 0)
dropPlayerText.Font = Enum.Font.GothamBold
dropPlayerText.TextSize = 12
dropPlayerText.TextXAlignment = Enum.TextXAlignment.Left

local dropPlayerArrow = Instance.new("TextLabel", dropPlayerFrame)
dropPlayerArrow.Size = UDim2.new(0, 30, 1, 0)
dropPlayerArrow.Position = UDim2.new(1, -30, 0, 0)
dropPlayerArrow.BackgroundTransparency = 1
dropPlayerArrow.TextTransparency = 0
dropPlayerArrow.Text = "V"
dropPlayerArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
dropPlayerArrow.TextStrokeTransparency = 0.5
dropPlayerArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
dropPlayerArrow.Font = Enum.Font.GothamBold
dropPlayerArrow.TextSize = 11

local listPlayerScroll = Instance.new("ScrollingFrame", pageCustomize)
listPlayerScroll.Size = UDim2.new(0.95, 0, 0, 100)
listPlayerScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
listPlayerScroll.BackgroundTransparency = 0
listPlayerScroll.Visible = false
listPlayerScroll.ScrollBarThickness = 3
listPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", listPlayerScroll).CornerRadius = UDim.new(0, 5)
local listPlayerLayout = Instance.new("UIListLayout", listPlayerScroll)
listPlayerLayout.Padding = UDim.new(0, 2)

local tpPlayerBtn = Instance.new("TextButton", pageCustomize)
tpPlayerBtn.Size = UDim2.new(0.95, 0, 0, 30)
tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tpPlayerBtn.BackgroundTransparency = 0
tpPlayerBtn.TextTransparency = 0
tpPlayerBtn.Text = "Teleport"
tpPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpPlayerBtn.TextStrokeTransparency = 0.5
tpPlayerBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
tpPlayerBtn.Font = Enum.Font.GothamBold
tpPlayerBtn.TextSize = 12
Instance.new("UICorner", tpPlayerBtn).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(tpPlayerBtn)

local function updatePlayerDropdown()
    for _, child in pairs(listPlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr then
            count = count + 1
            local pBtn = Instance.new("TextButton", listPlayerScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 25)
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            pBtn.BackgroundTransparency = 0
            pBtn.TextTransparency = 0
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextStrokeTransparency = 0.5
            pBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
            pBtn.Font = Enum.Font.GothamSemibold
            pBtn.TextSize = 11
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            pBtn.MouseButton1Click:Connect(function()
                selectedPlayerName = p.Name
                dropPlayerText.Text = "  Teleport To Players: " .. p.Name
                listPlayerScroll.Visible = false
                dropPlayerArrow.Text = "V"
            end)
        end
    end
    listPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, count * 27)
end

dropPlayerText.MouseButton1Click:Connect(function()
    local isVisible = not listPlayerScroll.Visible
    listPlayerScroll.Visible = isVisible
    dropPlayerArrow.Text = isVisible and "^" or "V"
    if isVisible then updatePlayerDropdown() end
end)

tpPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayerName ~= "" then
        local target = players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

-- --- DROPDOWN 4: TELEPORT TO FRIENDS ---
local dropFriendFrame = Instance.new("Frame", pageCustomize)
dropFriendFrame.Size = UDim2.new(0.95, 0, 0, 35)
dropFriendFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
dropFriendFrame.BackgroundTransparency = 0
Instance.new("UICorner", dropFriendFrame).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(dropFriendFrame)
local dropFriendStroke = Instance.new("UIStroke", dropFriendFrame)
dropFriendStroke.Thickness = 2
rs.RenderStepped:Connect(function()
    dropFriendStroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.8, 1)
end)

local dropFriendText = Instance.new("TextButton", dropFriendFrame)
dropFriendText.Size = UDim2.new(1, 0, 1, 0)
dropFriendText.BackgroundTransparency = 1
dropFriendText.TextTransparency = 0
dropFriendText.Text = "  Teleport to Friends"
dropFriendText.TextColor3 = Color3.fromRGB(255, 255, 255)
dropFriendText.TextStrokeTransparency = 0.5
dropFriendText.TextStrokeColor3 = Color3.new(0, 0, 0)
dropFriendText.Font = Enum.Font.GothamBold
dropFriendText.TextSize = 12
dropFriendText.TextXAlignment = Enum.TextXAlignment.Left

local dropFriendArrow = Instance.new("TextLabel", dropFriendFrame)
dropFriendArrow.Size = UDim2.new(0, 30, 1, 0)
dropFriendArrow.Position = UDim2.new(1, -30, 0, 0)
dropFriendArrow.BackgroundTransparency = 1
dropFriendArrow.TextTransparency = 0
dropFriendArrow.Text = "V"
dropFriendArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
dropFriendArrow.TextStrokeTransparency = 0.5
dropFriendArrow.TextStrokeColor3 = Color3.new(0, 0, 0)
dropFriendArrow.Font = Enum.Font.GothamBold
dropFriendArrow.TextSize = 11

local listFriendScroll = Instance.new("ScrollingFrame", pageCustomize)
listFriendScroll.Size = UDim2.new(0.95, 0, 0, 100)
listFriendScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
listFriendScroll.BackgroundTransparency = 0
listFriendScroll.Visible = false
listFriendScroll.ScrollBarThickness = 3
listFriendScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", listFriendScroll).CornerRadius = UDim.new(0, 5)
local listFriendLayout = Instance.new("UIListLayout", listFriendScroll)
listFriendLayout.Padding = UDim.new(0, 2)

local tpFriendBtn = Instance.new("TextButton", pageCustomize)
tpFriendBtn.Size = UDim2.new(0.95, 0, 0, 30)
tpFriendBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tpFriendBtn.BackgroundTransparency = 0
tpFriendBtn.TextTransparency = 0
tpFriendBtn.Text = "Teleport"
tpFriendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpFriendBtn.TextStrokeTransparency = 0.5
tpFriendBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
tpFriendBtn.Font = Enum.Font.GothamBold
tpFriendBtn.TextSize = 12
Instance.new("UICorner", tpFriendBtn).CornerRadius = UDim.new(0, 5)
applyBlackGreyGradient(tpFriendBtn)

local function updateFriendDropdown()
    for _, child in pairs(listFriendScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr then
            local isFriend = false
            pcall(function()
                isFriend = plr:IsFriendsWith(p.UserId)
            end)
            if isFriend then
                count = count + 1
                local fBtn = Instance.new("TextButton", listFriendScroll)
                fBtn.Size = UDim2.new(1, 0, 0, 25)
                fBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                fBtn.BackgroundTransparency = 0
                fBtn.TextTransparency = 0
                fBtn.Text = p.Name
                fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                fBtn.TextStrokeTransparency = 0.5
                fBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
                fBtn.Font = Enum.Font.GothamSemibold
                fBtn.TextSize = 11
                Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 4)
                fBtn.MouseButton1Click:Connect(function()
                    selectedFriendName = p.Name
                    dropFriendText.Text = "  Teleport to Friends: " .. p.Name
                    listFriendScroll.Visible = false
                    dropFriendArrow.Text = "V"
                end)
            end
        end
    end
    listFriendScroll.CanvasSize = UDim2.new(0, 0, 0, count * 27)
end

dropFriendText.MouseButton1Click:Connect(function()
    local isVisible = not listFriendScroll.Visible
    listFriendScroll.Visible = isVisible
    dropFriendArrow.Text = isVisible and "^" or "V"
    if isVisible then updateFriendDropdown() end
end)

tpFriendBtn.MouseButton1Click:Connect(function()
    if selectedFriendName ~= "" then
        local target = players:FindFirstChild(selectedFriendName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

-- // TAB INFO CONTENT //
local infoText = Instance.new("TextLabel", pageInfo)
infoText.Size = UDim2.new(0.95, 0, 0, 350); infoText.Position = UDim2.new(0.025, 0, 0, 5)
infoText.BackgroundTransparency = 1; infoText.TextTransparency = 0; infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
infoText.TextSize = 12; infoText.Font = Enum.Font.GothamMedium; infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left; infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Text = "This script is strictly guarded and secure. There is no account theft or fraud. This script is securely protected, and no malicious bots will steal your data.\n\nCreated by Progaming Meknoyu Script.\n\nAll Engine Core modules, anti-detection filters, and local virtualization protocols are managed natively. Optimization systems are running automatically in the background to ensure stable FPS."

-- // TAB GAMES CONTENT //
local function createGameBtn(name, parent, func)
    local b = Instance.new("TextButton", parent)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    b.BackgroundTransparency = 0
    b.TextTransparency = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextStrokeTransparency = 0.5
    b.TextStrokeColor3 = Color3.new(0,0,0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b)
    applyBlackGreyGradient(b)
    b.MouseButton1Click:Connect(func)
    return b
end

createGameBtn("Murder Mystery 2 Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/mm2.lua"))()
end)

createGameBtn("Survive the Killer Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/SurvivetheKiller.lua"))()
end)

createGameBtn("Slime RNG Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Slimerng.lua"))()
end)

createGameBtn("Quiet or Die Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/QuietorDie.lua"))()
end)

createGameBtn("Chicken Farm Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Chickenfarm.lua"))()
end)

createGameBtn("Mine Per Click Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Mineperclick.lua"))()
end)

createGameBtn("Pass or Explode Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/PassorExplode.lua"))()
end)

createGameBtn("Prison Life Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Prisonlife.lua"))()
end)

createGameBtn("Troll Pinning Tower 2 Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Trollpinningtower2.lua"))()
end)

createGameBtn("Sell Lemons Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Sell_lemons.lua"))()
end)

createGameBtn("Paint and Seek Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/Paintandseek.lua"))()
end)

createGameBtn("Grow a Garden 2 Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/gag2.lua"))()
end)

createGameBtn("Pistol Arena Script", pageGames, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MeknoyuReals/Meknoyu/refs/heads/main/PistolArena.lua"))()
end)

-- // TAB SERVER CONTENT //
createGameBtn("Rejoin", pageServer, function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
end)

createGameBtn("Small Server", pageServer, function()
    local ts = game:GetService("TeleportService")
    local http = game:GetService("HttpService")
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local req = pcall(function()
        local raw = game:HttpGet(api)
        local json = http:JSONDecode(raw)
        if json and json.data then
            for _, s in pairs(json.data) do
                if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
                    break
                end
            end
        end
    end)
end)

createGameBtn("Server Hop", pageServer, function()
    local ts = game:GetService("TeleportService")
    local http = game:GetService("HttpService")
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local req = pcall(function()
        local raw = game:HttpGet(api)
        local json = http:JSONDecode(raw)
        if json and json.data then
            local valid = {}
            for _, s in pairs(json.data) do
                if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(valid, s.id)
                end
            end
            if #valid > 0 then
                ts:TeleportToPlaceInstance(game.PlaceId, valid[math.random(1, #valid)], plr)
            end
        end
    end)
end)

createGameBtn("Server New", pageServer, function()
    local ts = game:GetService("TeleportService")
    local http = game:GetService("HttpService")
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local req = pcall(function()
        local raw = game:HttpGet(api)
        local json = http:JSONDecode(raw)
        if json and json.data then
            for _, s in pairs(json.data) do
                if s.playing and s.playing == 1 and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
                    return
                end
            end
            for _, s in pairs(json.data) do
                if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
                    break
                end
            end
        end
    end)
end)

-- // TOGGLE BUTTON CREATOR //
local function createToggleBtn(name, key, parent)
    local b = Instance.new("TextButton", parent)
    b.Text = name .. " : OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    b.BackgroundTransparency = 0
    b.TextTransparency = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextStrokeTransparency = 0.5
    b.TextStrokeColor3 = Color3.new(0, 0, 0)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    Instance.new("UICorner", b)
    applyBlackGreyGradient(b)

    b.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        b.Text = name .. " : " .. (states[key] and "ON" or "OFF")
        if key == "bypassac" then applyAntiDetect(states.bypassac)
        elseif key == "noclip" and not states.noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
        elseif key == "esp" and not states.esp then for _, p in pairs(players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MeknoHighlight") then p.Character.MeknoHighlight:Destroy() end end
        elseif key == "tracer" and not states.tracer then for _, p in pairs(players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MeknoTracer") then p.Character.MeknoTracer:Destroy() end end
        elseif key == "disco" then if states.disco then discoSky.Parent = lighting; skyText.Visible = true else discoSky.Parent = nil; skyText.Visible = false; lighting.Ambient = oldAmbient; lighting.OutdoorAmbient = oldOutdoor; lighting.FogColor = oldFog end
        elseif key == "hcxxr" and not states.hcxxr then lighting.Ambient = oldAmbient; lighting.OutdoorAmbient = oldOutdoor; for _, p in pairs(players:GetPlayers()) do if p.Character then for _, v in pairs(p.Character:GetDescendants()) do if v:IsA("Fire") and v.Name == "MeknoFire" then v:Destroy() end end end end
        elseif key == "addpart" and not states.addpart then if platformPart then platformPart:Destroy(); platformPart = nil end
        elseif key == "antivoid" and not states.antivoid then if voidPart then voidPart:Destroy(); voidPart = nil end
        elseif key == "antilag" then
            if states.antilag then
                settings().Rendering.QualityLevel = 1
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Material = Enum.Material.SmoothPlastic
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
            else
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                lighting.GlobalShadows = true
            end
        elseif key == "antirobux" and not states.antirobux then pcall(function() guiService.MenuOpened:Disconnect() end)
        elseif key == "xray" and not states.xray then for obj, trans in pairs(originalTransparencies) do if obj and obj.Parent then obj.Transparency = trans end end; originalTransparencies = {}
        elseif key == "antitel" and states.antitel then if hrp then lastPos = hrp.CFrame end
        elseif key == "antifling" and not states.antifling then
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            for _, p in pairs(players:GetPlayers()) do
                if p ~= plr and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
    end)
    return b
end

-- // TAB MAIN //
createToggleBtn("Noclip", "noclip", pageMain)
createToggleBtn("ESP", "esp", pageMain)
createToggleBtn("Tracer", "tracer", pageMain)
createToggleBtn("Fling", "fling", pageMain)
createToggleBtn("Inf Jump", "infJump", pageMain)
createToggleBtn("Speed", "speed", pageMain)
createToggleBtn("Xray", "xray", pageMain)
createToggleBtn("TP Kill Enemy", "tpKill", pageMain)
createToggleBtn("Aimbot", "aimActive", pageMain)
createToggleBtn("Disco Mode", "disco", pageMain)
createToggleBtn("HCXXR Mode", "hcxxr", pageMain)
createToggleBtn("Add Part", "addpart", pageMain)

-- // TAB SELECT ANTI //
createToggleBtn("Anti Detect", "bypassac", pageSelectAnti)
createToggleBtn("Anti Fling", "antifling", pageSelectAnti)
createToggleBtn("Anti Teleport", "antitel", pageSelectAnti)
createToggleBtn("Anti Ragdoll", "antirag", pageSelectAnti)
createToggleBtn("Anti Afk", "antiafk", pageSelectAnti)
createToggleBtn("Anti Robux", "antirobux", pageSelectAnti)
createToggleBtn("Anti Void", "antivoid", pageSelectAnti)
createToggleBtn("Anti Lag", "antilag", pageSelectAnti)

-- // TAB VISUALS //
local function createPlainBtn(name, parent, func)
    local b = Instance.new("TextButton", parent)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    b.BackgroundTransparency = 0
    b.TextTransparency = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextStrokeTransparency = 0.5
    b.TextStrokeColor3 = Color3.new(0, 0, 0)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    Instance.new("UICorner", b)
    applyBlackGreyGradient(b)
    
    b.MouseButton1Click:Connect(func)
    return b
end

local godSubFrame = Instance.new("Frame", screenGui); godSubFrame.Size = UDim2.new(0, 150, 0, 100); godSubFrame.Position = UDim2.new(0.5, -75, 0.5, -50); godSubFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255); godSubFrame.BackgroundTransparency = 0; godSubFrame.Visible = false; godSubFrame.Active = true; godSubFrame.Draggable = true; Instance.new("UICorner", godSubFrame); applyBlackGreyGradient(godSubFrame)
local godToggleBtn = Instance.new("TextButton", godSubFrame); godToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0); godToggleBtn.Position = UDim2.new(0.1, 0, 0.45, 0); godToggleBtn.Text = "God Mode : OFF"; godToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); godToggleBtn.BackgroundTransparency = 0; godToggleBtn.TextTransparency = 0; godToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); godToggleBtn.TextStrokeTransparency = 0; godToggleBtn.TextStrokeColor3 = Color3.new(0, 0, 0); Instance.new("UICorner", godToggleBtn); applyBlackGreyGradient(godToggleBtn)
local function GodModeSeatNoInvis(state) local c = game.Players.LocalPlayer.Character; if not c then return end for _, o in pairs(workspace:GetChildren()) do if o.Name == 'invischair' then pcall(function() o:Destroy() end) end end if state then local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end task.wait(0.05); local scf = r.CFrame; local under = r.Position + Vector3.new(0, -100, 0); c:MoveTo(under); task.wait(0.1); local s = Instance.new("Seat", workspace); s.Anchored = true; s.CanCollide = false; s.Transparency = 1; s.Position = under; s.Name = "invischair"; local w = Instance.new("Weld", s); w.Part0 = s; w.Part1 = r; task.wait(); s.CFrame = scf; s.Anchored = false end end
godToggleBtn.MouseButton1Click:Connect(function() states.god = not states.god; godToggleBtn.Text = "God Mode : " .. (states.god and "ON" or "OFF"); if states.god then GodModeSeatNoInvis(true); godConnection = rs.Heartbeat:Connect(function() if char and hum and hrp then hum.MaxHealth = math.huge; hum.Health = math.huge; hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end end) else if godConnection then godConnection:Disconnect() end; GodModeSeatNoInvis(false); if hum then hum.MaxHealth = 100; hum.Health = 100; hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end end end)

local invisSubFrame = Instance.new("Frame", screenGui); invisSubFrame.Size = UDim2.new(0, 150, 0, 100); invisSubFrame.Position = UDim2.new(0.5, -75, 0.5, -50); invisSubFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255); invisSubFrame.BackgroundTransparency = 0; invisSubFrame.Visible = false; invisSubFrame.Active = true; invisSubFrame.Draggable = true; Instance.new("UICorner", invisSubFrame); applyBlackGreyGradient(invisSubFrame)
local invisToggleBtn = Instance.new("TextButton", invisSubFrame); invisToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0); invisToggleBtn.Position = UDim2.new(0.1, 0, 0.45, 0); invisToggleBtn.Text = "Invisible : OFF"; invisToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); invisToggleBtn.BackgroundTransparency = 0; invisToggleBtn.TextTransparency = 0; invisToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); invisToggleBtn.TextStrokeTransparency = 0; invisToggleBtn.TextStrokeColor3 = Color3.new(0, 0, 0); Instance.new("UICorner", invisToggleBtn); applyBlackGreyGradient(invisToggleBtn)

local function setInvisState(state)
    local c = plr.Character; if not c then return end
    for _, o in pairs(workspace:GetChildren()) do
        if o.Name == 'invischair' then pcall(function() o:Destroy() end) end
    end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.Transparency = 0
        end
    end
    if state then
        local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
        task.wait(0.05);
        local scf = r.CFrame;
        local under = r.Position + Vector3.new(0, invisOffset, 0);
        c:MoveTo(under);
        task.wait(0.1)
        local s = Instance.new("Seat", workspace);
        s.Anchored = true;
        s.CanCollide = false;
        s.Transparency = 1
        s.Position = under;
        s.Name = "invischair";
        local w = Instance.new("Weld", s);
        w.Part0 = s;
        w.Part1 = r
        task.wait();
        s.CFrame = scf;
        s.Anchored = false
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = 0.5
            end
        end
    end
end

invisToggleBtn.MouseButton1Click:Connect(function() states.invis = not states.invis; invisToggleBtn.Text = "Invisible : " .. (states.invis and "ON" or "OFF"); setInvisState(states.invis) end)

local execMainFrame = Instance.new("Frame", screenGui); execMainFrame.Size = UDim2.new(0, 300, 0, 220); execMainFrame.Position = UDim2.new(0.5, -150, 0.5, -110); execMainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255); execMainFrame.BackgroundTransparency = 0; execMainFrame.Visible = false; execMainFrame.Active = true; execMainFrame.Draggable = true; Instance.new("UICorner", execMainFrame); applyBlackGreyGradient(execMainFrame)
local execTextBox = Instance.new("TextBox", execMainFrame); execTextBox.Size = UDim2.new(1, -20, 0, 130); execTextBox.Position = UDim2.new(0, 10, 0, 40); execTextBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); execTextBox.TextColor3 = Color3.fromRGB(255, 255, 255); execTextBox.ClearTextOnFocus = false; execTextBox.MultiLine = true; execTextBox.Font = Enum.Font.Code; execTextBox.TextSize = 10; Instance.new("UICorner", execTextBox)
local executeSubBtn = Instance.new("TextButton", execMainFrame); executeSubBtn.Size = UDim2.new(0, 85, 0, 35); executeSubBtn.Position = UDim2.new(0, 10, 0, 175); executeSubBtn.Text = "Execute"; executeSubBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); executeSubBtn.BackgroundTransparency = 0; executeSubBtn.TextTransparency = 0; executeSubBtn.TextColor3 = Color3.fromRGB(255, 255, 255); executeSubBtn.TextStrokeTransparency = 0; executeSubBtn.TextStrokeColor3 = Color3.new(0, 0, 0); Instance.new("UICorner", executeSubBtn); applyBlackGreyGradient(executeSubBtn)
executeSubBtn.MouseButton1Click:Connect(function() if execTextBox.Text ~= "" then pcall(function() local func = loadstring(execTextBox.Text); if func then func() end end) end end)

local function miniFling(playerToFling)
    local localplayer = game:GetService("Players").LocalPlayer
    local character = localplayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = humanoid and humanoid.RootPart

    local targetCharacter = playerToFling.Character
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    local targetRootPart = targetHumanoid and targetHumanoid.RootPart
    local targetHead = targetCharacter and targetCharacter:FindFirstChild("Head")

    if character and humanoid and rootPart and targetCharacter and targetHumanoid and targetRootPart then
        if rootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = rootPart.CFrame
        end

        workspace.CurrentCamera.CameraSubject = targetHead or targetRootPart or targetHumanoid
        workspace.FallenPartsDestroyHeight = 0/0

        local BV = Instance.new("BodyVelocity")
        BV.Name = "VelocityFling"
        BV.Parent = rootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        local Time = tick()
        repeat
            if rootPart and targetRootPart then
                rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 0)
                rootPart.Velocity = targetRootPart.Velocity * 10000 + Vector3.new(0, 10000, 0)
                rootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
            task.wait()
        until not targetRootPart or targetRootPart.Parent ~= targetCharacter or targetRootPart.Velocity.Magnitude > 150 or targetHumanoid.Health <= 0 or targetHumanoid.Sit or tick() > Time + 2

        BV:Destroy()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = humanoid

        repeat
            rootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            if character.PrimaryPart then character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0)) end
            humanoid:ChangeState("GettingUp")
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (rootPart.Position - getgenv().OldPos.p).Magnitude < 25
    end
end

createPlainBtn("God Mode Menu", pageNoToggle, function() godSubFrame.Visible = not godSubFrame.Visible end)
createPlainBtn("Invisible Menu", pageNoToggle, function() invisSubFrame.Visible = not invisSubFrame.Visible end)
createPlainBtn("Execute Project", pageNoToggle, function() execMainFrame.Visible = not execMainFrame.Visible end)
createPlainBtn("Teleport Back UI", pageNoToggle, function() tpBackGui.Visible = not tpBackGui.Visible end)
createPlainBtn("Tool TP Logic", pageNoToggle, function() states.tooltp = not states.tooltp; if states.tooltp then giveTpTool() else local t = plr.Backpack:FindFirstChild("Mekno TP Tool") or (char and char:FindFirstChild("Mekno TP Tool")); if t then t:Destroy() end end end)
createPlainBtn("KILL ALL", pageNoToggle, function() for i = 1, 10 do for _, p in pairs(players:GetPlayers()) do if p ~= plr and p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.Health = 0; p.Character.Humanoid:TakeDamage(999999) end end; task.wait(0.02) end end)
createPlainBtn("Fling All", pageNoToggle, function() task.spawn(function() for _, p in pairs(players:GetPlayers()) do if p ~= plr and p.Character then miniFling(p) end end end) end)
createPlainBtn("Dark Dex", pageNoToggle, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
createPlainBtn("Message Horror", pageNoToggle, function() task.spawn(function() local oldFrame = Instance.new("Frame", screenGui); oldFrame.Size = UDim2.new(1, 0, 0.25, 0); oldFrame.Position = UDim2.new(0, 0, 0.35, 0); oldFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); oldFrame.BackgroundTransparency = 0.4; local oldLabel = Instance.new("TextLabel", oldFrame); oldLabel.Size = UDim2.new(1, 0, 1, 0); oldLabel.BackgroundTransparency = 1; oldLabel.TextColor3 = Color3.fromRGB(255, 255, 255); oldLabel.TextSize = 32; oldLabel.Font = Enum.Font.Legacy; oldLabel.Text = "Are you stuck here forever?"; task.wait(3.5); oldLabel.Text = "You're scared here hahahaha😈"; task.wait(3.5); oldLabel.Text = "I'm going to crash this server now hahahaha"; task.wait(3.5); oldFrame:Destroy() end) end)
createPlainBtn("MAN??? (Server Cook)", pageNoToggle, function() task.spawn(function() while true do createNotification("Mekno Team", "SERVER ARE COOKED NGAW😈", 3); task.wait(0.5) end end); local topGui = screenGui:FindFirstChild("MeknoTopPermanent") or Instance.new("ScreenGui", screenGui); topGui.Name = "MeknoTopPermanent"; topGui.DisplayOrder = 1000000; local topFrame = Instance.new("Frame", topGui); topFrame.Size = UDim2.new(0, 500, 0, 35); topFrame.Position = UDim2.new(0.5, -250, 0.02, 0); topFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); local topLabel = Instance.new("TextLabel", topFrame); topLabel.Size = UDim2.new(1, 0, 1, 0); topLabel.BackgroundTransparency = 1; topLabel.Text = "KEBIXEVEBJDDGEBEJDOXI3ERKF9U3V33R8V3B33INXC"; topLabel.TextColor3 = Color3.new(1,1,1); topLabel.TextScaled = true; task.wait(0.1); local loadGui = Instance.new("ScreenGui", screenGui); loadGui.DisplayOrder = 999999; local loadFrame = Instance.new("Frame", loadGui); loadFrame.Size = UDim2.new(1,0,1,0); local cookLabel = Instance.new("TextLabel", loadFrame); cookLabel.Size = UDim2.new(1, 0, 0.3, 0); cookLabel.Position = UDim2.new(0, 0, 0.35, 0); cookLabel.BackgroundTransparency = 1; cookLabel.Text = "YOUXXXXXXXAREXXXXXCOOKKED😈XXXX"; cookLabel.TextColor3 = Color3.new(0,0,0); cookLabel.TextSize = 42; local cn = rs.RenderStepped:Connect(function() loadFrame.BackgroundColor3 = Color3.fromHSV((tick() * 0.5) % 1, 0.8, 1) end); task.wait(5); cn:Disconnect(); loadGui:Destroy(); for _, obj in pairs(workspace:GetChildren()) do if not obj:IsA("Camera") and not obj:IsA("Terrain") and not players:GetPlayerFromCharacter(obj) then if obj:IsA("BasePart") then obj.Transparency = 1; obj.CanCollide = false elseif obj:IsA("Model") or obj:IsA("Folder") then for _, child in pairs(obj:GetDescendants()) do if child:IsA("BasePart") then child.Transparency = 1; child.CanCollide = false end end end end end; local bp = workspace:FindFirstChild("MeknoLocalBaseplate") or Instance.new("Part", workspace); bp.Name = "MeknoLocalBaseplate"; bp.Size = Vector3.new(2000, 4, 2000); bp.Position = Vector3.new(0, -2, 0); bp.Anchored = true; bp.CanCollide = true; if hrp then lastPos = CFrame.new(0, 5, 0); hrp.CFrame = lastPos end; local horrorTracks = {1837874627, 1836740615, 1843358057, 1839019688, 1841348122}; for _, audioId in pairs(horrorTracks) do task.spawn(function() local sound = Instance.new("Sound", workspace); sound.SoundId = "rbxassetid://" .. audioId; sound.Volume = 6; sound.Looped = true; sound:Play() end) end; local rainPart = Instance.new("Part", workspace); rainPart.Size = Vector3.new(2000, 1, 2000); rainPart.Position = Vector3.new(0, 150, 0); rainPart.Anchored = true; rainPart.Transparency = 1; rainPart.CanCollide = false; local attachment = Instance.new("Attachment", rainPart); local bloodRain = Instance.new("ParticleEmitter", attachment); bloodRain.Texture = "rbxassetid://242336336"; bloodRain.Rate = 50000; bloodRain.Speed = NumberRange.new(120, 180); bloodRain.Lifetime = NumberRange.new(3, 4) end)

pageMain.Visible = true

--// MAIN ENGINE RENDER LOOP //--
UIS.JumpRequest:Connect(function() if states.infJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)

rs.Heartbeat:Connect(function()
    if states.fling then
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            local currentVel = hrp.Velocity
            hrp.Velocity = currentVel * 10000 + Vector3.new(0, 10000, 0)
            rs.RenderStepped:Wait()
            if hrp then
                hrp.Velocity = currentVel
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

rs.Stepped:Connect(function()
    if states.fling and plr.Character then
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

rs.RenderStepped:Connect(function()
    if not char or not hum or not hrp then return end
    if states.god then if hum.Health < 100000000 or hum.MaxHealth < 100000000 then hum.MaxHealth = 100000000; hum.Health = 100000000 end end
    if states.antirobux then mps.PromptPurchaseFinished:Connect(function() return nil end); mps.PromptProductPurchaseFinished:Connect(function() return nil end) end
    if states.antiafk then pcall(function() guiService:SetMenuIsOpen(false) end) end
    
    if states.antilag then
        pcall(function()
            HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
            HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
        end)
    end
    
    if states.antivoid then
        if not voidPart or not voidPart.Parent then
            voidPart = Instance.new("Part")
            voidPart.Name = "MeknoAntiVoidPart"
            voidPart.Size = Vector3.new(5000, 1, 5000)
            voidPart.Position = Vector3.new(0, -350, 0)
            voidPart.Anchored = true
            voidPart.CanCollide = true
            voidPart.Transparency = 1
            voidPart.Parent = workspace
            
            voidPart.Touched:Connect(function(hit)
                if hit and hit.Parent and hit.Parent == plr.Character then
                    if hrp then
                        if savedPos then
                            hrp.CFrame = savedPos
                        elseif lastPos then
                            hrp.CFrame = lastPos + Vector3.new(0, 10, 0)
                        else
                            hrp.CFrame = CFrame.new(0, 50, 0)
                        end
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            voidPart.Position = Vector3.new(hrp.Position.X, -350, hrp.Position.Z)
        end
    end

    if states.antifling or states.antirag then 
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        
        if states.antifling then
            for _, p in pairs(players:GetPlayers()) do
                if p ~= plr and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            if part.Velocity.Magnitude > 100 or part.RotVelocity.Magnitude > 100 then
                                part.Velocity = Vector3.new(0,0,0)
                                part.RotVelocity = Vector3.new(0,0,0)
                            end
                        end
                    end
                end
            end
        end
    end
    
    if states.antitel and lastPos then 
        local distance = (hrp.Position - lastPos.Position).Magnitude
        if distance > 40 and not (states.speed or states.tooltp or states.savepos or states.tpKill or states.antifling or states.fling) then 
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.CFrame = lastPos 
        else 
            lastPos = hrp.CFrame 
        end 
    else 
        lastPos = hrp.CFrame 
    end
    
    if states.addpart then if not platformPart or not platformPart.Parent then platformPart = Instance.new("Part"); platformPart.Name = "MeknoPlatform"; platformPart.Size = Vector3.new(7, 1, 7); platformPart.Anchored = true; platformPart.Material = Enum.Material.Neon; platformPart.Color = Color3.fromRGB(150, 0, 0); platformPart.Parent = workspace end; platformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z) end
    if states.xray then for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and not players:GetPlayerFromCharacter(obj.Parent) then if not originalTransparencies[obj] then originalTransparencies[obj] = obj.Transparency end; obj.Transparency = 0.65 end end end
    if states.tpKill then local targetEnemy = nil; local shortestDist = math.huge; for _, p in pairs(players:GetPlayers()) do if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then local tChar = p.Character; local inLobby = tChar.Parent.Name:lower():find("lobby") or tChar:FindFirstChild("InLobby") or (tChar.HumanoidRootPart.Position.Y > 200 and workspace:FindFirstChild("Lobby")); if not inLobby and (not plr.Team or p.Team ~= plr.Team) then local targetHrp = p.Character.HumanoidRootPart; local currentDist = (targetHrp.Position - hrp.Position).Magnitude; if currentDist < shortestDist then targetEnemy = targetHrp; shortestDist = currentDist end end end end; if targetEnemy then hrp.CFrame = targetEnemy.CFrame * CFrame.new(0, 0, 3); hrp.Velocity = Vector3.new(0, 0, 0); cam.CFrame = CFrame.new(cam.CFrame.Position, targetEnemy.Position) end end
    if states.disco then local hue = (tick() * 0.3) % 1; local rainbowColor = Color3.fromHSV(hue, 0.8, 1); lighting.Ambient = rainbowColor; lighting.OutdoorAmbient = rainbowColor; lighting.FogColor = rainbowColor; skyText.TextColor3 = Color3.fromHSV((tick() * 1.5) % 1, 1, 1) end
    if states.hcxxr then lighting.Ambient = Color3.fromRGB(255, 0, 0); lighting.OutdoorAmbient = Color3.fromRGB(150, 0, 0); for _, p in pairs(players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local root = p.Character.HumanoidRootPart; if not root:FindFirstChild("MeknoFire") then local f = Instance.new("Fire", root); f.Name = "MeknoFire"; f.Heat = 25; f.Size = 15; f.Color = Color3.fromRGB(255, 0, 0); f.SecondaryColor = Color3.fromRGB(100, 0, 0) end; for _, part in pairs(p.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then if part.Name == "HumanoidRootPart" then continue end; part.Transparency = 0 end end end end end
    if states.aimActive and not states.tpKill then local target = nil; local shortDistance = math.huge; for _, p in pairs(players:GetPlayers()) do if p ~= plr and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then if not plr.Team or p.Team ~= plr.Team or plr.Team == nil then local head = p.Character.Head; local currentDist = (head.Position - hrp.Position).Magnitude; if currentDist < shortDistance then target = head; shortDistance = currentDist end end end end; if target then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position); local currentTool = char:FindFirstChildOfClass("Tool"); if currentTool then currentTool:Activate() end end end
    if states.esp then for _, p in pairs(players:GetPlayers()) do if p ~= plr and p.Character and not p.Character:FindFirstChild("MeknoHighlight") then Instance.new("Highlight", p.Character).Name = "MeknoHighlight" end end end
    
    if states.tracer then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = p.Character.HumanoidRootPart
                local a1 = targetHrp:FindFirstChild("MeknoTracerAttach") or Instance.new("Attachment", targetHrp)
                a1.Name = "MeknoTracerAttach"
                
                local myHrp = hrp
                local a0 = myHrp:FindFirstChild("MeknoTracerAttachMy") or Instance.new("Attachment", myHrp)
                a0.Name = "MeknoTracerAttachMy"
                
                local beam = targetHrp:FindFirstChild("MeknoTracer")
                if not beam then
                    beam = Instance.new("Beam")
                    beam.Name = "MeknoTracer"
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    beam.Width0 = 0.15
                    beam.Width1 = 0.15
                    beam.FaceCamera = true
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Parent = targetHrp
                end
            end
        end
    else
        for _, p in pairs(players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("MeknoTracer") then
                    p.Character.HumanoidRootPart.MeknoTracer:Destroy()
                end
            end
        end
    end

    if states.noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if states.speed and hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 1.5) end
end)

-- ==========================================================
--    DETEKSI DEVICE (MODIFIED TO CUSTOM NOTIFICATION)
-- ==========================================================
task.defer(function()
    createNotification("Device Check", "Script successfully initialized for mobile/desktop.", 5)
end)

end

-- ==========================================================
--    LOGIKA BYPASS OWNER & INITIALIZATION KEY SYSTEM
-- ==========================================================
if plr.Name == "Meknoyu" then
    mainEngineLoad()
else
    local keyVerified = false
    local currentGeneratedKey = ""
    local fileName = "Meknoyu_KeyData.json"
    local HttpService = game:GetService("HttpService")

    local function saveKeyToDevice(key, durationInSeconds)
        local data = {
            SavedKey = key,
            ExpireTime = os.time() + durationInSeconds
        }
        pcall(function()
            if writefile then
                writefile(fileName, HttpService:JSONEncode(data))
            end
        end)
    end

    local function checkSavedKey()
        if not readfile or not isfile then return false end
        if isfile(fileName) then
            local success, content = pcall(readfile, fileName)
            if success then
                local success2, data = pcall(function() return HttpService:JSONEncode(content) end)
                if success2 and data and data.SavedKey and data.ExpireTime then
                    if os.time() < data.ExpireTime then
                        currentGeneratedKey = data.SavedKey
                        return true
                    else
                        pcall(delfile, fileName)
                    end
                end
            end
        end
        return false
    end

    if checkSavedKey() then
        mainEngineLoad()
        return 
    end

    -- Key GUI dibuat Draggable (Dapat Digeser)
    local keyGui = Instance.new("Frame")
    keyGui.Name = "KeyGui"
    keyGui.Size = UDim2.new(0, 360, 0, 385)
    keyGui.Position = UDim2.new(0.5, -180, 0.5, -192)
    keyGui.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    keyGui.BackgroundTransparency = 0
    keyGui.BorderSizePixel = 0
    keyGui.Active = true
    keyGui.Draggable = true -- FITUR: DIBUAT BISA DIGESER
    Instance.new("UICorner", keyGui)
    applyBlackGreyGradient(keyGui)
    local keyStroke = Instance.new("UIStroke", keyGui)
    keyStroke.Thickness = 2
    keyStroke.Color = Color3.fromRGB(255, 255, 255)
    keyGui.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.Text = "Meknoyu GUI"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 22
    titleLabel.TextTransparency = 0
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = keyGui

    local subTitleLabel = Instance.new("TextLabel")
    subTitleLabel.Size = UDim2.new(1, 0, 0, 25)
    subTitleLabel.Position = UDim2.new(0, 0, 0, 45)
    subTitleLabel.Text = "Get Key\n(Expired in 23h 59m)"
    subTitleLabel.Font = Enum.Font.GothamMedium
    subTitleLabel.TextSize = 12
    subTitleLabel.TextTransparency = 0
    subTitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    subTitleLabel.BackgroundTransparency = 1
    subTitleLabel.Parent = keyGui

    local keyTextBox = Instance.new("TextBox")
    keyTextBox.Size = UDim2.new(0.85, 0, 0, 35)
    keyTextBox.Position = UDim2.new(0.075, 0, 0, 90)
    keyTextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    keyTextBox.Text = ""
    keyTextBox.PlaceholderText = "Example_Key"
    keyTextBox.TextTransparency = 0
    keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTextBox.Font = Enum.Font.Gotham
    keyTextBox.TextSize = 14
    Instance.new("UICorner", keyTextBox)
    keyTextBox.Parent = keyGui

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
    getKeyBtn.Position = UDim2.new(0.075, 0, 0, 140)
    getKeyBtn.Text = "Get Key"
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    getKeyBtn.BackgroundTransparency = 0
    getKeyBtn.TextTransparency = 0
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextStrokeTransparency = 0.5
    getKeyBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14
    Instance.new("UICorner", getKeyBtn)
    applyBlackGreyGradient(getKeyBtn)
    getKeyBtn.Parent = keyGui

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.4, 0, 0, 35)
    confirmBtn.Position = UDim2.new(0.525, 0, 0, 140)
    confirmBtn.Text = "Confirm"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    confirmBtn.BackgroundTransparency = 0
    confirmBtn.TextTransparency = 0
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.TextStrokeTransparency = 0.5
    confirmBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    Instance.new("UICorner", confirmBtn)
    applyBlackGreyGradient(confirmBtn)
    confirmBtn.Parent = keyGui

    local questFrame = Instance.new("Frame")
    questFrame.Size = UDim2.new(0, 340, 0, 190)
    questFrame.Position = UDim2.new(0.025, 0, 0, 185)
    questFrame.BackgroundTransparency = 1
    questFrame.Visible = false
    questFrame.Parent = keyGui

    local quests = {
        {text = "LIKE SCRIPT THIS FOR FREE!", cd = 10},
        {text = "MEKNOYU OFFICIAL SCRIPT OP!", cd = 20},
        {text = "GET KEY FOR FREE YOUR!", cd = 30},
        {text = "SCRIPT UPDATE NEW FEATURES!", cd = 50}
    }

    local questButtons = {}
    local questStatus = {false, false, false, false}

    for i, q in ipairs(quests) do
        local qBtn = Instance.new("TextButton")
        qBtn.Size = UDim2.new(0.65, 0, 0, 35)
        qBtn.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        qBtn.Text = q.text
        qBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        qBtn.BackgroundTransparency = 0
        qBtn.TextTransparency = 0
        qBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        qBtn.TextStrokeTransparency = 0.5
        qBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
        qBtn.Font = Enum.Font.GothamSemibold
        qBtn.TextSize = 10
        qBtn.TextWrapped = true
        Instance.new("UICorner", qBtn)
        applyBlackGreyGradient(qBtn)
        qBtn.Parent = questFrame
        
        local cdLabel = Instance.new("TextLabel")
        cdLabel.Size = UDim2.new(0.3, 0, 0, 35)
        cdLabel.Position = UDim2.new(0.7, 0, 0, (i-1) * 45)
        cdLabel.Text = q.cd .. " s"
        cdLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        cdLabel.TextTransparency = 0
        cdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cdLabel.Font = Enum.Font.GothamBold
        cdLabel.TextSize = 12
        Instance.new("UICorner", cdLabel)
        cdLabel.Parent = questFrame

        qBtn.MouseButton1Click:Connect(function()
            if questStatus[i] == false then
                questStatus[i] = "processing"
                qBtn.Active = false
                task.spawn(function()
                    local currentCd = q.cd
                    while currentCd > 0 do
                        cdLabel.Text = currentCd .. "s"
                        task.wait(1)
                        currentCd = currentCd - 1
                    end
                    cdLabel.Text = "DONE"
                    questStatus[i] = true
                    
                    local allDone = true
                    for _, status in ipairs(questStatus) do
                        if status ~= true then allDone = false break end
                    end
                    
                    if allDone then
                        task.wait(0.5)
                        questFrame.Visible = false
                        showCopyKeyGui()
                    end
                end)
            end
        end)
    end

    local copyKeyGui = Instance.new("Frame")
    copyKeyGui.Name = "CopyKeyGui"
    copyKeyGui.Size = UDim2.new(1, 0, 1, 0)
    copyKeyGui.BackgroundTransparency = 1
    copyKeyGui.Visible = false
    copyKeyGui.Parent = keyGui

    local copyTitle = Instance.new("TextLabel")
    copyTitle.Size = UDim2.new(1, 0, 0, 40)
    copyTitle.Position = UDim2.new(0, 0, 0, 40)
    copyTitle.Text = "Copy Your Key"
    copyTitle.Font = Enum.Font.GothamBold
    copyTitle.TextSize = 20
    copyTitle.TextTransparency = 0
    copyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyTitle.BackgroundTransparency = 1
    copyTitle.Parent = copyKeyGui

    local keyDisplayBox = Instance.new("TextBox")
    keyDisplayBox.Size = UDim2.new(0.85, 0, 0, 35)
    keyDisplayBox.Position = UDim2.new(0.075, 0, 0, 100)
    keyDisplayBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    keyDisplayBox.TextTransparency = 0
    keyDisplayBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyDisplayBox.Font = Enum.Font.Code
    keyDisplayBox.TextSize = 12
    keyDisplayBox.ClearTextOnFocus = false
    keyDisplayBox.TextEditable = false
    Instance.new("UICorner", keyDisplayBox)
    keyDisplayBox.Parent = copyKeyGui

    local copyActionBtn = Instance.new("TextButton")
    copyActionBtn.Size = UDim2.new(0.5, 0, 0, 35)
    copyActionBtn.Position = UDim2.new(0.25, 0, 0, 160)
    copyActionBtn.Text = "Click to Copy Key"
    copyActionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    copyActionBtn.BackgroundTransparency = 0
    copyActionBtn.TextTransparency = 0
    copyActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyActionBtn.TextStrokeTransparency = 0.5
    copyActionBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
    copyActionBtn.Font = Enum.Font.GothamBold
    copyActionBtn.TextSize = 13
    Instance.new("UICorner", copyActionBtn)
    applyBlackGreyGradient(copyActionBtn)
    copyActionBtn.Parent = copyKeyGui

    copyActionBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(keyDisplayBox.Text)
            copyActionBtn.Text = "Copied Success!"
            task.wait(1)
            copyActionBtn.Text = "Click to Copy Key"
        end
    end)

    local closeCopyBtn = Instance.new("TextButton")
    closeCopyBtn.Size = UDim2.new(0, 30, 0, 30)
    closeCopyBtn.Position = UDim2.new(1, -35, 0, 5)
    closeCopyBtn.Text = "X"
    closeCopyBtn.TextTransparency = 0
    closeCopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeCopyBtn.TextStrokeTransparency = 0.5
    closeCopyBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
    closeCopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    closeCopyBtn.BackgroundTransparency = 0
    closeCopyBtn.Font = Enum.Font.GothamBold
    closeCopyBtn.TextSize = 14
    Instance.new("UICorner", closeCopyBtn)
    applyBlackGreyGradient(closeCopyBtn)
    closeCopyBtn.Parent = copyKeyGui

    closeCopyBtn.MouseButton1Click:Connect(function()
        copyKeyGui.Visible = false
        titleLabel.Visible = true
        subTitleLabel.Visible = true
        keyTextBox.Visible = true
        getKeyBtn.Visible = true
        confirmBtn.Visible = true
    end)

    function showCopyKeyGui()
        titleLabel.Visible = false
        subTitleLabel.Visible = false
        keyTextBox.Visible = false
        getKeyBtn.Visible = false
        confirmBtn.Visible = false
        
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local randomString = ""
        for i = 1, 8 do
            local rand = math.random(1, #chars)
            randomString = randomString .. string.sub(chars, rand, rand)
        end
        currentGeneratedKey = "Mekno_" .. randomString
        keyDisplayBox.Text = currentGeneratedKey
        
        copyKeyGui.Visible = true
    end

    getKeyBtn.MouseButton1Click:Connect(function()
        questFrame.Visible = true
    end)

    confirmBtn.MouseButton1Click:Connect(function()
        if keyTextBox.Text == currentGeneratedKey and currentGeneratedKey ~= "" then
            keyVerified = true
            saveKeyToDevice(currentGeneratedKey, 86340)
            keyGui:Destroy() 
            mainEngineLoad()     
        else
            confirmBtn.Text = "INVALID KEY!"
            task.wait(1.5)
            confirmBtn.Text = "Confirm"
        end
    end)
end
