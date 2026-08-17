local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "kohlsify",
    Size = UDim2.fromOffset(340, 740),
    Theme = "Crimson",
    AutoShow = true,
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local prefix = "."
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local ChatService = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
local __sayRequest = ChatService:WaitForChild("SayMessageRequest")

local function tchat(msg) __sayRequest:FireServer(msg, "System") end
local function chat(msg) __sayRequest:FireServer(msg, "All") end
local commands = {}

function addcommand(name, desc, func)
    commands[name:lower()] = func
end

local function executeCommand(text)
    if text:sub(1, 1) == prefix then text = text:sub(2) end
    local parts = text:split(" ")
    local cmd = parts[1]:lower()
    local func = commands[cmd]
    if func then
        local args = {}
        for i = 2, #parts do table.insert(args, parts[i]) end
        func(args)
    else
        WindUI:Notify({Title = "kohlsify", Content = "Command not found: " .. cmd, Duration = 3})
    end
end

function GetPlayers(target)
    local all = Players:GetPlayers()
    target = tostring(target or ""):lower()
    if target == "all" then return all end
    if target == "others" then local r = {} for _, p in ipairs(all) do if p ~= plr then table.insert(r, p) end end return r end
    if target == "me" then return {plr} end
    local r = {}
    for _, p in ipairs(all) do
        if p.Name:lower():find(target, 1, true) or p.DisplayName:lower():find(target, 1, true) then table.insert(r, p) end
    end
    return r
end

local blacklisted = {}
local blacklistReasons = {}
local recentlyKicked = {}
local whitelist = {
    "nowhudhejeir", "EgorYa900", "EgorYa900Alt", "PaulTheKinggg"
}
local ownerName = "nowhudhejeir"

if not isfile or not readfile or not writefile then
    isfile = function() return false end; readfile = function() return "" end; writefile = function() end
end
if not appendfile then
    appendfile = function(f, d) local o = (isfile(f) and readfile(f)) or ""; writefile(f, o .. d) end
end
if isfile("Blacklisted.txt") then
    for _, line in ipairs(readfile("Blacklisted.txt"):split("\n")) do
        if line ~= "" and line ~= "agspureiam" then
            local name, reason = line:match("^([^|]*)|?(.*)$")
            if name and name ~= "" then
                table.insert(blacklisted, name)
                if reason and reason ~= "" then
                    blacklistReasons[name] = reason
                end
            end
        end
    end
else
    writefile("Blacklisted.txt", "AZLANPLATTERS\nCapiataloftheking\n")
    table.insert(blacklisted, "AZLANPLATTERS")
    table.insert(blacklisted, "Capiataloftheking")
end

local Terrain = workspace:FindFirstChild("Terrain") or workspace:FindFirstChild("terrain")
local GameFolder = Terrain and (Terrain:FindFirstChild("_Game") or Terrain:FindFirstChild("GameFolder"))
local Admin = GameFolder and GameFolder:FindFirstChild("Admin")
local Pads = Admin and Admin:FindFirstChild("Pads")
local Folder = GameFolder and GameFolder:FindFirstChild("Folder")

local antipunish = false
local antijail = false
local antikill = false
local antifling = false
local antiblind = false
local antifreeze = false
local antiBanHammer = false
local antimessage = false
local Loops = {
    antifly = false,
    antivoid = false,
    antiskydive = false,
    antitripmine = false,
    antieggbomb = false
}
local cageLoops = {}
local spamConnection = nil
local autoGod = false
local autoName = false
local permNotified = false
local nokEnabled = false

local configFolder = "kohlsify"
local configFile = configFolder .. "/config.json"
if not isfolder(configFolder) then makefolder(configFolder) end

local function saveConfig()
    local data = {
        antipunish = antipunish,
        antijail = antijail,
        antikill = antikill,
        antifling = antifling,
        antiblind = antiblind,
        antifreeze = antifreeze,
        antiBanHammer = antiBanHammer,
        antimessage = antimessage,
        Loops = Loops,
        autoGod = autoGod,
        autoName = autoName,
        permEnabled = __permEnabled,
        nokEnabled = nokEnabled
    }
    writefile(configFile, HS:JSONEncode(data))
end

local function loadConfig()
    if isfile(configFile) then
        local success, data = pcall(function() return HS:JSONDecode(readfile(configFile)) end)
        if success and data then
            antipunish = data.antipunish or false
            antijail = data.antijail or false
            antikill = data.antikill or false
            antifling = data.antifling or false
            antiblind = data.antiblind or false
            antifreeze = data.antifreeze or false
            antiBanHammer = data.antiBanHammer or false
            antimessage = data.antimessage or false
            if data.Loops then
                for k, v in pairs(data.Loops) do
                    Loops[k] = v
                end
            end
            autoGod = data.autoGod or false
            autoName = data.autoName or false
            __permEnabled = data.permEnabled or false
            nokEnabled = data.nokEnabled or false
        end
    end
end
loadConfig()

local function isWhitelisted(player)
    if plr.Name == ownerName then return false end
    return table.find(whitelist, player.Name) ~= nil
end

local function __hasRealAdmin() return Pads and Pads:FindFirstChild(plr.Name .. "'s admin") ~= nil end
local function __getFreePad() if not Pads then return nil end return Pads:FindFirstChild("Touch to get admin") end
local function __claimPad(pad)
    if not pad or not firetouchinterest then return false end
    local chr = plr.Character if not chr or not chr:FindFirstChild("Head") then return false end
    local spr = chr.Head local a = pad:FindFirstChild("Head") if not a then return false end
    firetouchinterest(a, spr, 1) firetouchinterest(a, spr, 0) firetouchinterest(a, spr, 1) task.wait(0.05) firetouchinterest(a, spr, 0)
    return true
