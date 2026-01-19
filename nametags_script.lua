local plrs = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local txtChat = game:GetService("TextChatService")
local tweenSvc = game:GetService("TweenService")
local runSvc = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")

local lp = plrs.LocalPlayer
local taggedPlrs = {}
local respondedPlrs = {}

local defaultTagSz = UDim2.new(0, 115, 0, 42)
local rankedTagSz = UDim2.new(0, 115, 0, 54)
local tagOff = Vector3.new(0, 2.2, 0)

local LOGO_ASSET_ID = "rbxassetid://119568230377693"

local customPlayers = {
    ["GoIdNation"] = {
        color = Color3.fromRGB(255, 255, 255),
        glowColor = Color3.fromRGB(255, 255, 255),
        customName = "BIG YK"
    },
},
},
    ["forrandomsthings"] = {
        color = Color3.fromRGB(173,216,230),
        glowColor = Color3.fromRGB(173,216,230),
        customName = "KZK HEAD-ADMIN"
    },
    ["Kikz1245"] = {
        color = Color3.fromRGB(139,0,0),
        glowColor = Color3.fromRGB(139,0,0),
        customName = "KZK OWNER"
    },
    [123456789] = {
        color = Color3.fromRGB(255, 255, 100),
        glowColor = Color3.fromRGB(255, 255, 100),
        customName = "VIP Player"
    },
}

local function getCustomData(plr)
    if customPlayers[plr.Name] then
        return customPlayers[plr.Name]
    end
    if customPlayers[plr.UserId] then
        return customPlayers[plr.UserId]
    end
    return nil
end

starterGui:SetCore("SendNotification", {
    Title = "Nametag System";
    Text = "Made by Absent\ndiscord.gg/akadmin";
    Duration = 5;
})

local function getRankData(plr)
    if ranks and ranks[plr.Name] then
        return ranks[plr.Name]
    end
    if ranksByUserId and ranksByUserId[plr.UserId] then
        return ranksByUserId[plr.UserId]
    end
    return nil
end

