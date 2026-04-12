-- [[ Auto farm kill v1 - FIXED & FAST ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. ระบบโจมตี (เน้นส่งสัญญาณรัว ไม่สนบั๊ก) ###
local function AttackLogic()
    local char = lp.Character
    if not char then return end
    local remote = char:FindFirstChild("Communicate")
    if not remote then return end

    -- [M1 Spam] ส่งสัญญาณต่อย 4 ครั้งแบบรวดเร็ว
    for i = 1, 4 do
        remote:FireServer({
            Goal = "LeftClickRelease",
            Mobile = true
        })
    end

    -- [Skill Spam] สกิลไหนคูลดาวน์เสร็จ กดใช้ทันที
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

-- ### 2. UI (ลากได้ ตายไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmV1_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 80)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true -- ลากได้ชัวร์
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Auto farm kill v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Parent = MainFrame

-- ### 3. ระบบวาร์ปเกาะติด -5.8 (ไม่หยุดจนกว่าจะปิด) ###
local isFarming = false
local target = nil

local function findTarget()
    local potential = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(potential, p)
        end
    end
    return #potential > 0 and potential[math.random(1, #potential)] or nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleBtn.Text = isFarming and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

RunService.Heartbeat:Connect(function()
    if isFarming then
        -- ถ้าเป้าหมายเดิมตายหรือหายไป ให้หาคนใหม่ทันทีแบบไม่ต้องรอ
        if not target or not target.Parent or not target.Character or target.Character.Humanoid.Health <= 0 then
            target = findTarget()
            return
        end

        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = char.HumanoidRootPart
            local tHrp = target.Character.HumanoidRootPart
            
            -- วาร์ปมุดดิน -5.8 นอนราบ
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
            
            -- รันระบบโจมตีต่อเนื่อง
            AttackLogic()
        end
    end
end)