end

local __permEnabled = false
local __permCoroutine
local function __permLoop()
    if __permCoroutine then task.cancel(__permCoroutine) end
    permNotified = false
    __permCoroutine = task.spawn(function()
        while __permEnabled do
            if not __hasRealAdmin() then
                local free = __getFreePad()
                if free then
                    if __claimPad(free) then
                        if not permNotified then
                            permNotified = true
                        end
                    end
                else
                    if GameFolder and GameFolder:FindFirstChild("Admin") then
                        local regen = GameFolder.Admin:FindFirstChild("Regen")
                        if regen and regen:FindFirstChild("ClickDetector") then
                            if fireclickdetector then fireclickdetector(regen.ClickDetector) else pcall(function() regen.ClickDetector:Fire() end) end
                            task.wait(0.3)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

plr.CharacterAdded:Connect(function(chr)
    if autoGod then
        tchat("god me")
        tchat("ff me")
    end
    if autoName then
        local role = "User"
        if plr.Name == ownerName then role = "Owner"
        elseif isWhitelisted(plr) then role = "Support" end
        tchat("name me [" .. role .. " in kohlsify]\n" .. plr.DisplayName)
    end
    chr.ChildAdded:Connect(function(ch)
        if antifling and ch.Name == "BFRC" and ch:IsDescendantOf(workspace:WaitForChild(plr.Name)) then
            local hum = chr:FindFirstChild("Humanoid") if hum then hum.Sit = false end
            local torso = chr:FindFirstChild("Torso") if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            game:GetService("RunService").Heartbeat:Wait()
            pcall(function() ch:Destroy() end)
            if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
        end
    end)
end)

spawn(function()
    local lastPos = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Position or nil
    while true do
        if antifling then
            local chr = plr.Character
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                local r = chr.HumanoidRootPart
                local vel = r.Velocity
                if math.abs(vel.X) > 16 or math.abs(vel.Z) > 16 then
                    if lastPos then
                        r.CFrame = CFrame.new(lastPos)
                    end
                    r.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            lastPos = plr.Character.HumanoidRootPart.Position
        end
        game:GetService("RunService").RenderStepped:Wait()
    end
end)

spawn(function()
    while task.wait(0.1) do
        if antiblind then
            local blind = plr.PlayerGui:FindFirstChild("EFFECTGUIBLIND")
            if blind then blind:Destroy() end
            local confirm = plr.PlayerGui:FindFirstChild("ConfirmationPrompt")
            if confirm then confirm:Destroy() end
        end

        if antimessage then
            pcall(function()
                for _, v in ipairs(plr.PlayerGui:GetDescendants()) do
                    if v.Name == "MessageGUI" or v.Name == "Message" or v.Name == "HintGUI" then v:Destroy() end
                end
                if Folder then for _, v in ipairs(Folder:GetDescendants()) do if v.Name == "Message" then v:Destroy() end end end
            end)
        end

        if antiBanHammer then
            for _, p in ipairs(Players:GetPlayers()) do
                local found = false
                if p.Backpack then
                    local bh = p.Backpack:FindFirstChild("BanHammer")
                    if bh then bh:Destroy() found = true end
                end
                if p.Character then
                    local chbh = p.Character:FindFirstChild("BanHammer")
                    if chbh then chbh:Destroy() found = true end
                end
                if found then
                    if p == plr then
                        tchat("reset me")
                    else
                        tchat("reset " .. p.Name)
                    end
                end
            end
        end

        if antijail then
            pcall(function()
                local jailObj = GameFolder and GameFolder:FindFirstChild("Folder") and GameFolder.Folder:FindFirstChild(plr.Name .. "'s jail")
                if jailObj then tchat("unjail me") end
            end)
        end

        if Loops.antifly then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") then
                    local state = chr.Humanoid:GetState()
                    if not chr:FindFirstChild("Seizure") and (state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Flying) then
                        tchat("unfly me")
                        tchat("clip me")
                        if chr:FindFirstChild("Torso") then chr.Torso.Anchored = false end
                        chr.Humanoid.PlatformStand = false
                    end
                end
            end)
        end

        if Loops.antivoid then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y < -7 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antiskydive then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y > 256 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antitripmine then pcall(function() local tm = workspace:FindFirstChild("SubspaceTripmine") if tm then tm:Destroy() tchat("clr") end end) end
        if Loops.antieggbomb then pcall(function() local eb = workspace:FindFirstChild("EggBomb") if eb then eb:Destroy() tchat("clr") end end) end

        if antikill then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0 then
                    tchat("reset me")
                end
            end)
        end

        if antifreeze then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.WalkSpeed == 0 then
                    tchat("thaw me")
                end
            end)
        end
    end
end)

game:GetService("Lighting").ChildAdded:Connect(function(child)
    if antipunish and child.Name == plr.Name then child.Parent = workspace tchat("unpunish me") end
end)

plr.PlayerGui.ChildAdded:Connect(function(child)
    if antiblind then if child.Name == "EFFECTGUIBLIND" or child.Name == "ConfirmationPrompt" then child:Destroy() end end
end)

local GAMEFOLDER = GameFolder and GameFolder.Name or "GameFolder"
local kah_np = false