local function buildTag(plr)
    local char = plr.Character
    if not char then return end
    
    local hd = char:FindFirstChild("Head")
    if not hd then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local pg = lp:WaitForChild("PlayerGui")
    
    -- Delete existing tag if it exists, we'll rebuild it fresh
    local existingTag = pg:FindFirstChild("KZKNametag_" .. plr.UserId)
    if existingTag then
        existingTag:Destroy()
    end
    
    taggedPlrs[plr.UserId] = true
    
    local customData = getCustomData(plr)
    local rankData = getRankData(plr)
    local hasRank = rankData ~= nil
    
    local tagColor, glowColor
    if customData then
        tagColor = customData.color
        glowColor = customData.glowColor
    else
        tagColor = Color3.fromRGB(180, 120, 230)
        glowColor = Color3.fromRGB(180, 120, 230)
    end
    
    local displayName = customData and customData.customName or plr.Name
    
    local initialSize = hasRank and rankedTagSz or defaultTagSz
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "KZKNametag_" .. plr.UserId
    bb.Parent = pg
    bb.Size = initialSize
    bb.StudsOffset = tagOff
    bb.AlwaysOnTop = true
    bb.MaxDistance = math.huge
    bb.Adornee = hd
    bb.Active = true
    
    local btn = Instance.new("TextButton")
    btn.Name = "Detector"
    btn.Parent = bb
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 20
    btn.AutoButtonColor = false
    btn.Active = true
    
    if plr ~= lp then
        btn.MouseButton1Click:Connect(function()
            local myChar = lp.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") and hrp and hrp.Parent then
                myChar.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
            end
        end)
    end
    
    local bg = Instance.new("Frame")
    bg.Parent = bb
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 3, 15)
    bg.BorderSizePixel = 0
    bg.BackgroundTransparency = 0.2
    bg.ZIndex = 1
    
    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 10)
    cr.Parent = bg
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 20), Color3.fromRGB(10, 10, 10))
    grad.Rotation = 90
    grad.Parent = bg
    
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Parent = bg
    glow.Size = UDim2.new(1.1, 0, 1.1, 0)
    glow.Position = UDim2.new(-0.05, 0, -0.05, 0)
    glow.BackgroundColor3 = glowColor
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    
    local glowCr = Instance.new("UICorner")
    glowCr.CornerRadius = UDim.new(0, 13)
    glowCr.Parent = glow
    
    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "Logo"
    logoImg.Parent = bg
    logoImg.Size = UDim2.new(0.7, 0, 0.7, 0)
    logoImg.Position = UDim2.new(0.15, 0, 0.15, 0)
    logoImg.BackgroundTransparency = 0
    logoImg.Image = LOGO_ASSET_ID
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = 4
    logoImg.Visible = false
    
    local txtBox = Instance.new("Frame")
    txtBox.Parent = bg
    txtBox.Size = UDim2.new(0.88, 0, 0.5, 0)
    txtBox.Position = UDim2.new(0.06, 0, 0.12, 0)
    txtBox.BackgroundTransparency = 1
    txtBox.ZIndex = 2
    
    local kzk = Instance.new("TextLabel")
    kzk.Name = "Left"
    kzk.Parent = txtBox
    kzk.Size = UDim2.new(1, 0, 1, 0)
    kzk.Position = UDim2.new(0, 0, 0, 0)
    kzk.BackgroundTransparency = 1
    kzk.Text = customData and customData.customName or "KZK"
    kzk.TextColor3 = tagColor
    kzk.TextScaled = true
    kzk.TextXAlignment = Enum.TextXAlignment.Center
    kzk.Font = Enum.Font.GothamBold
    kzk.TextStrokeTransparency = 0.5
    kzk.ZIndex = 3
    
    local kzkConstraint = Instance.new("UITextSizeConstraint")
    kzkConstraint.MaxTextSize = 30
    kzkConstraint.Parent = kzk
    
    local kzkPadding = Instance.new("UIPadding")
    kzkPadding.PaddingLeft = UDim.new(0, 4)
    kzkPadding.PaddingRight = UDim.new(0, 4)
    kzkPadding.PaddingTop = UDim.new(0, 2)
    kzkPadding.PaddingBottom = UDim.new(0, 2)
    kzkPadding.Parent = kzk
    
    local usr = Instance.new("TextLabel")
    usr.Name = "Right"
    usr.Parent = bg
    usr.Size = UDim2.new(0, 0, 0, 0)
    usr.BackgroundTransparency = 1
    usr.Text = ""
    usr.Visible = false
    usr.ZIndex = 3
    
    local dname = Instance.new("TextLabel")
    dname.Name = "Username"
    dname.Parent = bg
    dname.Size = UDim2.new(0.88, 0, 0.3, 0)
    dname.Position = UDim2.new(0.06, 0, 0.65, 0)
    dname.BackgroundTransparency = 1
    dname.Text = "@" .. plr.Name
    dname.TextColor3 = customData and tagColor or Color3.fromRGB(150, 100, 200)
    dname.TextScaled = true
    dname.TextXAlignment = Enum.TextXAlignment.Center
    dname.Font = Enum.Font.Gotham
    dname.TextStrokeTransparency = 0.7
    dname.ZIndex = 3
    
    local dnameConstraint = Instance.new("UITextSizeConstraint")
    dnameConstraint.MaxTextSize = 12
    dnameConstraint.Parent = dname
    
    local dnamePadding = Instance.new("UIPadding")
    dnamePadding.PaddingLeft = UDim.new(0, 4)
    dnamePadding.PaddingRight = UDim.new(0, 4)
    dnamePadding.Parent = dname
    
    local rankBadge
    if hasRank then
        rankBadge = Instance.new("Frame")
        rankBadge.Name = "RankBadge"
        rankBadge.Parent = bg
        rankBadge.Size = UDim2.new(0.88, 0, 0.24, 0)
        rankBadge.Position = UDim2.new(0.06, 0, 0.88, 0)
        rankBadge.BackgroundColor3 = rankData.color
        rankBadge.BorderSizePixel = 0
        rankBadge.ZIndex = 2
        
        local rankCorner = Instance.new("UICorner")
        rankCorner.CornerRadius = UDim.new(0, 5)
        rankCorner.Parent = rankBadge
        
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Parent = rankBadge
        rankLabel.Size = UDim2.new(1, 0, 1, 0)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Text = rankData.rank
        rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        rankLabel.TextScaled = true
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.TextStrokeTransparency = 0.5
        rankLabel.ZIndex = 3
        
        local rankPadding = Instance.new("UIPadding")
        rankPadding.PaddingLeft = UDim.new(0, 3)
        rankPadding.PaddingRight = UDim.new(0, 3)
        rankPadding.PaddingTop = UDim.new(0, 1)
        rankPadding.PaddingBottom = UDim.new(0, 1)
        rankPadding.Parent = rankLabel
    end
    
    spawn(function()
        while bb and bb.Parent do
            for i = 0, 1, 0.1 do
                if not kzk or not usr then break end
                kzk.TextStrokeTransparency = 0.5 + (i * 0.4)
                usr.TextStrokeTransparency = 0.5 + (i * 0.4)
                wait(0.03)
            end
            for i = 1, 0, -0.1 do
                if not kzk or not usr then break end
                kzk.TextStrokeTransparency = 0.5 + (i * 0.4)
                usr.TextStrokeTransparency = 0.5 + (i * 0.4)
                wait(0.03)
            end
            wait(0.2)
        end
    end)
    
    local pFrm = Instance.new("Frame")
    pFrm.Parent = bg
    pFrm.Size = UDim2.new(1, 0, 1, 0)
    pFrm.BackgroundTransparency = 1
    pFrm.ZIndex = 1
    
    for i = 1, 18 do
        local dot = Instance.new("Frame")
        dot.Parent = pFrm
        dot.Size = UDim2.new(0, 2, 0, 2)
        dot.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.9 + 0.05, 0)
        dot.BackgroundColor3 = tagColor
        dot.BackgroundTransparency = math.random(30, 70) / 100
        dot.ZIndex = 1
        
        local dotCr = Instance.new("UICorner")
        dotCr.CornerRadius = UDim.new(1, 0)
        dotCr.Parent = dot
    end
    
    spawn(function()
        while bb and bb.Parent do
            for _, dot in pairs(pFrm:GetChildren()) do
                if dot:IsA("Frame") then
                    local pos = dot.Position
                    local yVal = pos.Y.Scale - 0.01
                    if yVal < -0.1 then yVal = 1.1 end
                    
                    dot.Position = UDim2.new(pos.X.Scale, 0, yVal, 0)
                    dot.BackgroundTransparency = 0.3 + math.random(0, 50) / 100
                end
            end
            wait(0.05)
        end
    end)
    
    local tweenCfg = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    
    spawn(function()
        while bb and bb.Parent and hrp and hrp.Parent do
            local myChar = lp.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
                local currentSize = hasRank and rankedTagSz or defaultTagSz
                
                if dist > 100 then
                    local minSz = UDim2.new(0, 28, 0, 28)
                    local szTween = tweenSvc:Create(bb, tweenCfg, {Size = minSz})
                    szTween:Play()
                    
                    local crTween = tweenSvc:Create(cr, tweenCfg, {CornerRadius = UDim.new(1, 0)})
                    crTween:Play()
                    
                    local clrTween = tweenSvc:Create(bg, tweenCfg, {BackgroundColor3 = Color3.fromRGB(30, 15, 50)})
                    clrTween:Play()
                    
                    kzk.Visible = false
                    usr.Visible = false
                    dname.Visible = false
                    pFrm.Visible = false
                    if rankBadge then rankBadge.Visible = false end
                    logoImg.Visible = true
                else
                    local normTween = tweenSvc:Create(bb, tweenCfg, {Size = currentSize})
                    normTween:Play()
                    
                    local crTween = tweenSvc:Create(cr, tweenCfg, {CornerRadius = UDim.new(0, 10)})
                    crTween:Play()
                    
                    local clrTween = tweenSvc:Create(bg, tweenCfg, {BackgroundColor3 = Color3.fromRGB(5, 3, 15)})
                    clrTween:Play()
                    
                    kzk.Visible = true
                    usr.Visible = true
                    dname.Visible = true
                    pFrm.Visible = true
                    if rankBadge then rankBadge.Visible = true end
                    logoImg.Visible = false
                end
            end
            wait(0.1)
        end
    end)
    
    -- Cleanup and character tracking (THIS GOES INSIDE buildTag)
    local cleanup
    cleanup = runSvc.Heartbeat:Connect(function()
        if not hd or not hd.Parent or not char or not char.Parent then
            if bb and bb.Parent then
                bb.Adornee = nil
            end
            
            if plr and plr.Parent then
                local newChar = plr.Character
                if newChar and newChar:FindFirstChild("Head") and newChar:FindFirstChild("HumanoidRootPart") then
                    local newHd = newChar.Head
                    local newHrp = newChar.HumanoidRootPart
                    if bb and bb.Parent then
                        bb.Adornee = newHd
                        hd = newHd
                        hrp = newHrp
                        char = newChar
                    end
                end
            else
                if bb and bb.Parent then
                    bb:Destroy()
                end
                taggedPlrs[plr.UserId] = nil
                cleanup:Disconnect()
            end
        end
    end)
    
    char.AncestryChanged:Connect(function()
        if not char.Parent then
            if bb and bb.Parent then
                bb.Adornee = nil
            end
        end
    end)
