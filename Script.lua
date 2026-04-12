-- [[ Auto farm kill v1 - FULL SPAM EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. ระบบโจมตีแบบสแปม (ปิด Auto Clicker ได้เลย) ###
local function AttackLogic()
    local char = lp.Character
    local remote = char and char:FindFirstChild("Communicate")
    if not remote then return end

    -- [สแปมหมัด M1]
    task.spawn(function()
        for i = 1, 5 do -- ส่ง 5 ครั้งต่อรอบ
            remote:FireServer({Goal = "LeftClickRelease", Mobile = true})
        end
    end)

    -- [สแปมสกิล 1-4] สกิลไหนพร้อมใช้ตัวนั้นก่อนทันที
    local skills = {"Normal Punch", "Consecutive Punches", "Shove", "Uppercut"}
    for _, name in ipairs(skills) do
        local tool = lp.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
        if tool then
            remote:FireServer({
                Goal = "Auto Use End",
                Tool = tool
            })
        end
    end
end

-- ### 2. สร้าง UI (ลากได้ / ไม่หาย / ดีไซน์ดุ) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KUYA_FINAL_V1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 90)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -45)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- ลากได้ชัวร์
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Auto farm kill v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = MainFrame

-- ### 3. ระบบวาร์ปเกาะติด (ล็อคจนกว่าจะตายจริง) ###
local isFarming = false
local target = nil

local function findTarget()
    local pot = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(pot, p)
        end
    end
    return #pot > 0 and pot[math.random(1, #pot)] or nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleBtn.Text = isFarming and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    if not isFarming then target = nil end
end)

RunService.Heartbeat:Connect(function()
    if isFarming then
        -- ล็อคเป้าจนตายสนิท (กันโดนลาสต์คิล)
        local valid = target and target.Parent and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
        
        if not valid then
            target = findTarget()
            return
        end

        local myChar = lp.Character
        local tChar = target.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") and tChar:FindFirstChild("HumanoidRootPart") then
            local myHrp = myChar.HumanoidRootPart
            local tHrp = tChar.HumanoidRootPart
            
            -- วาร์ปมุดดิน -5.8 นอนราบเกาะติดหนึบ
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
            
            -- รันระบบโจมตีสแปม
            AttackLogic()
        end
    end
end)