function TNOK(mode)
    pcall(function()
        if kah_np == false then
            if not game:GetService("Workspace").Terrain[GAMEFOLDER].Workspace.Obby:GetChildren() then
                return
            end
            for i, v in pairs(game:GetService("Workspace").Terrain[GAMEFOLDER].Workspace.Obby:GetChildren()) do
                if mode == "true" then
                    v.CanTouch = false
                else
                    v.CanTouch = true
                end
            end
        else
            for i, v in pairs(workspace.Tabby.Admin_House.Obby:GetChildren()) do
                if mode == "true" then
                    v.CanTouch = false
                else
                    v.CanTouch = true
                end
            end
        end
    end)
end

addcommand("nokill", "Disable obby kill", function() nokEnabled = true TNOK("true") WindUI:Notify({Title="kohlsify", Content="Obby Kill disabled", Duration=2}) saveConfig() end)
addcommand("unnokill", "Enable obby kill", function() nokEnabled = false TNOK("false") WindUI:Notify({Title="kohlsify", Content="Obby Kill enabled", Duration=2}) saveConfig() end)

plr.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "?" then
        executeCommand(msg:sub(2))
    end
end)

local function handleBannedPlayer(p)
    if table.find(blacklisted, p.Name) and not (p.Name == ownerName or isWhitelisted(p)) then
        local reason = blacklistReasons[p.Name]
        if reason and reason ~= "" then
            chat(p.DisplayName .. " you have been in blacklist, reason: " .. reason)
        end
        task.wait(2)
        executeCommand("kick " .. p.Name)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= plr and table.find(whitelist, p.Name) then
        WindUI:Notify({Title="kohlsify", Content="Whitelisted, " .. p.Name .. " join in server", Duration=5})
    end
    if p ~= plr then
        if recentlyKicked[p.Name] then
            local dialog = Instance.new("ScreenGui")
            dialog.Name = "ReturnDialog"
            dialog.Parent = game.CoreGui
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 120)
            frame.Position = UDim2.new(0.5, -150, 0.5, -60)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = dialog
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1,0,0,30)
            title.BackgroundTransparency = 1
            title.Text = p.Name .. " joined back, kick him?"
            title.TextColor3 = Color3.new(1,1,1)
            title.Parent = frame
            local ignoreBtn = Instance.new("TextButton")
            ignoreBtn.Size = UDim2.new(0,100,0,30)
            ignoreBtn.Position = UDim2.new(0.05,0,0.7,0)
            ignoreBtn.Text = "Ignore"
            ignoreBtn.Parent = frame
            local kickBtn = Instance.new("TextButton")
            kickBtn.Size = UDim2.new(0,100,0,30)
            kickBtn.Position = UDim2.new(0.55,0,0.7,0)
            kickBtn.Text = "Kick"
            kickBtn.Parent = frame
            ignoreBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
            kickBtn.MouseButton1Click:Connect(function()
                dialog:Destroy()
                executeCommand("kick " .. p.Name)
            end)
            task.delay(30, function() recentlyKicked[p.Name] = nil end)
        end
        handleBannedPlayer(p)
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= plr then
        if table.find(whitelist, p.Name) then
            WindUI:Notify({Title="kohlsify", Content="Whitelisted, " .. p.Name .. " join in server", Duration=5})
        end
        handleBannedPlayer(p)
    end
end

local __commandsTab = Window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({
    Title = "Commands 1",
    Desc = "ban <player> [reason] – add to blacklist & kick if online\nunban <player> – remove from blacklist\nfpunish <player> – fake punish\nkick <player> – hot potato kick\nkid <player> – make a kid\nspam <message> – spam\nunspam – stop spam\nfixfilter – fix chat filter\nbypassmessage <msg> – bypass filter\ncage <player> – cage player\nloopcage <player> – loop cage\nunloopcage <player> – stop loop\ngearbl <player> – gear ban\nungearbl <player> – ungear ban\nnokill – disable obby kill\nunnokill – enable obby kill\nclonef3x/cf3x – clone your Building Tools\nremoveobby/deleteobby/rmobby/dobby – remove obby\nunlockworkspace/unlockws – unlock workspace"
})
__commandsTab:Paragraph({
    Title = "Commands 2",
    Desc = "fixvel – fix velocity\nregen – click regen\nfixregen – move regen to spawn\ntptoregen – teleport to regen\nrmoveregen – remove regen\ndeletetool – get delete tool\njerk – you know\nbang <player> – bang animation\nunbang – stop bang\nping – show ping\nrejoin (rj) – rejoin server\nserverhop (shop) – hop server\nnocam – break camera (shiftlock)\nfcam <player> – break player's camera\nfixcam – fix your camera\nslag – server lag (2 stones)\nserverlag – server lag (2 stones)\nr15 – switch to R15\nr6 – switch to R6"
})

local __mainTab = Window:Tab({ Title = "Main", Icon = "home" })
__mainTab:Toggle({ Title = "Auto Perm", Value = __permEnabled, Callback = function(v) __permEnabled = v if v then __permLoop() else if __permCoroutine then task.cancel(__permCoroutine) end end saveConfig() end })
__mainTab:Toggle({ Title = "Auto God", Value = autoGod, Callback = function(v) autoGod = v saveConfig() end })
__mainTab:Toggle({ Title = "Auto Name", Value = autoName, Callback = function(v) autoName = v saveConfig() end })

