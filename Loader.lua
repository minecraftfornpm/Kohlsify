local filePath = "kohlsify/loader.txt"

local function loadVersion(version)
    if version == "Release" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/minecraftfornpm/Kohlsify/refs/heads/main/Kohlsify.lua"))()
    elseif version == "Beta" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/minecraftfornpm/Kohlsify/refs/heads/main/KohlsifyBeta.lua"))()
        task.delay(5, function()
            if not getgenv().KohlsifyLoaded then
                local notificationGui = Instance.new("ScreenGui")
                notificationGui.Name = "NotificationGui"
                notificationGui.Parent = game.CoreGui

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 350, 0, 150)
                frame.Position = UDim2.new(0.5, -175, 0.5, -75)
                frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                frame.Parent = notificationGui

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0, 40)
                title.BackgroundTransparency = 1
                title.Text = "script is no started, load release?"
                title.TextColor3 = Color3.new(1, 1, 1)
                title.Parent = frame

                local loadBtn = Instance.new("TextButton")
                loadBtn.Size = UDim2.new(0, 100, 0, 30)
                loadBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
                loadBtn.Text = "load"
                loadBtn.Parent = frame

                local noBtn = Instance.new("TextButton")
                noBtn.Size = UDim2.new(0, 100, 0, 30)
                noBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
                noBtn.Text = "no"
                noBtn.Parent = frame

                loadBtn.Activated:Connect(function()
                    notificationGui:Destroy()
                    loadVersion("Release")
                end)

                noBtn.Activated:Connect(function()
                    notificationGui:Destroy()
                end)
            end
        end)
    end
end

local function showChoiceDialog()
    local dialog = Instance.new("ScreenGui")
    dialog.Name = "VersionDialog"
    dialog.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 180)
    frame.Position = UDim2.new(0.5, -200, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = dialog

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundTransparency = 1
    title.Text = "what version is load?\nRelease - always work, no problem\nBeta - buggy, can no work"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = frame

    local betaBtn = Instance.new("TextButton")
    betaBtn.Size = UDim2.new(0, 100, 0, 30)
    betaBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
    betaBtn.Text = "Beta"
    betaBtn.Parent = frame

    local releaseBtn = Instance.new("TextButton")
    releaseBtn.Size = UDim2.new(0, 100, 0, 30)
    releaseBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
    releaseBtn.Text = "Release"
    releaseBtn.Parent = frame

    local rememberCheck = Instance.new("TextButton")
    rememberCheck.Size = UDim2.new(0, 150, 0, 25)
    rememberCheck.Position = UDim2.new(0.5, -75, 0.9, 0)
    rememberCheck.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    rememberCheck.Text = "remember my choice"
    rememberCheck.TextColor3 = Color3.new(1, 1, 1)
    rememberCheck.Parent = frame

    local remember = false
    rememberCheck.Activated:Connect(function()
        remember = not remember
        rememberCheck.BackgroundColor3 = remember and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    end)

    local function choose(version)
        dialog:Destroy()
        if remember then
            writefile(filePath, version)
        end
        loadVersion(version)
    end

    betaBtn.Activated:Connect(function()
        choose("Beta")
    end)

    releaseBtn.Activated:Connect(function()
        choose("Release")
    end)
end

if isfile(filePath) then
    local choice = readfile(filePath)
    if choice == "Beta" then
        loadVersion("Beta")
    elseif choice == "Release" then
        loadVersion("Release")
    else
        showChoiceDialog()
    end
else
    showChoiceDialog()
end
