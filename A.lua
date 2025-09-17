local Player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystem"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local g1 = Instance.new("Frame",ScreenGui); g1.Size = UDim2.new(1,0,0.12,0); g1.Position = UDim2.new(0,0,0,0); g1.BackgroundColor3 = Color3.fromRGB(170,210,255); g1.BorderSizePixel = 0
local g2 = Instance.new("Frame",ScreenGui); g2.Size = UDim2.new(1,0,0.12,0); g2.Position = UDim2.new(0,0,0.12,0); g2.BackgroundColor3 = Color3.fromRGB(160,200,245); g2.BorderSizePixel = 0
local g3 = Instance.new("Frame",ScreenGui); g3.Size = UDim2.new(1,0,0.12,0); g3.Position = UDim2.new(0,0,0.24,0); g3.BackgroundColor3 = Color3.fromRGB(150,190,235); g3.BorderSizePixel = 0
local g4 = Instance.new("Frame",ScreenGui); g4.Size = UDim2.new(1,0,0.12,0); g4.Position = UDim2.new(0,0,0.36,0); g4.BackgroundColor3 = Color3.fromRGB(140,180,225); g4.BorderSizePixel = 0
local g5 = Instance.new("Frame",ScreenGui); g5.Size = UDim2.new(1,0,0.12,0); g5.Position = UDim2.new(0,0,0.48,0); g5.BackgroundColor3 = Color3.fromRGB(130,170,215); g5.BorderSizePixel = 0
local g6 = Instance.new("Frame",ScreenGui); g6.Size = UDim2.new(1,0,0.12,0); g6.Position = UDim2.new(0,0,0.60,0); g6.BackgroundColor3 = Color3.fromRGB(120,160,205); g6.BorderSizePixel = 0
local g7 = Instance.new("Frame",ScreenGui); g7.Size = UDim2.new(1,0,0.12,0); g7.Position = UDim2.new(0,0,0.72,0); g7.BackgroundColor3 = Color3.fromRGB(110,150,195); g7.BorderSizePixel = 0
local g8 = Instance.new("Frame",ScreenGui); g8.Size = UDim2.new(1,0,0.12,0); g8.Position = UDim2.new(0,0,0.84,0); g8.BackgroundColor3 = Color3.fromRGB(100,140,185); g8.BorderSizePixel = 0
local g9 = Instance.new("Frame",ScreenGui); g9.Size = UDim2.new(1,0,0.16,0); g9.Position = UDim2.new(0,0,0.96,0); g9.BackgroundColor3 = Color3.fromRGB(90,130,175); g9.BorderSizePixel = 0
local gradients = {g1,g2,g3,g4,g5,g6,g7,g8,g9}

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,350,0,260)
Frame.Position = UDim2.new(0,20,0.5,-130)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
local function addCorner(inst,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = inst
end
addCorner(Frame,15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.9,0,0,30)
Title.Position = UDim2.new(0.05,0,0.05,0)
Title.BackgroundTransparency = 1
Title.Text = "Lead Hub | V1.1"
Title.TextColor3 = Color3.fromRGB(0,60,120)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.9,0,0,40)
KeyBox.Position = UDim2.new(0.05,0,0.3,0)
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 18
KeyBox.TextColor3 = Color3.fromRGB(0,0,0)
KeyBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
KeyBox.BorderSizePixel = 0
KeyBox.TextXAlignment = Enum.TextXAlignment.Left
KeyBox.Parent = Frame
addCorner(KeyBox,8)

local EnterBtn = Instance.new("TextButton")
EnterBtn.Size = UDim2.new(0.42,0,0,40)
EnterBtn.Position = UDim2.new(0.05,0,0.65,0)
EnterBtn.BackgroundColor3 = Color3.fromRGB(100,180,255)
EnterBtn.Text = "Enter"
EnterBtn.TextScaled = true
EnterBtn.Font = Enum.Font.GothamBold
EnterBtn.TextColor3 = Color3.fromRGB(255,255,255)
EnterBtn.Parent = Frame
addCorner(EnterBtn,8)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.42,0,0,40)
GetKeyBtn.Position = UDim2.new(0.53,0,0.65,0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80,160,230)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextScaled = true
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
GetKeyBtn.Parent = Frame
addCorner(GetKeyBtn,8)

local snowflakes = {}
for i=1,10 do
    local snow = Instance.new("TextLabel")
    snow.Text = "❄️"
    snow.TextSize = math.random(20,35)
    snow.Position = UDim2.new(math.random(),0,math.random(),-50)
    snow.BackgroundTransparency = 1
    snow.Parent = ScreenGui
    table.insert(snowflakes,snow)
end

spawn(function()
    while ScreenGui.Parent do
        for _,snow in ipairs(snowflakes) do
            local x = math.random()
            snow.Position = UDim2.new(x,0,-0.05,0)
            snow:TweenPosition(UDim2.new(x,0,1,0),"Linear","Out",math.random(6,12),true,function()
                snow.Position = UDim2.new(math.random(),0,-0.05,0)
            end)
            task.wait(0.3)
        end
        task.wait(0.5)
    end
end)

local function Notify(msg,color)
    local Noti = Instance.new("TextLabel")
    Noti.Size = UDim2.new(0,250,0,40)
    Noti.Position = UDim2.new(1,-260,1,-60)
    Noti.BackgroundColor3 = color
    Noti.BorderSizePixel = 0
    Noti.Text = msg
    Noti.TextScaled = true
    Noti.Font = Enum.Font.GothamBold
    Noti.TextColor3 = Color3.fromRGB(255,255,255)
    Noti.Parent = ScreenGui
    Noti.Position = UDim2.new(1,-260,1,60)
    Noti:TweenPosition(UDim2.new(1,-260,1,-60),"Out","Quad",0.5,true)
    task.delay(3,function()
        if Noti then
            Noti:TweenPosition(UDim2.new(1,260,1,-60),"In","Quad",0.5,true)
            game:GetService("Debris"):AddItem(Noti,1)
        end
    end)
end

local CorrectKey = "(stars_are-so+C0oL!)"

EnterBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == CorrectKey then
        Notify("Access Granted", Color3.fromRGB(0,170,90))
        for i, frame in ipairs(gradients) do
            frame:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
            task.wait(0.1)
        end
        Frame:TweenSize(UDim2.new(0,350,0,0), "Out", "Quad", 0.7, true)
        task.wait(0.7)
        ScreenGui:Destroy()
        loadstring(game:HttpGet("https://pastebin.com/raw/qBx0i9zj"))()
    else
        Notify("Wrong Key!", Color3.fromRGB(200,0,0))
    end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/mPMyz3rB2J")
    Notify("Key link copied!", Color3.fromRGB(80,160,230))
end)
