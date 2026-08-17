if game.PlaceId ~= 14747334292 then
    game.StarterGui:SetCore("SendNotification", {
        Title = "kohlsify";
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
                    for _, s in ipairs(servers.data) do if s.playing < s.maxPlayers then table.insert(good, s) end end
                    if #good > 0 then TS:TeleportToPlaceInstance(game.PlaceId, good[math.random(1,#good)].id, game.Players.LocalPlayer) end
                end)
            end
        end;
    })
    return
end

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
local whitelist = {"nowhudhejeir", "EgorYa900", "EgorYa900Alt", "PaulTheKinggg"}
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
    antijail = false,
    antispin = false,
    antistun = false,
    antisetgrav = false,
    antiswag = false,
    antirocket = false,
    antisit = false,
    antiseizure = false,
    antismoke = false,
    antisparkles = false,
    antichar = false,
    antiparticles = false,
    antikill = false,
    antimessage = false,
    antidog = false,
    antiskydive = false,
    antigrayscale = false,
    antiaddon = false,
    antifling = false,
    antifly = false,
    antivoid = false,
    antitripmine = false,
    antieggbomb = false,
}
local autoGod = false
local autoName = false
local permEnabled = false
local permCoroutine = nil

local configFolder = "kohlsify"
local configFile = configFolder .. "/config.json"
if not isfolder(configFolder) then makefolder(configFolder) end

local function saveConfig()
    local data = {
        antis = antis,
        autoGod = autoGod,
        autoName = autoName,
        permEnabled = permEnabled,
    }
    writefile(configFile, HS:JSONEncode(data))
end

local function loadConfig()
    if isfile(configFile) then
        local success, data = pcall(function() return HS:JSONDecode(readfile(configFile)) end)
        if success and data then
            if data.antis then for k,v in pairs(data.antis) do antis[k] = v end end
            autoGod = data.autoGod or false
            autoName = data.autoName or false
            permEnabled = data.permEnabled or false
        end
    end
end
loadConfig()

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
            task.wait(0.1)
        end
    end)
end

plr.CharacterAdded:Connect(function(chr)
    if autoGod then tchat("god me") tchat("ff me") end
    if autoName then
        local role = "User"
        if plr.Name == ownerName then role = "Owner"
        elseif isWhitelisted(plr) then role = "Support" end
        tchat("name me [" .. role .. " in kohlsify]\n" .. plr.DisplayName)
    end
    if antis.antifling then
        chr.ChildAdded:Connect(function(ch)
            if ch.Name == "BFRC" then
                pcall(function() ch:Destroy() end)
            end
        end)
    end
end)