local __toolsTab = Window:Tab({ Title = "Tools", Icon = "tool" })
__toolsTab:Button({ Title = "Fix Regen", Callback = function() commands["fixregen"]({}) end })
__toolsTab:Button({ Title = "TP to Regen", Callback = function() commands["tptoregen"]({}) end })
__toolsTab:Button({ Title = "Rmove Regen", Callback = function() commands["rmoveregen"]({}) end })
__toolsTab:Button({ Title = "Delete Tool", Callback = function() commands["deletetool"]({}) end })

local __protectTab = Window:Tab({ Title = "Protection", Icon = "shield" })
__protectTab:Toggle({ Title = "Anti Punish", Value = antipunish, Callback = function(v) antipunish = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Kill", Value = antikill, Callback = function(v) antikill = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Freeze", Value = antifreeze, Callback = function(v) antifreeze = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Jail", Value = antijail, Callback = function(v) antijail = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Fling/Speed", Value = antifling, Callback = function(v) antifling = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Blind", Value = antiblind, Callback = function(v) antiblind = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Fly", Value = Loops.antifly, Callback = function(v) Loops.antifly = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Void", Value = Loops.antivoid, Callback = function(v) Loops.antivoid = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Skydive", Value = Loops.antiskydive, Callback = function(v) Loops.antiskydive = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Tripmine", Value = Loops.antitripmine, Callback = function(v) Loops.antitripmine = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Eggbomb", Value = Loops.antieggbomb, Callback = function(v) Loops.antieggbomb = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti BanHammer", Value = antiBanHammer, Callback = function(v) antiBanHammer = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Message", Value = antimessage, Callback = function(v) antimessage = v saveConfig() end })
__protectTab:Toggle({ Title = "No Kill (obby)", Value = nokEnabled, Callback = function(v) nokEnabled = v TNOK(v and "true" or "false") saveConfig() end })

spawn(function()
    local UI = Instance.new("ScreenGui")
    CommandBar = UI
    local dairyQueenBalls = Instance.new("TextButton") local holyshidt11 = Instance.new("TextBox")
    UI.Name = "&!)!@@#$(~(UI" UI.Parent = game.CoreGui UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling UI.ResetOnSpawn = false
    dairyQueenBalls.Name = "dairyQueenBalls" dairyQueenBalls.Parent = UI dairyQueenBalls.AnchorPoint = Vector2.new(1,1) dairyQueenBalls.BackgroundColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.BackgroundTransparency = 1.000 dairyQueenBalls.BorderSizePixel = 0 dairyQueenBalls.Position = UDim2.new(1,0,1,0) dairyQueenBalls.Size = UDim2.new(0,61,0,61) dairyQueenBalls.Font = Enum.Font.Roboto dairyQueenBalls.Text = "]" dairyQueenBalls.TextColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.TextSize = 75.000 dairyQueenBalls.TextStrokeTransparency = 0.000 dairyQueenBalls.TextWrapped = true
    holyshidt11.Name = "holyshidt11" holyshidt11.Parent = dairyQueenBalls holyshidt11.AnchorPoint = Vector2.new(1,0) holyshidt11.BackgroundColor3 = Color3.fromRGB(255,255,255) holyshidt11.BackgroundTransparency = 0.750 holyshidt11.BorderSizePixel = 5 holyshidt11.BorderMode = "Inset" holyshidt11.Size = UDim2.new(0,0,0,61) holyshidt11.Visible = false holyshidt11.Font = Enum.Font.Code holyshidt11.Text = "" holyshidt11.AutomaticSize = "X" holyshidt11.TextColor3 = Color3.fromRGB(255,255,255) holyshidt11.TextSize = 50.000 holyshidt11.TextStrokeTransparency = 0.000 holyshidt11.TextXAlignment = Enum.TextXAlignment.Right
    local isCmdBarOpen = false
    function openUI() isCmdBarOpen = true holyshidt11:CaptureFocus() holyshidt11.Visible = true game:GetService("TweenService"):Create(holyshidt11, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0,200,0,61)}):Play() game:GetService("RunService").RenderStepped:Wait() holyshidt11.Text = "" end
    local Connections = {}
    Connections[tostring(math.random(-9999999,9999999))] = game:GetService("UserInputService").InputBegan:Connect(function(key,gp) if not gp then if key.KeyCode == Enum.KeyCode.RightBracket then openUI() end end end)
    Connections[tostring(math.random(-9999999,9999999))] = dairyQueenBalls.MouseButton1Click:Connect(openUI)
    Connections[tostring(math.random(-9999999,9999999))] = holyshidt11.FocusLost:Connect(function(shouldSend)
        spawn(function() isCmdBarOpen = false game:GetService("TweenService"):Create(holyshidt11, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0,0,0,61)}):Play() holyshidt11.Text = "" end)
        if shouldSend then
            local text = holyshidt11.Text
            if text ~= "" then executeCommand(text) end
        end
    end)
end)

