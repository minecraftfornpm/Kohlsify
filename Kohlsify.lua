--[[
    †Køhlsîfy - Open source script
    Only for Kohls admin house X (KAH X/14747334292)
    Made by nowhud (nowhudhejeir in roblox)
    10% code it kohlslite, plsnoleak (thanks "Ultra", "Ts2021")
]]

if getgenv().KohlsifyLoaded then return end
getgenv().KohlsifyLoaded = true

if game.PlaceId ~= 14747334292 then
    game.StarterGui:SetCore("SendNotification", {
        Title = "†Køhlsîfy";
        Text = "You are not in Kohls Admin House X";
        Duration = 10;
        Button1 = "Join";
        Button2 = "Ignore";
        Callback = function(choice)
            if choice == "Join" then
                local TS = game:GetService("TeleportService")
                local HS = game:GetService("HttpService")
                pcall(function()
                    local servers = HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
                    local good = {}
                    for _, s in ipairs(servers.data) do
                        if s.playing < s.maxPlayers then table.insert(good, s) end
                    end
                    if #good > 0 then
                        TS:TeleportToPlaceInstance(game.PlaceId, good[math.random(1, #good)].id, game.Players.LocalPlayer)
                    end
                end)
            end
        end;
    })
    return
end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local prefix = "†"
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local ChatService = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
local __sayRequest = ChatService:WaitForChild("SayMessageRequest")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "†Køhlsîfy",
    Size = UDim2.fromOffset(340, 740),
    Theme = "Crimson",
    AutoShow = true,
})

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
        WindUI:Notify({Title = "†Køhlsîfy", Content = "Command not found: " .. cmd, Duration = 3})
    end
end

function GetPlayers(target)
    local all = Players:GetPlayers()
    target = tostring(target or ""):lower()
    local result = {}
    local function filterWhitelist(list)
        local filtered = {}
        for _, p in ipairs(list) do
            if p ~= plr and not (p.Name == ownerName or isWhitelisted(p)) then
                table.insert(filtered, p)
            end
        end
        return filtered
    end
    if target == "all" then
        result = filterWhitelist(all)
    elseif target == "random" then
        local others = filterWhitelist(all)
        if #others == 0 then return {} end
        result = {others[math.random(1, #others)]}
    elseif target == "others" then
        result = filterWhitelist(all)
    elseif target == "me" then
        result = {plr}
    else
        for _, p in ipairs(all) do
            if p.Name:lower():find(target, 1, true) or p.DisplayName:lower():find(target, 1, true) then
                if not (p == plr and target ~= "me") and not (p.Name == ownerName or isWhitelisted(p)) then
                    table.insert(result, p)
                end
            end
        end
    end
    return result
end

local blacklisted = {}
local blacklistReasons = {}
local recentlyKicked = {}
local whitelist = {"nowhudhejeir", "EgorYa900", "EgorYa900Alt", "PaulTheKinggg", "1love2dadw1"}
local ownerName = "nowhudhejeir"

if not isfile or not readfile or not writefile then
    isfile = function() return false end
    readfile = function() return "" end
    writefile = function() end
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
                if reason and reason ~= "" then blacklistReasons[name] = reason end
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

local antis = {
    antipunish = false,
    antistun = false,
    antisetgrav = false,
    antirocket = false,
    antiseizure = false,
    antikill = false,
    antimessage = false,
    antiskydive = false,
    antifly = false,
    antivoid = false,
    antifreeze = false,
    antibanhammer = false,
    antigearban = false,
    antiblind = false,
}

local configFolder = "kohlsify"
local configFile = configFolder .. "/config.json"
if not isfolder(configFolder) then makefolder(configFolder) end

local function saveConfig()
    local data = {
        antis = antis,
        autoGod = autoGod,
        autoForceField = autoForceField,
        autoName = autoName,
        permEnabled = permEnabled,
        showCommands = showCommands,
    }
    writefile(configFile, HS:JSONEncode(data))
end

local function loadConfig()
    if isfile(configFile) then
        local success, data = pcall(function() return HS:JSONDecode(readfile(configFile)) end)
        if success and data then
            if data.antis then for k, v in pairs(data.antis) do antis[k] = v end end
            autoGod = data.autoGod or false
            autoForceField = data.autoForceField or false
            autoName = data.autoName or false
            permEnabled = data.permEnabled or false
            showCommands = data.showCommands or false
        end
    end
end
loadConfig()

local permEnabled = false
local permCoroutine = nil

local function isWhitelisted(player)
    if plr.Name == ownerName then return false end
    return table.find(whitelist, player.Name) ~= nil
end

local function hasRealAdmin() return Pads and Pads:FindFirstChild(plr.Name .. "'s admin") ~= nil end
local function getFreePad() return Pads and Pads:FindFirstChild("Touch to get admin") end
local function claimPad(pad)
    if not pad or not firetouchinterest then return false end
    local chr = plr.Character
    if not chr or not chr:FindFirstChild("Head") then return false end
    local spr = chr.Head
    local a = pad:FindFirstChild("Head")
    if not a then return false end
    firetouchinterest(a, spr, 1) firetouchinterest(a, spr, 0) firetouchinterest(a, spr, 1) task.wait(0.05) firetouchinterest(a, spr, 0)
    return true
end

local function permLoop()
    if permCoroutine then task.cancel(permCoroutine) end
    permCoroutine = task.spawn(function()
        while permEnabled do
            pcall(function()
                if not hasRealAdmin() then
                    local free = getFreePad()
                    if free then
                        claimPad(free)
                    else
                        if Admin and Admin:FindFirstChild("Regen") and Admin.Regen:FindFirstChild("ClickDetector") then
                            fireclickdetector(Admin.Regen.ClickDetector)
                            task.wait(0.3)
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local autoGod = false
local autoForceField = false
local autoName = false

local function sendName()
    if not autoName then return end
    local role = "User"
    if plr.Name == ownerName then
        role = "Owner"
    elseif isWhitelisted(plr) then
        role = "Helper"
    end
    tchat("name me [†Køhlsîfy]\nRank:" .. role .. "\n" .. plr.DisplayName)
end

local function checkNameModel()
    if not autoName then return end
    local chr = plr.Character
    if not chr then return end
    local container = workspace:FindFirstChild(plr.Name)
    local model = container and container:FindFirstChild("[†Køhlsîfy]\nRank:" .. (plr.Name == ownerName and "Owner" or (isWhitelisted(plr) and "Helper" or "User")) .. "\n" .. plr.DisplayName)
    if not model then
        sendName()
    end
end

plr.CharacterAdded:Connect(function(chr)
    if autoGod or autoForceField then
        spawn(function()
            while autoGod or autoForceField do
                if autoGod then
                    local hum = chr:FindFirstChild("Humanoid")
                    if hum and hum.MaxHealth ~= math.huge then
                        tchat("god me")
                    end
                end
                if autoForceField then
                    if not chr:FindFirstChild("ForceField") then
                        tchat("ff me")
                    end
                end
                task.wait(1)
            end
        end)
    end
    if autoName then
        sendName()
    end
    local hum = chr:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(old, new)
        if antis.antistun and new == Enum.HumanoidStateType.PlatformStanding then
            hum.PlatformStand = false
            tchat("unstun me")
        end
        if antis.antifreeze and hum.WalkSpeed == 0 then
            tchat("thaw me")
        end
    end)
    chr.ChildAdded:Connect(function(child)
        if child.Name == "BFRC" then
            pcall(function() child:Destroy() end)
        end
        if antis.antirocket and child.Name == "Rocket" then
            pcall(function() child:Destroy() end)
        end
        if antis.antiseizure and child.Name == "Seizure" then
            child:Destroy()
            tchat("unseizure me")
        end
    end)
end)

spawn(function()
    while true do
        task.wait(2)
        if autoName then checkNameModel() end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if antis.antiblind then
                local blind = plr.PlayerGui:FindFirstChild("EFFECTGUIBLIND")
                if blind then blind:Destroy() end
                local confirm = plr.PlayerGui:FindFirstChild("ConfirmationPrompt")
                if confirm then confirm:Destroy() end
            end

            if antis.antisetgrav then
                local chr = plr.Character
                if chr then
                    for _, v in ipairs(chr:GetDescendants()) do
                        if v:IsA("BodyForce") or v:IsA("BodyPosition") then
                            v:Destroy()
                            if chr:FindFirstChild("HumanoidRootPart") then
                                chr.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                                chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                            end
                        end
                    end
                end
            end

            if antis.antikill then
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0 then tchat("reset me") end
            end

            if antis.antimessage then
                pcall(function()
                    for _, v in ipairs(plr.PlayerGui:GetDescendants()) do
                        if v.Name == "MessageGUI" or v.Name == "Message" or v.Name == "HintGUI" or v.Name == "Ice" then v:Destroy() end
                    end
                    if Folder then for _, v in ipairs(Folder:GetDescendants()) do if v.Name == "Message" then v:Destroy() end end end
                end)
            end

            if antis.antiskydive then
                local chr = plr.Character
                if chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.Position.Y > 256 then
                    chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                    chr.HumanoidRootPart.Velocity = Vector3.new(chr.HumanoidRootPart.Velocity.X, 0, chr.HumanoidRootPart.Velocity.Z)
                end
            end

            if antis.antifly then
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") then
                    local state = chr.Humanoid:GetState()
                    if state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Flying then
                        tchat("unfly me")
                        tchat("clip me")
                        if chr:FindFirstChild("Torso") then chr.Torso.Anchored = false end
                        chr.Humanoid.PlatformStand = false
                    end
                end
            end

            if antis.antivoid then
                local chr = plr.Character
                if chr and chr:FindFirstChild("HumanoidRootPart") then
                    local root = chr.HumanoidRootPart
                    local rayOrigin = root.Position
                    local rayDirection = Vector3.new(0, -1000, 0)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {chr}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    if not rayResult then
                        root.CFrame = CFrame.new(root.Position.X, 5, root.Position.Z)
                        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                    end
                end
            end

            if antis.antifreeze then
                local chr = plr.Character
                if chr then
                    local frozen = chr:FindFirstChild("ice") or chr:FindFirstChild("Frozen") or chr:FindFirstChild("Freeze")
                    if frozen then
                        pcall(function() frozen:Destroy() end)
                        tchat("thaw me")
                    end
                    local hum = chr:FindFirstChild("Humanoid")
                    if hum and hum.WalkSpeed == 0 then
                        tchat("thaw me")
                    end
                end
            end

            if antis.antibanhammer then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= plr then
                        local found = false
                        if p.Backpack and p.Backpack:FindFirstChild("BanHammer") then
                            p.Backpack.BanHammer:Destroy()
                            found = true
                        end
                        if p.Character and p.Character:FindFirstChild("BanHammer") then
                            p.Character.BanHammer:Destroy()
                            found = true
                        end
                        if workspace:FindFirstChild(p.Name) then
                            local wsModel = workspace[p.Name]
                            if wsModel:FindFirstChild("BanHammer") then
                                wsModel.BanHammer:Destroy()
                                found = true
                            end
                        end
                        if found then
                            tchat("reset " .. p.Name)
                        end
                    end
                end
            end

            if antis.antigearban then
                pcall(function()
                    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
                end)
                if plr.Character then
                    local db = plr.Character:FindFirstChild("DisableBackpack")
                    if db then db:Destroy() end
                end
            end
        end)
    end
end)

game:GetService("Lighting").ChildAdded:Connect(function(child)
    if antis.antipunish and child.Name == plr.Name then
        child.Parent = workspace
        tchat("unpunish me")
    end
end)

local showCommands = false

addcommand("show", "Send commands to chat when using command bar", function()
    showCommands = true
    saveConfig()
    WindUI:Notify({Title="†Køhlsîfy", Content="Command sending enabled", Duration=2})
end)
addcommand("hide", "Stop sending commands to chat", function()
    showCommands = false
    saveConfig()
    WindUI:Notify({Title="†Køhlsîfy", Content="Command sending disabled", Duration=2})
end)

local function handleBannedPlayer(p)
    if table.find(blacklisted, p.Name) and not (p.Name == ownerName or isWhitelisted(p)) then
        local reason = blacklistReasons[p.Name]
        if reason and reason ~= "" then
            chat(p.DisplayName .. " you have been in blacklist, reason: " .. reason)
        else
            chat(p.DisplayName .. " you have been in blacklist")
        end
        task.wait(2)
        tchat("respawn " .. p.Name)
        executeCommand("kick " .. p.Name)
    end
end

addcommand("bl", "Add player to blacklist & kick if online", function(args)
    local target = args[1] if not target then return end
    local reason = nil
    if #args > 1 then
        reason = table.concat(args, " ", 2)
        if reason:match("^%s*$") then reason = nil end
    end
    for _, tgt in pairs(GetPlayers(target)) do
        if tgt.Name == ownerName or isWhitelisted(tgt) then continue end
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
        WindUI:Notify({Title="†Køhlsîfy", Content=tgt.Name.." unbanned", Duration=3})
    end
end)
addcommand("unbl", "", function(args) commands["unban"](args) end)
addcommand("fpunish", "Fake punish a player", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        tchat("unff "..tgt.Name) tchat("freeze "..tgt.Name) tchat("invisible "..tgt.Name)
    end
end)
addcommand("spam", "Spam a message", function(args)
    local msg = table.concat(args, " ") if msg == "" then return end
    if spamConnection then spamConnection:Disconnect() end
    spamConnection = game:GetService("RunService").Heartbeat:Connect(function() tchat(msg) end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Spam started: "..msg, Duration=2})
end)
addcommand("unspam", "Stop spamming", function()
    if spamConnection then spamConnection:Disconnect() spamConnection = nil end
    WindUI:Notify({Title="†Køhlsîfy", Content="Spam stopped", Duration=2})
end)
addcommand("fixfilter", "Fix chat filter", function() commands["bypassmessage"]({"filtercheck"}) end)
addcommand("bypassmessage", "Bypass chat filter (system)", function(args)
    local msg = table.concat(args, " ") if msg == "" then return end
    local a = {} for letter in msg:gmatch(".") do if letter ~= "\r" and letter ~= "\n" then table.insert(a, letter) end end
    for b, c in ipairs(a) do local e = string.rep("  ", 2*(b-1)) tchat("h the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"..e..c) end
end)
addcommand("cage", "Cage a player", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        spawn(function()
            _G.cagecheck = false
            tchat("give me 000000000000000000000000000000000000000000082357101")
            repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice')
            plr.Backpack.PortableJustice.Parent = plr.Character
            repeat task.wait() until workspace:FindFirstChild(plr.Name) and workspace[plr.Name]:FindFirstChild('PortableJustice') and workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick')
            local oldpos = plr.Character.HumanoidRootPart.CFrame
            plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame
            tchat('unff '..tgt.Name)
            repeat
                coroutine.wrap(function() workspace[plr.Name].PortableJustice.MouseClick:FireServer(workspace[tgt.Name]) end)()
                task.wait()
            until tgt.Character:FindFirstChild('DisableBackpack')
            pcall(function() workspace[plr.Name]["PortableJustice"]:Destroy() end)
            _G.cagecheck = false
            plr.Character.HumanoidRootPart.CFrame = oldpos
        end)
    end
end)
addcommand("loopcage", "Loop cage a player", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if cageLoops[tgt.Name] then return end
        cageLoops[tgt.Name] = true
        spawn(function()
            while cageLoops[tgt.Name] do
                commands["cage"]({tgt.Name})
                tgt.CharacterAdded:Wait()
                wait(0.5)
            end
        end)
    end
end)
addcommand("unloopcage", "Stop loop caging", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do cageLoops[tgt.Name] = nil end
end)

addcommand("gearbl", "Gear ban a player", function(args)
    local xplayer = args[1] if not xplayer then return end
    local xplr = GetPlayers(xplayer)[1]
    if not xplr then return end
    tchat("give me 000000000000000000000000000000000000000000082357101")
    tchat("unff " .. xplr.Name)
    tchat("speed " .. xplr.Name .. " 0")
    tchat("unfly " .. xplr.Name)
    task.wait(0.5)
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
addcommand("gearban", "", function(args) commands["gearbl"](args) end)
addcommand("gearblacklist", "", function(args) commands["gearbl"](args) end)

addcommand("ungearbl", "Remove gear ban", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        spawn(function()
            tchat("ungear me") tchat("tp " .. tgt.Name .. " me") tchat("speed " .. tgt.Name .. " 0")
            task.wait(0.5)
            tchat("give me 0000000000000000000000000000000000000000000071037101")
            repeat task.wait() until plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions")
            local ungear = plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions")
            task.wait() ungear.Parent = plr.Character
            task.wait(0.5)
            plr.Character.DaggerOfShatteredDimensions.Remote:FireServer(Enum.KeyCode.Q)
            task.wait(0.5)
            tchat("ungear me") tchat("speed " .. tgt.Name .. " 16")
        end)
    end
end)

addcommand("fixvel", "Fix velocity of map parts", function()
    pcall(function()
        local Workspace_Folder = workspace.Terrain["_Game"].Workspace
        local Admin_Folder = workspace.Terrain["_Game"].Admin
        Workspace_Folder.Baseplate.Velocity = Vector3.new(0,0,0) Workspace_Folder.Baseplate.RotVelocity = Vector3.new(0,0,0)
        for _, v in ipairs(Workspace_Folder["Basic House"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
        for _, v in ipairs(Workspace_Folder["Obby"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
        for _, v in ipairs(Workspace_Folder["Admin Dividers"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
        for _, v in ipairs(Workspace_Folder["Obby Box"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
        for _, v in ipairs(Workspace_Folder["Building Bricks"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end
        Admin_Folder.Regen.Velocity = Vector3.new(0,0,0) Admin_Folder.Regen.RotVelocity = Vector3.new(0,0,0)
        for _, v in ipairs(Admin_Folder.Pads:GetDescendants()) do if v.Name == "Head" then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end end
    end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Velocity fixed!", Duration=2})
end)
addcommand("regen", "Click regen button", function()
    local regen = Admin and Admin:FindFirstChild("Regen")
    if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) WindUI:Notify({Title="†Køhlsîfy", Content="Regen clicked", Duration=2}) end
end)

addcommand("rmoveregen", "Remove regen by moving to workspace and deleting", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X", Duration=3})
        return
    end
    local regen = Admin and Admin:FindFirstChild("Regen")
    if not regen then return end
    regen.Parent = workspace
    task.wait(0.1)
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    pcall(function() api:InvokeServer(table.unpack({[1]="Remove", [2]={regen}})) end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Regen removed", Duration=2})
end)

addcommand("fixregen", "Fix regen by deleting it so server restores default", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X", Duration=3})
        return
    end
    local regen = Admin and Admin:FindFirstChild("Regen")
    if not regen then return end
    regen.Parent = workspace
    task.wait(0.1)
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    pcall(function() api:InvokeServer(table.unpack({[1]="Remove", [2]={workspace.Regen}})) end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Regen fixed (will restore)", Duration=2})
end)

addcommand("deletetool", "Get delete tool", function()
    local btool = Instance.new("Tool", plr.Backpack)
    local SelectionBox = Instance.new("SelectionBox", workspace)
    local hammer = Instance.new("Part")
    hammer.Parent = btool hammer.Name = "Handle" hammer.CanCollide = false hammer.Anchored = false
    SelectionBox.Name = "oof" SelectionBox.LineThickness = 0.05 SelectionBox.Adornee = nil SelectionBox.Color3 = Color3.fromRGB(0,0,255) SelectionBox.Visible = false
    btool.Name = "Delete Tool" btool.RequiresHandle = false
    local IsEquipped = false local Mouse = plr:GetMouse()
    btool.Equipped:Connect(function() IsEquipped = true SelectionBox.Visible = true SelectionBox.Adornee = nil end)
    btool.Unequipped:Connect(function() IsEquipped = false SelectionBox.Visible = false SelectionBox.Adornee = nil end)
    btool.Activated:Connect(function()
        if IsEquipped then
            btool.Parent = game.Chat
            local ex = Instance.new("Explosion") ex.BlastRadius = 0 ex.Position = Mouse.Target.Position ex.Parent = workspace
            local prevcfarchive = plr.Character.HumanoidRootPart.CFrame
            local target = Mouse.Target
            local function movepart()
                local cf = plr.Character.HumanoidRootPart local looping = true
                spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() plr.Character.Humanoid:ChangeState(11) cf.CFrame = target.CFrame * CFrame.new(-(target.Size.X/2)-(plr.Character.Torso.Size.X/2),0,0) end) if not looping then break end end end)
                spawn(function() while looping do wait(0.1) tchat("unpunish me") end end)
                wait(0.25) looping = false
            end
            movepart()
            repeat wait() until plr.Character.Torso:FindFirstChild("Weld")
            tchat("skydive me") wait(0.1) tchat("respawn me") wait(0.25)
            game.Chat["Delete Tool"].Parent = plr.Backpack
            plr.Character.HumanoidRootPart.CFrame = prevcfarchive
            spawn(function() wait(3) if game.Chat:FindFirstChild("Delete Tool") then game.Chat["Delete Tool"]:Destroy() end end)
        end
    end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Delete Tool added to backpack", Duration=2})
end)

local function transferHotPotato(player)
    for _ = 1, 3 do
        tchat("give me 000000000000000000000000000000000000000000025741198")
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

addcommand("kick", "Hot potato kick (optional reason)", function(args)
    local target = args[1] if not target then return end
    local reason = nil
    if #args > 1 then
        reason = table.concat(args, " ", 2)
        if reason:match("^%s*$") then reason = nil end
    end
    for _, tgt in pairs(GetPlayers(target)) do
        spawn(function()
            tchat("freeze " .. tgt.Name)
            tchat("size " .. tgt.Name .. " nan")
            task.wait(0.1)
            transferHotPotato(tgt)
            task.wait(2)
            tchat("reset " .. tgt.Name)
            task.wait(0.2)
            local nameMsg
            if reason then
                nameMsg = "[†Køhlsîfy]\nKicked by " .. plr.DisplayName .. ", reason: " .. reason .. "\n" .. tgt.DisplayName
            else
                nameMsg = "[†Køhlsîfy]\nKicked by " .. plr.DisplayName .. "\n" .. tgt.DisplayName
            end
            tchat("name " .. tgt.Name .. " " .. nameMsg)
            recentlyKicked[tgt.Name] = true
        end)
    end
end)

addcommand("kid", "Make a player small with candy", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        spawn(function() tchat("size " .. tgt.Name .. " 0.5") tchat("give " .. tgt.Name .. " candy") tchat("name " .. tgt.Name .. " Good Kid") end)
    end
end)

addcommand("clonef3x", "Clone your Building Tools", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X, maybe you need to wait?", Duration=3})
        return
    end
    tchat("give me 000000000000000000000000000000000000000097161295")
    repeat task.wait() until plr.Backpack:FindFirstChild("Gear Cloner")
    local cloner = plr.Backpack["Gear Cloner"]
    cloner.Parent = plr.Character
    task.wait(0.5)
    workspace.nowhudhejeir["Gear Cloner"].GearRequest:FireServer(plr.Backpack["Building Tools"])
    task.wait(0.5)
    pcall(function() plr.PlayerGui:FindFirstChild("GearCloneGUI"):Destroy() end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Cloned Building Tools", Duration=2})
end)
addcommand("cf3x", "", function(args) commands["clonef3x"](args) end)

addcommand("nok", "Remove all TouchInterests", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("TouchInterest") then
            pcall(function() v:Destroy() end)
        end
    end
    WindUI:Notify({Title="†Køhlsîfy", Content="All TouchInterests removed!", Duration=3})
end)

addcommand("clrall", "Delete everything in workspace", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X", Duration=3})
        return
    end
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    local toRemove = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if (v:IsA("Part") or v:IsA("Sphere") or v:IsA("Cylinder") or v:IsA("Wedge") or v:IsA("CornerWedge") or v:IsA("MeshPart") or v:IsA("Tool")) then
            local isPlayerPart = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and (v:IsDescendantOf(p.Character) or v == p.Character) then
                    isPlayerPart = true
                    break
                end
            end
            if not isPlayerPart then
                table.insert(toRemove, v)
            end
        end
    end
    pcall(function()
        api:InvokeServer(table.unpack({[1] = "Remove", [2] = toRemove}))
    end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Workspace cleared!", Duration=3})
end)
addcommand("clr", "", function(args) commands["clrall"](args) end)

addcommand("fix", "Remove problematic seats and spawns", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X", Duration=3})
        return
    end
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    local toRemove = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Seat") or (v:IsA("BasePart") and v.Name == "Spawn" and v.Position.Y < -50) then
            table.insert(toRemove, v)
        end
    end
    pcall(function() api:InvokeServer(table.unpack({[1]="Remove", [2]=toRemove})) end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Seats and bottom spawns removed", Duration=3})
end)

addcommand("unlockworkspace", "Unlock all parts", function()
    for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = false end end
    WindUI:Notify({Title="†Køhlsîfy", Content="Workspace unlocked", Duration=2})
end)
addcommand("unlockws", "", function(args) commands["unlockworkspace"](args) end)

addcommand("nocam", "Break camera (shiftlock)", function()
    tchat("give me 000000000000000000000000000000000000000004842207161")
    repeat task.wait() until plr.Backpack:FindFirstChild("AR")
    plr.Backpack.AR.Parent = plr.Character
    task.wait(0.2)
    plr.Character.AR:Activate()
    WindUI:Notify({Title="†Køhlsîfy", Content="Camera broken (shiftlock)", Duration=5})
end)

addcommand("fcam", "Break a player's camera", function(args)
    local target = args[1] if not target then return end
    local cplr = GetPlayers(target)[1]
    if not cplr then return end
    if not firetouchinterest then return end
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
    local part = Instance.new("Part", plr.Character)
    part.Anchored = true part.Size = Vector3.new(10,1,10) part.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    tchat("give me 000000000000000000000000000000000000000000094794847")
    repeat task.wait() until plr.Backpack:FindFirstChild("VampireVanquisher")
    local vv = plr.Backpack.VampireVanquisher
    vv.Parent = plr.Character
    repeat task.wait() until not plr.Character.VampireVanquisher:FindFirstChild("Coffin")
    repeat
        task.wait()
        firetouchinterest(vv.Handle, cplr.Character.Head, 0)
        firetouchinterest(vv.Handle, cplr.Character.Head, 1)
    until plr:DistanceFromCharacter(cplr.Character.Head.Position) < 10
    tchat("respawn me")
end)

-- Sorry, this was taken from kohlslite
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
addcommand("fixcam", "Fix camera", function() FixCam() end)

addcommand("slag", "Server lag (2 stones)", function()
    tchat("ungear me")
    task.wait(0.5)
    tchat("give me 000000000000000000000000000000000000000000059190534")
    tchat("give me 000000000000000000000000000000000000000000059190534")
    repeat task.wait() until #plr.Backpack:GetChildren() >= 2
    local tool1 = plr.Backpack:GetChildren()[1]
    local tool2 = plr.Backpack:GetChildren()[2]
    task.wait()
    tool1.Parent = plr.Character
    tool2.Parent = plr.Character
    task.wait()
    spawn(function() tool1.ServerControl:InvokeServer("KeyPress", {["Key"]="x",["Down"]=true}) end)
    spawn(function() tool2.ServerControl:InvokeServer("KeyPress", {["Key"]="x",["Down"]=true}) end)
end)
addcommand("serverlag", "", function(args) commands["slag"](args) end)

addcommand("servercrash", "Crash the server with many blocks", function()
    if not plr.Backpack:FindFirstChild("Building Tools") then
        tchat("f3x")
        task.wait(2)
    end
    if not plr.Backpack:FindFirstChild("Building Tools") then
        WindUI:Notify({Title="†Køhlsîfy", Content="You no have F3X", Duration=3})
        return
    end
    local api = workspace.nowhudhejeir["Building Tools"].SyncAPI.ServerEndpoint
    local pos = plr.Character and plr.Character.HumanoidRootPart and plr.Character.HumanoidRootPart.CFrame or CFrame.new(0, 5, 0)
    spawn(function()
        for i = 1, 100000 do
            pcall(function()
                api:InvokeServer("CreatePart", "Normal", pos, workspace.Tabby.Admin_House)
            end)
            if i % 500 == 0 then task.wait() end
        end
    end)
    WindUI:Notify({Title="†Køhlsîfy", Content="Server crash initiated!", Duration=3})
end)
addcommand("crash", "", function(args) commands["servercrash"](args) end)
addcommand("shutdown", "", function(args) commands["servercrash"](args) end)

addcommand("r15", "Switch to R15", function() tchat("!experiment adaptiver6 on") task.wait(2) tchat("unchar me") end)
addcommand("r6", "Switch to R6", function() tchat("!experiment adaptiver6 off") end)

addcommand("ping", "Show ping in chat", function()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    chat("Ping is " .. ping .. "ms.")
end)

addcommand("jerk", "You know", function()
    local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local tool = Instance.new("Tool") tool.Name = "Jerk Off" tool.RequiresHandle = false tool.Parent = plr.Backpack
    local anim = Instance.new("Animation")
    anim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://698251653" or "rbxassetid://72042024"
    local track = humanoid:LoadAnimation(anim) track:Play() track:AdjustSpeed(0.7) task.wait(0.1) track:Stop()
end)

addcommand("rejoin", "Rejoin server", function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr) end)
addcommand("rj", "", function(args) commands["rejoin"](args) end)
addcommand("serverhop", "Hop server", function()
    local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") end)
    if not success then WindUI:Notify({Title="†Køhlsîfy", Content="Failed to fetch servers", Duration=3}) return end
    local servers = HS:JSONDecode(result)
    local good = {}
    for _, s in ipairs(servers.data) do if s.playing < s.maxPlayers then table.insert(good, s) end end
    if #good > 0 then
        local target = good[math.random(1, #good)]
        TS:TeleportToPlaceInstance(game.PlaceId, target.id, plr)
    else
        WindUI:Notify({Title="†Køhlsîfy", Content="No available servers", Duration=3})
    end
end)
addcommand("shop", "", function(args) commands["serverhop"](args) end)

addcommand("equipall", "Equip all backpack items", function()
    for _, v in ipairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then v.Parent = plr.Character end
    end
    WindUI:Notify({Title="†Køhlsîfy", Content="Equipped all items!", Duration=2})
end)

addcommand("dropall", "Drop all items", function()
    for _, v in ipairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then v.Parent = plr.Character end
    end
    task.wait(0.5)
    for _, v in ipairs(plr.Character:GetChildren()) do
        if v:IsA("Tool") then v.Parent = workspace end
    end
    WindUI:Notify({Title="†Køhlsîfy", Content="Dropped all items!", Duration=2})
end)

addcommand("furry", "Make player furry", function(args)
    local target = args[1] if not target then return end
    local tgt = GetPlayers(target)[1]
    if not tgt then return end
    tchat("char " .. tgt.Name .. " 18")
    task.wait(0.2)
    tchat("paint " .. tgt.Name .. " Institutional white")
    tchat("hat " .. tgt.Name .. " 10563319994")
    tchat("hat " .. tgt.Name .. " 12578728695")
    tchat("shirt " .. tgt.Name .. " 10571467676")
    tchat("pants " .. tgt.Name .. " 10571468508")
end)

addcommand("naked", "Paint player to skin color", function(args)
    local target = args[1] if not target then return end
    for _, v in pairs(GetPlayers(target)) do
        if v and v.Character and v.Character:FindFirstChild("Head") then
            tchat("paint " .. v.Name .. " " .. v.Character.Head.BrickColor.Name)
        end
    end
end)
addcommand("nude", "", function(args) commands["naked"](args) end)
addcommand("nakify", "", function(args) commands["naked"](args) end)

addcommand("femify", "Make player feminine", function(args)
    local target = args[1] if not target then return end
    local tgt = GetPlayers(target)[1]
    if not tgt then return end
    tchat("char " .. tgt.Name .. " 31342830")
    task.wait(0.2)
    repeat task.wait() until tgt.Character and tgt.Character:FindFirstChild("Ultra-Fabulous Hair")
    task.wait(0.3)
    tchat("removehats " .. tgt.Name)
    task.wait()
    tchat("paint " .. tgt.Name .. " Institutional white")
    task.wait()
    tchat("hat " .. tgt.Name .. " 7141674388")
    task.wait()
    tchat("hat " .. tgt.Name .. " 7033871971")
    task.wait()
    tchat("shirt " .. tgt.Name .. " 5933990311")
    task.wait()
    tchat("pants " .. tgt.Name .. " 7219538593")
end)

-- UI: Commands tab with two paragraphs
local __commandsTab = Window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({
    Title = "Commands 1",
    Desc = "ban <player> [reason] - blacklist & kick\nunban <player> - unblacklist\nfpunish <player> - fake punish\nkick <player> [reason] - hot potato kick\nkid <player> - make kid\nspam <msg> - spam\nunspam - stop spam\nfixfilter - fix filter\nbypassmessage <msg> - bypass filter (system)\ncage <player> - cage\nloopcage <player> - loop cage\nunloopcage <player> - stop loop\ngearbl/gearban/gearblacklist <player> - gear ban\nungearbl <player> - ungear ban\nnok - remove all TouchInterests\nclrall/clr - delete all workspace parts\nfix - remove problematic seats and spawns\nunlockworkspace/unlockws - unlock all parts\nnocam - break camera\nfcam <player> - break player's camera\nfixcam - fix camera\nslag/serverlag - lag server\nservercrash/crash/shutdown - crash server\nr15/r6 - switch rig\nping - show ping\njerk - animation\nrejoin/rj - rejoin\nserverhop/shop - hop server\nequipall - equip all\ndropall - drop all"
})
__commandsTab:Paragraph({
    Title = "Commands 2",
    Desc = "furry <player> - make furry\nnaked/nude/nakify <player> - paint skin color\nfemify <player> - make feminine\nhide/show - toggle command sending to chat"
})

local __toolsTab = Window:Tab({ Title = "Tools", Icon = "tool" })
__toolsTab:Button({ Title = "Fix Regen", Callback = function() commands["fixregen"]({}) end })
__toolsTab:Button({ Title = "TP to Regen", Callback = function() commands["tptoregen"]({}) end })
__toolsTab:Button({ Title = "Remove Regen", Callback = function() commands["rmoveregen"]({}) end })
__toolsTab:Button({ Title = "Delete Tool", Callback = function() commands["deletetool"]({}) end })

local __protectTab = Window:Tab({ Title = "Protection", Icon = "shield" })
__protectTab:Toggle({ Title = "Anti Blind", Value = antis.antiblind, Callback = function(v) antis.antiblind = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Punish", Value = antis.antipunish, Callback = function(v) antis.antipunish = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Stun", Value = antis.antistun, Callback = function(v) antis.antistun = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Setgrav", Value = antis.antisetgrav, Callback = function(v) antis.antisetgrav = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Rocket", Value = antis.antirocket, Callback = function(v) antis.antirocket = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Seizure", Value = antis.antiseizure, Callback = function(v) antis.antiseizure = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Kill", Value = antis.antikill, Callback = function(v) antis.antikill = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Message", Value = antis.antimessage, Callback = function(v) antis.antimessage = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Skydive", Value = antis.antiskydive, Callback = function(v) antis.antiskydive = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Fly", Value = antis.antifly, Callback = function(v) antis.antifly = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Void", Value = antis.antivoid, Callback = function(v) antis.antivoid = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti Freeze", Value = antis.antifreeze, Callback = function(v) antis.antifreeze = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti BanHammer", Value = antis.antibanhammer, Callback = function(v) antis.antibanhammer = v saveConfig() end })
__protectTab:Toggle({ Title = "Anti GearBan", Value = antis.antigearban, Callback = function(v) antis.antigearban = v saveConfig() end })

local __mainTab = Window:Tab({ Title = "Main", Icon = "home" })
__mainTab:Toggle({ Title = "Perm", Value = permEnabled, Callback = function(v) permEnabled = v if v then permLoop() else if permCoroutine then task.cancel(permCoroutine) end end saveConfig() end })
__mainTab:Toggle({ Title = "Auto God (god me)", Value = autoGod, Callback = function(v) autoGod = v saveConfig() end })
__mainTab:Toggle({ Title = "Auto ForceField (ff me)", Value = autoForceField, Callback = function(v) autoForceField = v saveConfig() end })
__mainTab:Toggle({ Title = "Auto Name", Value = autoName, Callback = function(v) autoName = v saveConfig() end })
__mainTab:Toggle({ Title = "Show Commands", Value = showCommands, Callback = function(v) showCommands = v saveConfig() end })

spawn(function()
    local UI = Instance.new("ScreenGui")
    CommandBar = UI
    local dairyQueenBalls = Instance.new("TextButton") local holyshidt11 = Instance.new("TextBox")
    UI.Name = "&!)!@@#$(~(UI" UI.Parent = game.CoreGui UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling UI.ResetOnSpawn = false
    dairyQueenBalls.Name = "dairyQueenBalls" dairyQueenBalls.Parent = UI dairyQueenBalls.AnchorPoint = Vector2.new(1,1) dairyQueenBalls.BackgroundColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.BackgroundTransparency = 1.000 dairyQueenBalls.BorderSizePixel = 0 dairyQueenBalls.Position = UDim2.new(1,0,1,0) dairyQueenBalls.Size = UDim2.new(0,61,0,61) dairyQueenBalls.Font = Enum.Font.Roboto dairyQueenBalls.Text = "†" dairyQueenBalls.TextColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.TextSize = 75.000 dairyQueenBalls.TextStrokeTransparency = 0.000 dairyQueenBalls.TextWrapped = true
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
            if text ~= "" then
                if showCommands then
                    local textToSend = text
                    local parts = text:split(" ")
                    local first = parts[1]:lower()
                    local aliasMap = {
                        ["shop"] = "serverhop",
                        ["rj"] = "rejoin",
                        ["slag"] = "serverlag",
                        ["unbl"] = "unban",
                        ["cf3x"] = "clonef3x",
                        ["nude"] = "naked",
                        ["unlockws"] = "unlockworkspace",
                        ["nakify"] = "naked",
                    }
                    if aliasMap[first] then
                        parts[1] = aliasMap[first]
                        textToSend = table.concat(parts, " ")
                    end
                    chat(prefix .. textToSend)
                end
                executeCommand(text)
            end
        end
    end)
end)

Players.PlayerAdded:Connect(function(p)
    if p ~= plr and table.find(whitelist, p.Name) then
        WindUI:Notify({Title="†Køhlsîfy", Content="Whitelisted, " .. p.Name .. " join in server", Duration=5})
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
            WindUI:Notify({Title="†Køhlsîfy", Content="Whitelisted, " .. p.Name .. " join in server", Duration=5})
        end
        handleBannedPlayer(p)
    end
end)

if permEnabled then permLoop() end

commands["nok"]({})