spawn(function()
    local lastPos = nil
    while true do
        if antis.antifling then
            local chr = plr.Character
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                local r = chr.HumanoidRootPart
                local vel = r.Velocity
                if math.abs(vel.X) > 16 or math.abs(vel.Z) > 16 then
                    if lastPos then r.CFrame = CFrame.new(lastPos) end
                    r.Velocity = Vector3.new(0,0,0)
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
        if antis.antijail then
            if GameFolder and GameFolder:FindFirstChild("Folder") and GameFolder.Folder:FindFirstChild(plr.Name .. "'s jail") then
                tchat("unjail me")
            end
        end
        if antis.antispin then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Torso") and chr.Torso:FindFirstChild("SPINNER") then
                chr.Torso.SPINNER:Destroy()
                tchat("unspin me")
            end
        end
        if antis.antistun then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.PlatformStand then
                chr.Humanoid.PlatformStand = false
                tchat("unstun me")
            end
        end
        if antis.antisetgrav then
            local chr = plr.Character
            if chr then
                for _, v in ipairs(chr:GetDescendants()) do
                    if v:IsA("BodyForce") or v:IsA("BodyPosition") then
                        v:Destroy()
                        if chr:FindFirstChild("HumanoidRootPart") then
                            chr.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                            chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                        end
                    end
                end
            end
        end
        if antis.antiswag then
            if plr.Character and plr.Character:FindFirstChild("EpicCape") then
                plr.Character.EpicCape:Destroy()
                tchat("normal me")
            end
        end
        if antis.antirocket then
            local chr = plr.Character
            if chr then
                for _, v in ipairs(chr:GetChildren()) do
                    if v.Name == "Rocket" then
                        pcall(function() v.CanCollide = false end)
                        task.wait(0.5)
                        v:Destroy()
                    end
                end
            end
        end
        if antis.antisit then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Sit then
                chr.Humanoid.Sit = false
                tchat("unsit me")
            end
        end
        if antis.antiseizure then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Seizure") then
                tchat("unseizure me")
                pcall(function() chr.Seizure:Destroy() end)
                if chr:FindFirstChild("Torso") then chr.Torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
                if chr:FindFirstChild("Humanoid") then chr.Humanoid:ChangeState("GettingUp") end
            end
        end
        if antis.antismoke then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Torso") and chr.Torso:FindFirstChild("Smoke") then
                chr.Torso.Smoke:Destroy()
                tchat("unsmoke me")
            end
        end
        if antis.antisparkles then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Torso") then
                for _, v in ipairs(chr.Torso:GetChildren()) do
                    if v:IsA("Sparkles") then
                        v:Destroy()
                        tchat("unsparkle me")
                    end
                end
            end
        end
        if antis.antichar then
            if plr.UserId ~= plr.CharacterAppearanceId then
                tchat("unchar me")
            end
        end
        if antis.antiparticles then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Torso") then
                for _, v in ipairs(chr.Torso:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Destroy()
                        tchat("unparticle me")
                    end
                end
            end
        end
        if antis.antikill then
            local chr = plr.Character
            if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0 then
                tchat("reset me")
            end
        end
        if antis.antimessage then
            pcall(function()
                for _, v in ipairs(plr.PlayerGui:GetDescendants()) do
                    if v.Name == "MessageGUI" or v.Name == "Message" or v.Name == "HintGUI" or v.Name == "Ice" then v:Destroy() end
                end
                if Folder then for _, v in ipairs(Folder:GetDescendants()) do if v.Name == "Message" then v:Destroy() end end end
            end)
        end
        if antis.antidog then
            local chr = plr.Character
            if chr then
                for _, v in ipairs(chr:GetDescendants()) do
                    if v:IsA("FakeTorso") then
                        tchat("undog me")
                    end
                end
            end
        end
        if antis.antiskydive then
            local chr = plr.Character
            if chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.Position.Y > 256 then
                chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                chr.HumanoidRootPart.Velocity = Vector3.new(chr.HumanoidRootPart.Velocity.X, 0, chr.HumanoidRootPart.Velocity.Z)
            end
        end
        if antis.antigrayscale then
            if workspace.CurrentCamera and workspace.CurrentCamera:FindFirstChild("GrayScale") then
                workspace.CurrentCamera.GrayScale:Destroy()
            end
        end
        if antis.antiaddon then
            if plr.Character and plr.Character:FindFirstChild("Addon") then
                plr.Character.Addon:Destroy()
                tchat("reset me")
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
            if chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.Position.Y < -7 then
                chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                chr.HumanoidRootPart.Velocity = Vector3.new(chr.HumanoidRootPart.Velocity.X, 0, chr.HumanoidRootPart.Velocity.Z)
            end
        end
        if antis.antitripmine then
            local tm = workspace:FindFirstChild("SubspaceTripmine")
            if tm then tm:Destroy() tchat("clr") end
        end
        if antis.antieggbomb then
            local eb = workspace:FindFirstChild("EggBomb")
            if eb then eb:Destroy() tchat("clr") end
        end
    end
end)

plr.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "?" then
        executeCommand(msg:sub(2))
    end
end)

-- Команды
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
        local prev = antis.antijail antis.antijail = false
        spawn(function()
            _G.cagecheck = false tchat("gear me 000000000000000000000000000000000000000000082357101") repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice') plr.Backpack.PortableJustice.Parent = plr.Character repeat task.wait() until game.Workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick') local oldpos = plr.Character.HumanoidRootPart.CFrame plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame tchat('unff '..tgt.Name) repeat coroutine.wrap(function() game.Workspace[plr.Name].PortableJustice.MouseClick:FireServer(game.Workspace[tgt.Name]) end)() task.wait() until tgt.Character:FindFirstChild('DisableBackpack') pcall(function() game.Workspace[plr.Name]["PortableJustice"]:Destroy() end) _G.cagecheck = false plr.Character.HumanoidRootPart.CFrame = oldpos antis.antijail = prev
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
        local prev = antis.antijail antis.antijail = false
        spawn(function()
            tchat("ungear me") tchat("tp " .. tgt.Name .. " me") tchat("speed " .. tgt.Name .. " 0") task.wait(0.5) tchat("gear me 0000000000000000000000000000000000000000000071037101") repeat task.wait() until plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") local ungear = plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") task.wait() ungear.Parent = plr.Character task.wait(0.5) plr.Character.DaggerOfShatteredDimensions.Remote:FireServer(Enum.KeyCode.Q) task.wait(0.5) tchat("ungear me") tchat("speed " .. tgt.Name .. " 16") antis.antijail = prev
        end)
    end