addcommand("bl", "Add player to blacklist & kick if online", function(args)
    local target = args[1] if not target then return end
    local reason = args[2] and table.concat(args, " ", 2) or nil
    for _, tgt in pairs(GetPlayers(target)) do
        if tgt.Name == ownerName or isWhitelisted(tgt) then return end
        if not table.find(blacklisted, tgt.Name) then
            local line = reason and (tgt.Name .. "|" .. reason) or tgt.Name
            appendfile("Blacklisted.txt", line .. "\n")
            table.insert(blacklisted, tgt.Name)
            if reason then blacklistReasons[tgt.Name] = reason end
        end
        executeCommand("kick " .. tgt.Name)
    end
end)
addcommand("ban", "", function(args) commands["bl"](args) end)
addcommand("unban", "Remove player from blacklist", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        for i = #blacklisted, 1, -1 do if blacklisted[i] == tgt.Name then table.remove(blacklisted, i) end end
        blacklistReasons[tgt.Name] = nil
        local content = readfile("Blacklisted.txt")
        local newContent = content:gsub(tgt.Name .. "[^\n]*\n", "")
        writefile("Blacklisted.txt", newContent)
        WindUI:Notify({Title="kohlsify", Content=tgt.Name.." unbanned", Duration=3})
    end
end)
addcommand("unbl", "", function(args) commands["unban"](args) end)
addcommand("fpunish", "Fake punish a player", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end tchat("unff "..tgt.Name) tchat("freeze "..tgt.Name) tchat("invisible "..tgt.Name) end end)
addcommand("spam", "Spam a message", function(args) local msg = table.concat(args, " ") if msg == "" then return end if spamConnection then spamConnection:Disconnect() end spamConnection = game:GetService("RunService").Heartbeat:Connect(function() tchat(msg) end) WindUI:Notify({Title="kohlsify", Content="Spam started: "..msg, Duration=2}) end)
addcommand("unspam", "Stop spamming", function() if spamConnection then spamConnection:Disconnect() spamConnection = nil end WindUI:Notify({Title="kohlsify", Content="Spam stopped", Duration=2}) end)
addcommand("fixfilter", "Fix chat filter", function() commands["bypassmessage"]({"filtercheck"}) end)
addcommand("bypassmessage", "Bypass chat filter", function(args) local msg = table.concat(args, " ") if msg == "" then return end local a = {} for letter in msg:gmatch(".") do if letter ~= "\r" and letter ~= "\n" then table.insert(a, letter) end end for b, c in ipairs(a) do local e = string.rep("  ", 2*(b-1)) tchat("h the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"..e..c) end end)
addcommand("cage", "Cage a player", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            _G.cagecheck = false tchat("gear me 000000000000000000000000000000000000000000082357101") repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice') plr.Backpack.PortableJustice.Parent = plr.Character repeat task.wait() until game.Workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick') local oldpos = plr.Character.HumanoidRootPart.CFrame plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame tchat('unff '..tgt.Name) repeat coroutine.wrap(function() game.Workspace[plr.Name].PortableJustice.MouseClick:FireServer(game.Workspace[tgt.Name]) end)() task.wait() until tgt.Character:FindFirstChild('DisableBackpack') pcall(function() game.Workspace[plr.Name]["PortableJustice"]:Destroy() end) _G.cagecheck = false plr.Character.HumanoidRootPart.CFrame = oldpos antifreeze = prev
        end)
    end
end)
addcommand("loopcage", "Loop cage a player", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end if cageLoops[tgt.Name] then return end cageLoops[tgt.Name] = true spawn(function() while cageLoops[tgt.Name] do commands["cage"]({tgt.Name}) tgt.CharacterAdded:Wait() wait(0.5) end end) end end)
addcommand("unloopcage", "Stop loop caging", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do cageLoops[tgt.Name] = nil end end)

addcommand("gearbl", "Gear ban a player", function(args)
    local xplayer = args[1] if not xplayer then return end
    local xplr = GetPlayers(xplayer)[1]
    if not xplr then return end
    tchat("gear me 000000000000000000000000000000000000000000082357101")
    tchat("unff " .. xplr.Name)
    tchat("speed " .. xplr.Name .. " 0")
    tchat("unfly " .. xplr.Name)
    local pos = plr.Character.HumanoidRootPart.CFrame
    plr.Character.HumanoidRootPart.CFrame = xplr.Character.HumanoidRootPart.CFrame
    local cappy = xplr.Character
    repeat task.wait() until plr.Backpack:FindFirstChild("PortableJustice")
    local tool = plr.Backpack:FindFirstChild("PortableJustice")
    tool.Parent = plr.Character
    tool.MouseClick:FireServer(cappy)
    task.wait(1)
    tchat("reload " .. xplr.Name)
    tchat("h \n\n\n\n\n " .. xplr.DisplayName .. " got gearbanned! \n\n\n\n\n")
    tool:Destroy()
    plr.Character.HumanoidRootPart.CFrame = pos
    tchat("ungear me")
    pcall(function() plr.PlayerGui:FindFirstChild("HelpGui"):Destroy() end)
end)

addcommand("ungearbl", "Remove gear ban", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            tchat("ungear me") tchat("tp " .. tgt.Name .. " me") tchat("speed " .. tgt.Name .. " 0") task.wait(0.5) tchat("gear me 0000000000000000000000000000000000000000000071037101") repeat task.wait() until plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") local ungear = plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") task.wait() ungear.Parent = plr.Character task.wait(0.5) plr.Character.DaggerOfShatteredDimensions.Remote:FireServer(Enum.KeyCode.Q) task.wait(0.5) tchat("ungear me") tchat("speed " .. tgt.Name .. " 16") antifreeze = prev
        end)
    end
end)

