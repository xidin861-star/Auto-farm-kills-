-- [[ Auto farm kill v1 - KUYA CLAN EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. ระบบจัดการสกิลและหมัด (Smart Spam) ###
local function AttackLogic(targetReady)
    if not targetReady then return end
    
    local char = lp.Character
    if not char then return end
    local remote = char:FindFirstChild("Communicate")
    if not remote then return end

    -- [M1 Spam] ต่อย 4 ครั้งรวด
    task.spawn(function()
        for i = 1, 4 do
            remote:FireServer({
                Goal = "LeftClickRelease",
                Mobile = true
            })
            task.wait(0.02) -- ความเร็วสูงสุดที่เซิร์ฟเวอร์ยังรับทัน
        end
    end)

    -- [Smart Skill] สกิลไหนมาใช้ตัวนั้นก่อน
    local skills = {"Normal Punch", "Consecutive Punches", "Shove", "Uppercut"}
    for _, skillName in ipairs(skills) do
        local tool = lp.Backpack:FindFirstChild(skillName) or char:FindFirstChild(skillName)
        if tool then
            remote:FireServer({
                Goal = "Auto Use End",
                Tool = tool
            })
        end
    end
end

-- ### 2. สร้าง UI (Auto farm kill v1 / ลากได้ / ไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmV1_Main"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 80)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- ลากได้ตามสั่ง
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Auto farm kill v1"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = MainFrame

-- ### 3. ระบบค้นหาและเกาะติด (Infinite Range) ###
local isFarming = false
local target = nil

local function findTarget()
    local allPlayers = Players:GetPlayers()
    local potential = {}
    for _, p in pairs(allPlayers) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(potential, p)
        end
    end
    -- สุ่มเป้าหมายจากคนที่มีอยู่ (หรือเลือกคนใกล้สุดก็ได้ถ้าต้องการ)
    return #potential > 0 and potential[math.random(1, #potential)] or nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleBtn.Text = isFarming and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    if isFarming then target = findTarget() end
end)

-- ใช้ Heartbeat เพื่อความไวสูงสุดในการตามตัว
RunService.Heartbeat:Connect(function()
    if isFarming then
        -- ตรวจเช็กเป้าหมาย: ถ้าตายหรือออก จะหยุดทำงานทันที (ป้องกันแบน)
        local valid = target and target.Parent and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
        
        if not valid then
            target = findTarget() -- หาเหยื่อรายใหม่
            return
        end

        local myChar = lp.Character
        local targetChar = target.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
            local myHrp = myChar.HumanoidRootPart
            local targetHrp = targetChar.HumanoidRootPart
            
            -- วาร์ปไปนอนราบ -5.5 ใต้เท้า (ไกลแค่ไหนก็พุ่งไปหา)
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, -5.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0) -- ตัดแรงเฉื่อยป้องกันการหลุดแมพ
            
            -- สั่งโจมตีแบบ Loop
            AttackLogic(true)
        end
    end
end)