end)

addcommand("fixvel", "Fix velocity of map parts", function() pcall(function() local Workspace_Folder = workspace.Terrain["GameFolder"].Workspace local Admin_Folder = workspace.Terrain["GameFolder"].Admin Workspace_Folder.Baseplate.Velocity = Vector3.new(0,0,0) Workspace_Folder.Baseplate.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Workspace_Folder["Basic House"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Admin Dividers"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby Box"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Building Bricks"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end Admin_Folder.Regen.Velocity = Vector3.new(0,0,0) Admin_Folder.Regen.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Admin_Folder.Pads:GetDescendants()) do if v.Name == "Head" then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end end end) WindUI:Notify({Title="kohlsify", Content="Velocity fixed!", Duration=2}) end)
addcommand("regen", "Click regen button", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) WindUI:Notify({Title="kohlsify", Content="Regen clicked", Duration=2}) end end)
addcommand("fixregen", "Move regen to spawn", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen then regen.CFrame = CFrame.new(-7.16500044, 5.42999268, 91.7430038) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)) WindUI:Notify({Title="kohlsify", Content="Regen moved to default position", Duration=2}) end end)
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
        local prev = antis.antijail antis.antijail = false
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
            antis.antijail = prev
        end)
    end
end)

addcommand("kid", "Make a player small with a candy", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohlsify", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        spawn(function() tchat("size " .. tgt.Name .. " 0.5") tchat("gear " .. tgt.Name .. " candy") tchat("name " .. tgt.Name .. " Good Kid") end)
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

addcommand("removeobby", "Remove obby kill parts", function()
    local obby = workspace.Terrain and workspace.Terrain["_Game"] and workspace.Terrain["_Game"].Workspace and workspace.Terrain["_Game"].Workspace.Obby
    if not obby then WindUI:Notify({Title="kohlsify", Content="Obby not found", Duration=3}) return end
    for _, part in ipairs(obby:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChild("TouchInterest") then
            part.TouchInterest:Destroy()
        end
    end
    WindUI:Notify({Title="kohlsify", Content="Obby (killbricks) removed!", Duration=3})
end)
addcommand("deleteobby", "", function(args) commands["removeobby"](args) end)
addcommand("rmobby", "", function(args) commands["removeobby"](args) end)
addcommand("dobby", "", function(args) commands["removeobby"](args) end)

addcommand("unlockworkspace", "Unlock all parts", function()
    for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = false end end
    WindUI:Notify({Title="kohlsify", Content="Workspace unlocked", Duration=2})
end)
addcommand("unlockws", "", function(args) commands["unlockworkspace"](args) end)

addcommand("nocam", "Break camera", function()
    tchat("gear me 000000000000000000000000000000000000000004842207161")
    repeat task.wait() until plr.Backpack:FindFirstChild("AR")
    plr.Backpack.AR.Parent = plr.Character
    task.wait(0.2)
    plr.Character.AR:Activate()
    WindUI:Notify({Title="kohlsify", Content="Camera broken (shiftlock)", Duration=5})
end)

addcommand("fcam", "Break player's camera", function(args)
    local target = args[1] if not target then return end
    local cplr = GetPlayers(target)[1]
    if not cplr then return end
    if not firetouchinterest then return end
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
    local part = Instance.new("Part", plr.Character)
    part.Anchored = true part.Size = Vector3.new(10,1,10) part.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    tchat("gear me 000000000000000000000000000000000000000000094794847")
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

local function FixCam()
    task.spawn(function()
        local lp = game.Players.LocalPlayer
        local UIS = game:GetService("UserInputService")
        local CAS = game:GetService("ContextActionService")
        local RUS = game:GetService("RunService")
        CAS:UnbindAction("ShoulderCameraSprint")
        RUS:UnbindFromRenderStep("ShoulderCameraUpdate")
        CAS:UnbindAction("ShoulderCameraZoom")
        while true do
            task.wait()
            repeat RUS.Heartbeat:Wait() until workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable
            RUS:UnbindFromRenderStep("ShoulderCameraUpdate")
            CAS:UnbindAction("ShoulderCameraZoom")
            CAS:UnbindAction("ShoulderCameraSprint")
            local WEPSYS = game:GetService("ReplicatedStorage"):FindFirstChild("WeaponsSystem")
            if not WEPSYS then return end
            for _, v in pairs(WEPSYS:GetDescendants()) do
                if v:IsA("Script") then v.Disabled = true end
                v:Destroy()
            end
            local CWS = lp.PlayerGui:FindFirstChild("ClientWeaponsScript")
            if CWS then CWS.Disabled = true CWS:Destroy() end
            local WSG = lp.PlayerGui:FindFirstChild("WeaponsSystemGui")
            if WSG then WSG:Destroy() end
            local CWS2 = lp.PlayerScripts:FindFirstChild("ClientWeaponsScript")
            if CWS2 then CWS2.Disabled = true CWS2:Destroy() end
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
            lp.CameraMaxZoomDistance = 400
            lp.CameraMinZoomDistance = 0.5
            workspace.CurrentCamera.FieldOfView = 70
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
            lp.Character.Humanoid.AutoRotate = true
        end
    end)
end
addcommand("fixcam", "Fix camera", function() FixCam() end)

addcommand("slag", "Server lag", function()
    tchat("ungear me")
    task.wait(0.5)
    tchat("gear me 000000000000000000000000000000000000000000059190534")
    tchat("gear me 000000000000000000000000000000000000000000059190534")
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

addcommand("r15", "Switch to R15", function() tchat("!experiment adaptiver6 on") task.wait(2) tchat("unchar me") end)
addcommand("r6", "Switch to R6", function() tchat("!experiment adaptiver6 off") end)

addcommand("ping", "Show ping", function()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    chat("Ping is " .. ping .. "ms.")
end)

addcommand("jerk", "You know", function() local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") if not humanoid then return end local tool = Instance.new("Tool") tool.Name = "Jerk Off" tool.RequiresHandle = false tool.Parent = plr.Backpack local anim = Instance.new("Animation") anim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://698251653" or "rbxassetid://72042024" local track = humanoid:LoadAnimation(anim) track:Play() track:AdjustSpeed(0.7) task.wait(0.1) track:Stop() end)
addcommand("bang", "Bang animation", function(args)
    local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674" or "rbxassetid://148840371"
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    track:AdjustSpeed(3)
end)
addcommand("unbang", "Stop bang", function() plr.Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"):Stop() end)

addcommand("rejoin", "Rejoin server", function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr) end)
addcommand("rj", "", function(args) commands["rejoin"](args) end)
addcommand("serverhop", "Hop server", function()
    local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") end)
    if not success then WindUI:Notify({Title="kohlsify", Content="Failed to fetch servers", Duration=3}) return end
    local servers = HS:JSONDecode(result)
    local good = {}
    for _, s in ipairs(servers.data) do if s.playing < s.maxPlayers then table.insert(good, s) end end
    if #good > 0 then
        local target = good[math.random(1, #good)]
        TS:TeleportToPlaceInstance(game.PlaceId, target.id, plr)
    else
        WindUI:Notify({Title="kohlsify", Content="No available servers", Duration=3})
    end
end)
addcommand("shop", "", function(args) commands["serverhop"](args) end)

-- Дополнительные команды
addcommand("equipall", "Equip all backpack items", function()
    local char = plr.Character
    local bp = plr.Backpack
    for _, v in ipairs(bp:GetChildren()) do
        if v:IsA("Tool") then v.Parent = char end
    end
    WindUI:Notify({Title="kohlsify", Content="Equipped all items!", Duration=2})
end)

addcommand("dropall", "Drop all items", function()
    local char = plr.Character
    local bp = plr.Backpack
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then v.Parent = bp end
    end
    for _, v in ipairs(bp:GetChildren()) do
        v.Parent = workspace
    end
    WindUI:Notify({Title="kohlsify", Content="Dropped all items!", Duration=2})
end)

addcommand("spawntrap", "Move spawn trap part", function()
    local part = workspace:FindFirstChild("Terrain") and workspace.Terrain["_Game"] and workspace.Terrain["_Game"].Workspace and workspace.Terrain["_Game"].Workspace.Obby and workspace.Terrain["_Game"].Workspace.Obby.Jump9
    if part then
        part.CFrame = CFrame.new(-41.0650024, 1.30000007, -28.601058959961, 0, 0, -1, 0, 1, 0, 1, 0, 0)
        WindUI:Notify({Title="kohlsify", Content="Spawn trap moved", Duration=2})
    end
end)

addcommand("prison", "Move prison part", function()
    local part = workspace:FindFirstChild("Terrain") and workspace.Terrain["_Game"] and workspace.Terrain["_Game"].Workspace and workspace.Terrain["_Game"].Workspace["Basic House"] and workspace.Terrain["_Game"].Workspace["Basic House"].SmoothBlockModel40
    if part then
        part.CFrame = CFrame.new(-10.7921638, 17.3182983, -16.0743637, -0.999961913, -0.0085983118, 0.00151610479, -1.01120179e-08, 0.173648253, 0.98480773, -0.00873095356, 0.984770179, -0.173641637)
        WindUI:Notify({Title="kohlsify", Content="Prison moved", Duration=2})
    end
end)

addcommand("furry", "Make player furry", function(args)
    local target = args[1] if not target then return end
    local tgt = GetPlayers(target)[1]
    if not tgt then return end
    tchat("char " .. tgt.Name .. " 18")
    tchat("paint " .. tgt.Name .. " Institutional white")
    tchat("hat " .. tgt.Name .. " 10563319994")
    tchat("hat " .. tgt.Name .. " 12578728695")
    tchat("shirt " .. tgt.Name .. " 10571467676")
    tchat("pants " .. tgt.Name .. " 10571468508")
end)

-- UI
local __commandsTab = Window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({
    Title = "Commands",
    Desc = "ban <player> [reason] – blacklist & kick\nunban <player> – unblacklist\nfpunish <player> – fake punish\nkick <player> – hot potato kick\nkid <player> – make kid\nspam <msg> – spam\nunspam – stop spam\nfixfilter – fix filter\nbypassmessage <msg> – bypass filter\ncage <player> – cage\nloopcage <player> – loop cage\nunloopcage <player> – stop loop\ngearbl <player> – gear ban\nungearbl <player> – ungear ban\nclonef3x/cf3x – clone F3X\nremoveobby – remove obby killbricks\nunlockworkspace/unlockws – unlock parts\nnocam – break camera\nfcam <player> – break camera\nfixcam – fix camera\nslag – lag server\nr15/r6 – switch rig\nping – show ping\njerk – animation\nbang/unbang – animation\nrejoin/rj – rejoin\nserverhop/shop – hop server\nequipall – equip all\ndropall – drop all\nspawntrap – move spawn trap\nprison – move prison\nfurry <player> – make furry"
})

local __protectTab = Window:Tab({ Title = "Protection", Icon = "shield" })
local protectionToggles = {
    {"Anti Jail", "antijail"},
    {"Anti Spin", "antispin"},
    {"Anti Stun", "antistun"},
    {"Anti Setgrav", "antisetgrav"},
    {"Anti Swag", "antiswag"},
    {"Anti Rocket", "antirocket"},
    {"Anti Sit", "antisit"},
    {"Anti Seizure", "antiseizure"},
    {"Anti Smoke", "antismoke"},
    {"Anti Sparkles", "antisparkles"},
    {"Anti Char", "antichar"},
    {"Anti Particles", "antiparticles"},
    {"Anti Kill", "antikill"},
    {"Anti Message", "antimessage"},
    {"Anti Dog", "antidog"},
    {"Anti Skydive", "antiskydive"},
    {"Anti Grayscale", "antigrayscale"},
    {"Anti Addon", "antiaddon"},
    {"Anti Fling", "antifling"},
    {"Anti Fly", "antifly"},
    {"Anti Void", "antivoid"},
    {"Anti Tripmine", "antitripmine"},
    {"Anti Eggbomb", "antieggbomb"},
}
for _, toggle in ipairs(protectionToggles) do
    local title, key = toggle[1], toggle[2]
    __protectTab:Toggle({
        Title = title,
        Value = antis[key],
        Callback = function(v)
            antis[key] = v
            saveConfig()
        end
    })
end

local __mainTab = Window:Tab({ Title = "Main", Icon = "home" })
__mainTab:Toggle({ Title = "Auto Perm", Value = permEnabled, Callback = function(v) permEnabled = v if v then permLoop() else if permCoroutine then task.cancel(permCoroutine) end end saveConfig() end })
__mainTab:Toggle({ Title = "Auto God", Value = autoGod, Callback = function(v) autoGod = v saveConfig() end })
__mainTab:Toggle({ Title = "Auto Name", Value = autoName, Callback = function(v) autoName = v saveConfig() end })

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

if permEnabled then permLoop() end