addcommand("fixvel", "Fix velocity of map parts", function() pcall(function() local Workspace_Folder = workspace.Terrain["GameFolder"].Workspace local Admin_Folder = workspace.Terrain["GameFolder"].Admin Workspace_Folder.Baseplate.Velocity = Vector3.new(0,0,0) Workspace_Folder.Baseplate.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Workspace_Folder["Basic House"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Admin Dividers"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby Box"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Building Bricks"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end Admin_Folder.Regen.Velocity = Vector3.new(0,0,0) Admin_Folder.Regen.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Admin_Folder.Pads:GetDescendants()) do if v.Name == "Head" then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end end end) WindUI:Notify({Title="kohlsify", Content="Velocity fixed!", Duration=2}) end)
addcommand("regen", "Click regen button", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) WindUI:Notify({Title="kohlsify", Content="Regen clicked", Duration=2}) end end)
addcommand("fixregen", "Move regen to spawn", function()
    local regen = Admin and Admin:FindFirstChild("Regen")
    if regen then
        regen.CFrame = CFrame.new(-7.16500044, 5.42999268, 91.7430038) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90))
        WindUI:Notify({Title="kohlsify", Content="Regen moved to default position", Duration=2})
    end
end)
addcommand("tptoregen", "Teleport to regen", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character.HumanoidRootPart.CFrame = regen.CFrame * CFrame.new(0, 2.5, 0) end end)
addcommand("rmoveregen", "Remove regen", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen.CFrame.Y < 500 then spawn(function() local chr = plr.Character if not chr or not chr:FindFirstChild("Humanoid") then return end local cf = chr.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() chr.Humanoid:ChangeState(11) cf.CFrame = regen.CFrame * CFrame.new(-(regen.Size.X/2)-(chr.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.3) looping = false tchat("trip me") wait(0.2) tchat("respawn me") end) else WindUI:Notify({Title="kohlsify", Content="Regen already moved or not found", Duration=2}) end end)
addcommand("deletetool", "Get delete tool", function() local btool = Instance.new("Tool", plr.Backpack) local SelectionBox = Instance.new("SelectionBox", workspace) local hammer = Instance.new("Part") hammer.Parent = btool hammer.Name = "Handle" hammer.CanCollide = false hammer.Anchored = false SelectionBox.Name = "oof" SelectionBox.LineThickness = 0.05 SelectionBox.Adornee = nil SelectionBox.Color3 = Color3.fromRGB(0,0,255) SelectionBox.Visible = false btool.Name = "Delete Tool" btool.RequiresHandle = false local IsEquipped = false local Mouse = plr:GetMouse() btool.Equipped:Connect(function() IsEquipped = true SelectionBox.Visible = true SelectionBox.Adornee = nil end) btool.Unequipped:Connect(function() IsEquipped = false SelectionBox.Visible = false SelectionBox.Adornee = nil end) btool.Activated:Connect(function() if IsEquipped then btool.Parent = game.Chat local ex = Instance.new("Explosion") ex.BlastRadius = 0 ex.Position = Mouse.Target.Position ex.Parent = workspace local prevcfarchive = plr.Character.HumanoidRootPart.CFrame local target = Mouse.Target local function movepart() local cf = plr.Character.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() plr.Character.Humanoid:ChangeState(11) cf.CFrame = target.CFrame * CFrame.new(-(target.Size.X/2)-(plr.Character.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.25) looping = false end movepart() repeat wait() until plr.Character.Torso:FindFirstChild("Weld") tchat("skydive me") wait(0.1) tchat("respawn me") wait(0.25) game.Chat["Delete Tool"].Parent = plr.Backpack plr.Character.HumanoidRootPart.CFrame = prevcfarchive spawn(function() wait(3) if game.Chat:FindFirstChild("Delete Tool") then game.Chat["Delete Tool"]:Destroy() end end) end end) WindUI:Notify({Title="kohlsify", Content="Delete Tool added to backpack", Duration=2}) end)

local function transferHotPotato(player)
    for _=1,3 do
        tchat("gear me 000000000000000000000000000000000000000000025741198")
        repeat task.wait() until plr.Backpack:FindFirstChild("HotPotato")
        local potato = plr.Backpack.HotPotato
        potato.Parent = plr.Character
        potato:Activate()
        spawn(function()
            while potato.Parent == plr.Character do
                task.wait()
                pcall(function()
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 0)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 1)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 0)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 1)
                end)
            end
        end)
    end
end

addcommand("kick", "Hot potato kick", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            tchat("unff me") tchat("ff me") tchat("ff " .. tgt.Name) tchat("blind " .. tgt.Name) tchat("size " .. tgt.Name .. " nan")
            task.wait(0.2)
            tchat("freeze " .. tgt.Name)
            transferHotPotato(tgt)
            task.wait(1.5)
            tchat("reset " .. tgt.Name)
            task.wait(0.6)
            tchat("flashify " .. tgt.Name) tchat("ff " .. tgt.Name) tchat("god " .. tgt.Name)
            tchat("name " .. tgt.Name .. " \n\n\n\n\n\n\n\n\n\n[kohlsify]\nKicked by hot potato, " .. plr.DisplayName .. "\n" .. tgt.DisplayName)
            tchat("invisible " .. tgt.Name)
            recentlyKicked[tgt.Name] = true
            antifreeze = prev
        end)
    end
end)

addcommand("kid", "Make a player small with a candy", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function() tchat("size " .. tgt.Name .. " 0.5") tchat("gear " .. tgt.Name .. " candy") tchat("name " .. tgt.Name .. " Good Kid") antifreeze = prev end)
    end
end)