end

-- Build initial tag for local player
if lp.Character then
    buildTag(lp)
end

lp.CharacterAdded:Connect(function(char)
    wait(0.5)
    if char:FindFirstChild("Head") then
        buildTag(lp)
    end
end)

for _, plr in pairs(plrs:GetPlayers()) do
    plr.CharacterAdded:Connect(function(char)
        if taggedPlrs[plr.UserId] then
            wait(0.5)
            if char:FindFirstChild("Head") then
                buildTag(plr)
            end
        end
    end)
end

plrs.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if taggedPlrs[plr.UserId] then
            wait(0.5)
            if char:FindFirstChild("Head") then
                buildTag(plr)
            end
        end
    end)
end)

local channels = txtChat:WaitForChild("TextChannels", 5)
local general = channels and channels:FindFirstChild("RBXGeneral")

if channels then
    for _, ch in pairs(channels:GetChildren()) do
        if ch:IsA("TextChannel") then
            ch.MessageReceived:Connect(function(msg)
                if msg and msg.Text then
                    local txt = string.lower(msg.Text)
                    
                    if string.find(txt, ",,kzk,,") then
                        local src = msg.TextSource
                        if src then
                            local sender = plrs:GetPlayerByUserId(src.UserId)
                            
                            if sender then
                                if sender ~= lp and not respondedPlrs[sender.UserId] then
                                    task.wait(0.5)
                                    ch:SendAsync(",,kzk,,")
                                    respondedPlrs[sender.UserId] = true
                                end
                                
                                if not taggedPlrs[sender.UserId] then
                                    if sender.Character then
                                        buildTag(sender)
                                    else
                                        sender.CharacterAdded:Wait()
                                        wait(0.5)
                                        buildTag(sender)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    
    channels.ChildAdded:Connect(function(ch)
        if ch:IsA("TextChannel") then
            ch.MessageReceived:Connect(function(msg)
                if msg and msg.Text then
                    local txt = string.lower(msg.Text)
                    
                    if string.find(txt, ",,kzk,,") then
                        local src = msg.TextSource
                        if src then
                            local sender = plrs:GetPlayerByUserId(src.UserId)
                            
                            if sender then
                                if sender ~= lp and not respondedPlrs[sender.UserId] then
                                    task.wait(0.5)
                                    ch:SendAsync(",,kzk,,")
                                    respondedPlrs[sender.UserId] = true
                                end
                                
                                if not taggedPlrs[sender.UserId] then
                                    if sender.Character then
                                        buildTag(sender)
                                    else
                                        sender.CharacterAdded:Wait()
                                        wait(0.5)
                                        buildTag(sender)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    if general then
        task.wait(0.5)
        general:SendAsync(",,kzk,,")
    end
end

plrs.PlayerRemoving:Connect(function(plr)
    taggedPlrs[plr.UserId] = nil
    respondedPlrs[plr.UserId] = nil

    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        local tag = pg:FindFirstChild("KZKNametag_" .. plr.UserId)
        if tag then
            tag:Destroy()
        end
    end
end)

game:BindToClose(function()
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in pairs(pg:GetChildren()) do
            if string.find(obj.Name, "KZKNametag_") then
                obj:Destroy()
            end
        end
    end
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "NametagToggle"
toggleBtn.Parent = lp:WaitForChild("PlayerGui")
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "Nametag: ON"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.ZIndex = 100

local nametagEnabled = true

toggleBtn.MouseButton1Click:Connect(function()
    nametagEnabled = not nametagEnabled
    toggleBtn.Text = nametagEnabled and "Nametag: ON" or "Nametag: OFF"

    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in pairs(pg:GetChildren()) do
            if string.find(obj.Name, "KZKNametag_") then
                obj.Enabled = nametagEnabled
            end
        end
    end
end)