addcommand("clonef3x", "Clone your Building Tools", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="kohlsify", Content="You no have F3X, maybe you need to wait?", Duration=3})
        return
    end
    tchat("gear me cloner")
    repeat task.wait() until plr.Backpack:FindFirstChild("Gear Cloner")
    local cloner = plr.Backpack["Gear Cloner"]
    cloner.Parent = plr.Character
    task.wait(0.5)
    workspace.nowhudhejeir["Gear Cloner"].GearRequest:FireServer(plr.Backpack["Building Tools"])
    task.wait(0.5)
    pcall(function() plr.PlayerGui:FindFirstChild("GearCloneGUI"):Destroy() end)
    WindUI:Notify({Title="kohlsify", Content="Cloned Building Tools", Duration=2})
end)
addcommand("cf3x", "", function(args) commands["clonef3x"](args) end)

addcommand("removeobby", "Remove obby parts", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="kohlsify", Content="You no have F3X, maybe you need to wait?", Duration=3})
        return
    end
    local tool = plr.Backpack:FindFirstChild("Building Tools")
    tool.Parent = plr.Character
    task.wait(0.5)
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    local parts = {
        workspace.Tabby.Admin_House.Obby.Jump1,
        workspace.Tabby.Admin_House.Obby.Jump2,
        workspace.Tabby.Admin_House.Obby.Jump3,
        workspace.Tabby.Admin_House.Obby.Jump4,
        workspace.Tabby.Admin_House.Obby.Jump5,
        workspace.Tabby.Admin_House.Obby.Jump6,
        workspace.Tabby.Admin_House.Obby.Jump7,
        workspace.Tabby.Admin_House.Obby.Jump8,
    }
    for _, part in ipairs(parts) do
        pcall(function() api:InvokeServer(table.unpack({[1]="Remove", [2]={part}})) end)
    end
    task.wait(0.5)
    local anyLeft = false
    for _, part in ipairs(parts) do
        if part and part.Parent then anyLeft = true break end
    end
    if anyLeft then
        WindUI:Notify({Title="kohlsify", Content="error in removing obby (no fix)", Duration=3})
    else
        WindUI:Notify({Title="kohlsify", Content="obby (killbricks) removed!", Duration=3})
    end
end)
addcommand("deleteobby", "", function(args) commands["removeobby"](args) end)
addcommand("rmobby", "", function(args) commands["removeobby"](args) end)
addcommand("dobby", "", function(args) commands["removeobby"](args) end)

addcommand("unlockworkspace", "Unlock all parts in workspace", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Locked = false
        end
    end
    WindUI:Notify({Title="kohlsify", Content="Workspace unlocked", Duration=2})
end)
addcommand("unlockws", "", function(args) commands["unlockworkspace"](args) end)

addcommand("nocam", "Break camera (shiftlock)", function()
    tchat("gear me 000000000000000000000000000000000000000004842207161")
    repeat task.wait() until plr.Backpack:FindFirstChild("AR")
    local cambrek = plr.Backpack:FindFirstChild("AR")
    cambrek.Parent = plr.Character
    task.wait(0.2)
    cambrek:Activate()
    WindUI:Notify({Title="kohlsify", Content="The camera is now broken into shiftlock - you won't see the effect until you rejoin.", Duration=5})
end)

addcommand("fcam", "Break a player's camera", function(args)
    local target = args[1] if not target then return end
    local cplr = GetPlayers(target)[1]
    if not cplr then return end
    if not firetouchinterest then WindUI:Notify({Title="kohlsify", Content="firetouchinterest not supported", Duration=3}) return end
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
    local instancechina = Instance.new("Part", plr.Character)
    instancechina.Anchored = true
    instancechina.Size = Vector3.new(10,1,10)
    instancechina.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    tchat("gear me 000000000000000000000000000000000000000000094794847")
    repeat task.wait() until plr.Backpack:FindFirstChild("VampireVanquisher")
    local VampireVanquisher = plr.Backpack:FindFirstChild("VampireVanquisher")
    VampireVanquisher.Parent = plr.Character
    repeat task.wait() until not plr.Character.VampireVanquisher:FindFirstChild("Coffin")
    repeat
        task.wait()
        firetouchinterest(VampireVanquisher.Handle, cplr.Character.Head, 0)
        firetouchinterest(VampireVanquisher.Handle, cplr.Character.Head, 1)
    until plr:DistanceFromCharacter(cplr.Character.Head.Position) < 10
    tchat("respawn me")
end)

local function FixCam()
    task.spawn(function()
        local Player = game.Players.LocalPlayer
        local PlayerService = game:GetService("Players")
        local lp = PlayerService.LocalPlayer
        local UIS = game:GetService("UserInputService")
        local CAS = game:GetService("ContextActionService")
        local RUS = game:GetService("RunService")
        CAS:UnbindAction("ShoulderCameraSprint")
        RUS:UnbindFromRenderStep("ShoulderCameraUpdate")
        CAS:UnbindAction("ShoulderCameraZoom")
        while true do
            task.wait()
            repeat game:GetService("RunService").Heartbeat:Wait() until game.Workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable
            RUS:UnbindFromRenderStep("ShoulderCameraUpdate")
            CAS:UnbindAction("ShoulderCameraZoom")
            CAS:UnbindAction("ShoulderCameraSprint")
            local WEPSYS = game:GetService("ReplicatedStorage"):FindFirstChild("WeaponsSystem")
            if not WEPSYS then return end
            for i,v in pairs(WEPSYS:GetDescendants()) do
                if v:IsA("Script") then v.Disabled = true end
                v:Destroy()
            end
            local CWS = lp.PlayerGui:FindFirstChild("ClientWeaponsScript")
            local WSG = lp.PlayerGui:FindFirstChild("WeaponsSystemGui")
            local CWS_2 = lp.PlayerScripts:FindFirstChild("ClientWeaponsScript")
            local Camera = game:GetService("Workspace"):FindFirstChild("Camera")
            if CWS then CWS.Disabled = true CWS:Destroy() end
            if WSG then WSG:Destroy() end
            if CWS_2 then CWS_2.Disabled = true CWS_2:Destroy() end
            game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
            PlayerService.LocalPlayer.CameraMaxZoomDistance = 400
            PlayerService.LocalPlayer.CameraMinZoomDistance = 0.5
            Camera.FieldOfView = 70
            game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            game.Workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
            lp.Character.Humanoid.AutoRotate = true
        end
    end)
end

addcommand("fixcam", "Fix your camera", function() FixCam() end)

addcommand("slag", "Server lag (2 stones)", function()
    tchat("ungear me")
    task.wait(0.5)
    tchat("gear me 000000000000000000000000000000000000000000059190534")
    tchat("gear me 000000000000000000000000000000000000000000059190534")
    repeat task.wait() until #plr.Backpack:GetChildren() >= 2
    local stoneTool1 = plr.Backpack:GetChildren()[1]
    local stoneTool2 = plr.Backpack:GetChildren()[2]
    task.wait()
    stoneTool1.Parent = plr.Character
    stoneTool2.Parent = plr.Character
    task.wait()
    spawn(function() stoneTool1.ServerControl:InvokeServer("KeyPress", {["Key"] = "x", ["Down"] = true}) end)
    spawn(function() stoneTool2.ServerControl:InvokeServer("KeyPress", {["Key"] = "x", ["Down"] = true}) end)
end)
addcommand("serverlag", "Server lag (2 stones)", function() commands["slag"]({}) end)

addcommand("r15", "Switch to R15", function()
    tchat("!experiment adaptiver6 on")
    task.wait(2)
    tchat("unchar me")
end)
addcommand("r6", "Switch to R6", function()
    tchat("!experiment adaptiver6 off")
end)

addcommand("ping", "Show ping", function()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    chat("Ping is " .. ping .. "ms.")
end)

addcommand("jerk", "You know", function() local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") local backpack = plr.Backpack if not humanoid or not backpack then return end local tool = Instance.new("Tool") tool.Name = "Jerk Off" tool.RequiresHandle = false tool.Parent = backpack local jorkin = false local track = nil local function stopTomfoolery() jorkin = false if track then track:Stop() track = nil end end tool.Equipped:Connect(function() jorkin = true end) tool.Unequipped:Connect(stopTomfoolery) humanoid.Died:Connect(stopTomfoolery) spawn(function() while task.wait() do if not jorkin then continue end local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15 if not track then local anim = Instance.new("Animation") anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653" track = humanoid:LoadAnimation(anim) end track:Play() track:AdjustSpeed(isR15 and 0.7 or 0.65) track.TimePosition = 0.6 task.wait(0.1) while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end if track then track:Stop() track = nil end end end) end)
addcommand("bang", "Bang animation on a player", function(args) local target = args[1] local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") if not humanoid then return end if bangAnim and bang then bang:Stop() bangAnim:Destroy() end bangAnim = Instance.new("Animation") bangAnim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674" or "rbxassetid://148840371" bang = humanoid:LoadAnimation(bangAnim) bang:Play(0.1,1,1) bang:AdjustSpeed(3) bangDied = humanoid.Died:Connect(function() bang:Stop() bangAnim:Destroy() bangDied:Disconnect() if bangLoop then bangLoop:Disconnect() end end) if target then local players = GetPlayers(target) for _, v in ipairs(players) do local other = v.Character if other and other:FindFirstChild("Torso") then local otherRoot = other.Torso bangLoop = game:GetService("RunService").Stepped:Connect(function() pcall(function() plr.Character.HumanoidRootPart.CFrame = otherRoot.CFrame * CFrame.new(0, 0, 1.1) end) end) break end end end end)
addcommand("unbang", "Stop bang animation", function() if bangDied then bangDied:Disconnect() end if bang then bang:Stop() bang = nil end if bangAnim then bangAnim:Destroy() bangAnim = nil end if bangLoop then bangLoop:Disconnect() bangLoop = nil end end)

addcommand("rejoin", "Rejoin the server", function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr) end)
addcommand("rj", "", function() commands["rejoin"]({}) end)

addcommand("serverhop", "Hop to another server", function()
    local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") end)
    if not success then WindUI:Notify({Title="kohlsify", Content="Failed to fetch servers", Duration=3}) return end
    local servers = HS:JSONDecode(result)
    local goodServers = {}
    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers then table.insert(goodServers, server) end
    end
    if #goodServers > 0 then
        local targetServer = goodServers[math.random(1, #goodServers)]
        TS:TeleportToPlaceInstance(game.PlaceId, targetServer.id, plr)
    else
        WindUI:Notify({Title="kohlsify", Content="No available servers", Duration=3})
    end
end)
addcommand("shop", "", function() commands["serverhop"]({}) end)

if game.PlaceId ~= 14747334292 then
    game.StarterGui:SetCore("SendNotification", {
        Title = "kohlsify";
        Text = "You are not in Kohls Admin House X";
        Duration = 10;
        Button1 = "Join";
        Button2 = "Ignore";
        Callback = function(choice)
            if choice == "Join" then
                commands["serverhop"]({})
            end
        end;
    })
    return
end
