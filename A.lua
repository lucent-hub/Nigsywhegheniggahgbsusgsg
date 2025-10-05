-- Hardened Low-Power Key System (single-word ids) + ASCII Art "LEAD HUB"
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- single-word main gui
local Gui = Instance.new("ScreenGui")
Gui.Name = "KeySystem"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

-- ======== utils ========
local function pok(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function sWait(t)
    if type(wait) == "function" then wait(t or 0.03) else task.wait(t or 0.03) end
end

local function sDelay(d, fn)
    if typeof(delay) == "function" then
        delay(d, fn)
    else
        spawn(function() sWait(d); pcall(fn) end)
    end
end

-- encode/decode
local function encode(str, k)
    local out = {}
    for i = 1, #str do
        local a = string.byte(str, i)
        local b = string.byte(k, ((i - 1) % #k) + 1)
        out[i] = string.char(((a + b) % 256))
    end
    return table.concat(out)
end
local function decode(str, k)
    local out = {}
    for i = 1, #str do
        local a = string.byte(str, i)
        local b = string.byte(k, ((i - 1) % #k) + 1)
        out[i] = string.char(((a - b) % 256))
    end
    return table.concat(out)
end

-- ======== Key memory (single-word Key) ========
local Key = "(stars_are-so+C0oL!)" -- plain (change if needed)
local Secret = "local_secret!"
local Enc = encode(Key, Secret)

local function randName()
    return "K"..tostring(math.random(1000,9999))..tostring(os.time()%100000)
end
local Var = randName()
getgenv()[Var] = Enc

local function verify(input)
    if type(input) ~= "string" then return false end
    local e = getgenv()[Var]
    if not e then return false end
    return encode(input, Secret) == e
end

-- ======== Anti-tamper / anti-dump ========
local enterStart = 0
local MIN_ENTER = 1.5

local function kill(msg)
    pcall(function()
        if type(msg) == "string" then
            Player:Kick("Security: "..msg)
        else
            Player:Kick("Fuck YOU whore!!!")
        end
    end)
end

spawn(function()
    while Gui and Gui.Parent do
        sWait(2)
        local ok, err = pcall(function()
            if not Gui:IsDescendantOf(PlayerGui) then
                kill("I hope u die CUNT")
            end
        end)
        if not ok then kill("GUI error") end
    end
end)

spawn(function()
    while Gui and Gui.Parent do
        sWait(3) 
        pcall(function()
            for _, o in ipairs(Gui:GetDescendants()) do
                if o:IsA("GuiObject") and o.Parent ~= Gui and not o:IsDescendantOf(PlayerGui) then
                    kill("Unauthorized GUI clone detected")
                end
            end
        end)
    end
end)

-- ======== UI (single-word Ui) ========
local colors = {
    Color3.fromRGB(170,210,255),
    Color3.fromRGB(160,200,245),
    Color3.fromRGB(150,190,235),
    Color3.fromRGB(140,180,225),
    Color3.fromRGB(130,170,215),
    Color3.fromRGB(120,160,205),
    Color3.fromRGB(110,150,195),
    Color3.fromRGB(100,140,185),
    Color3.fromRGB(90,130,175)
}
local grads = {}
for i,c in ipairs(colors) do
    local f = Instance.new("Frame", Gui)
    f.Size = UDim2.new(1,0,0.12,0)
    f.Position = UDim2.new(0,0,(i-1)*0.12,0)
    f.BackgroundColor3 = c
    f.BorderSizePixel = 0
    grads[i] = f
end
grads[#grads].Size = UDim2.new(1,0,0.16,0)

local function corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = i
end

local Ui = Instance.new("Frame")
Ui.Size = UDim2.new(0,350,0,300) -- taller to fit ASCII art
Ui.Position = UDim2.new(0,20,0.5,-150)
Ui.BackgroundColor3 = Color3.fromRGB(255,255,255)
Ui.BackgroundTransparency = 0.15
Ui.BorderSizePixel = 0
Ui.Parent = Gui
corner(Ui, 15)

-- ASCII art for "LEAD HUB"
local ArtText = [[
     

┏┓╋╋╋╋╋╋╋╋╋╋┏┓
┃┃╋╋╋╋╋╋╋╋╋╋┃┃
┃┃╋╋┏━━┳━━┳━┛┃
┃┃╋┏┫┃━┫┏┓┃┏┓┃
┃┗━┛┃┃━┫┏┓┃┗┛┃
┗━━━┻━━┻┛┗┻━━┛
   HUB
]]

local Art = Instance.new("TextLabel")
Art.Size = UDim2.new(0.9,0,0.24,0)
Art.Position = UDim2.new(0.05,0,0.04,0)
Art.BackgroundTransparency = 1
Art.Text = ArtText
Art.TextColor3 = Color3.fromRGB(0,60,120)
Art.TextWrapped = true
Art.RichText = false
Art.TextXAlignment = Enum.TextXAlignment.Left
Art.TextYAlignment = Enum.TextYAlignment.Top
Art.Font = Enum.Font.Code or Enum.Font.GothamBold
Art.TextSize = 14
Art.Parent = Ui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.9,0,0,26)
Title.Position = UDim2.new(0.05,0,0.30,0) -- moved down to fit ASCII art
Title.BackgroundTransparency = 1
Title.Text = "Lead Hub | V1.1"
Title.TextColor3 = Color3.fromRGB(0,60,120)
Title.TextScaled = false
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 16
Title.Parent = Ui

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(0.9,0,0,40)
Box.Position = UDim2.new(0.05,0,0.45,0)
Box.PlaceholderText = "Enter Key..."
Box.Font = Enum.Font.Gotham
Box.TextSize = 18
Box.TextColor3 = Color3.fromRGB(0,0,0)
Box.BackgroundColor3 = Color3.fromRGB(255,255,255)
Box.BorderSizePixel = 0
Box.TextXAlignment = Enum.TextXAlignment.Left
Box.ClearTextOnFocus = false
Box.Parent = Ui
corner(Box, 8)

local BtnEnter = Instance.new("TextButton")
BtnEnter.Size = UDim2.new(0.42,0,0,40)
BtnEnter.Position = UDim2.new(0.05,0,0.68,0)
BtnEnter.BackgroundColor3 = Color3.fromRGB(100,180,255)
BtnEnter.Text = "Enter"
BtnEnter.TextScaled = true
BtnEnter.Font = Enum.Font.GothamBold
BtnEnter.TextColor3 = Color3.fromRGB(255,255,255)
BtnEnter.Parent = Ui
corner(BtnEnter, 8)

local BtnGet = Instance.new("TextButton")
BtnGet.Size = UDim2.new(0.42,0,0,40)
BtnGet.Position = UDim2.new(0.53,0,0.68,0)
BtnGet.BackgroundColor3 = Color3.fromRGB(80,160,230)
BtnGet.Text = "Get Key"
BtnGet.TextScaled = true
BtnGet.Font = Enum.Font.GothamBold
BtnGet.TextColor3 = Color3.fromRGB(255,255,255)
BtnGet.Parent = Ui
corner(BtnGet, 8)

local function Notify(msg, col, dur)
    local N = Instance.new("TextLabel", Gui)
    N.Size = UDim2.new(0,250,0,40)
    N.Position = UDim2.new(1,-260,1,-60)
    N.BackgroundColor3 = col or Color3.fromRGB(60,60,60)
    N.BorderSizePixel = 0
    N.Text = msg or ""
    N.TextScaled = true
    N.Font = Enum.Font.GothamBold
    N.TextColor3 = Color3.fromRGB(255,255,255)
    corner(N, 8)
    sDelay(dur or 3, function() if N and N.Parent then N:Destroy() end end)
end

-- simple snow
for i = 1, 10 do
    local s = Instance.new("TextLabel", Gui)
    s.Text = "❄️"
    s.TextSize = math.random(20, 30)
    s.Position = UDim2.new(math.random(),0,math.random()*0.2,0)
    s.BackgroundTransparency = 1
    spawn(function()
        while s.Parent do
            sWait(0.08 + math.random()*0.05)
            local cy = s.Position.Y.Scale + 0.01 + math.random()*0.02
            local nx = math.random()
            s.Position = UDim2.new(nx,0,cy,0)
            if s.Position.Y.Scale > 1.1 then
                s.Position = UDim2.new(math.random(),0,-0.05,0)
            end
        end
    end)
end

-- safe http
local function httpGet(u)
    local ok, res = pcall(function() return game:HttpGet(u, true) end)
    if ok and res and #res > 0 then return res end
    return nil
end

-- Supported games (single-word Function entries)
local Function = {
    {Id = 79546208627805, Name = "v1", Exec = function()
        local code = httpGet("https://files.catbox.moe/vgua6a.txt")
        if code then loadstring(code)() end
    end},
    {Id = 4924922222, Name = "v1", Exec = function()
        local code = httpGet("https://files.catbox.moe/z2z5hg.txt")
        if code then loadstring(code)() end
    end}
}

local function runIt()
    local found = false
    for _, v in ipairs(Function) do
        if game.PlaceId == v.Id then
            found = true
            Notify("Supported game detected, loading...", Color3.fromRGB(0,170,90), 2)
            sDelay(0.8, function() pcall(function() v.Exec() end) end)
            break
        end
    end
    if not found then
        local P = Instance.new("Frame", Gui)
        P.Size = UDim2.new(0,400,0,180)
        P.Position = UDim2.new(0.5,-200,0.5,-90)
        P.BackgroundColor3 = Color3.fromRGB(30,30,30)
        P.BorderSizePixel = 0
        corner(P, 12)

        local M = Instance.new("TextLabel", P)
        M.Size = UDim2.new(0.9,0,0.5,0)
        M.Position = UDim2.new(0.05,0,0.12,0)
        M.BackgroundTransparency = 1
        M.Text = "This game isn't supported."
        M.TextColor3 = Color3.fromRGB(255,255,255)
        M.TextScaled = true
        M.Font = Enum.Font.GothamBold
        M.TextWrapped = true

        local Y = Instance.new("TextButton", P)
        Y.Size = UDim2.new(0.4,0,0,50)
        Y.Position = UDim2.new(0.05,0,0.65,0)
        Y.BackgroundColor3 = Color3.fromRGB(0,170,90)
        Y.Text = "alright"
        Y.TextScaled = true
        Y.Font = Enum.Font.GothamBold
        Y.TextColor3 = Color3.fromRGB(255,255,255)
        corner(Y, 10)

        local N = Instance.new("TextButton", P)
        N.Size = UDim2.new(0.4,0,0,50)
        N.Position = UDim2.new(0.55,0,0.65,0)
        N.BackgroundColor3 = Color3.fromRGB(200,50,50)
        N.Text = "ok"
        N.TextScaled = true
        N.Font = Enum.Font.GothamBold
        N.TextColor3 = Color3.fromRGB(255,255,255)
        corner(N, 10)

        Y.MouseButton1Click:Connect(function()
            Notify("Launching Command Bar...", Color3.fromRGB(0,120,200), 2)
            P:Destroy()
            sDelay(0.5, function() print("User accepted popup") end)
        end)
        N.MouseButton1Click:Connect(function()
            Notify("Okay. Closing.", Color3.fromRGB(120,120,120), 1.5)
            P:Destroy()
            sDelay(0.5, function() Gui:Destroy() end)
        end)
    end
end

-- button logic
BtnEnter.MouseButton1Click:Connect(function()
    local now = os.time() + (tick() or 0)
    if enterStart == 0 then enterStart = now end
    if (now - enterStart) < MIN_ENTER then
        Notify("Wait a moment before entering key.", Color3.fromRGB(255,170,0), 2)
        return
    end
    if type(Box.Text) ~= "string" or #Box.Text < 6 then
        Notify("Invalid key format.", Color3.fromRGB(200,0,0), 2)
        return
    end
    if verify(Box.Text) then
        Notify("Access Granted", Color3.fromRGB(0,170,90), 2)
        sDelay(0.25, function()
            pcall(function() Gui:ClearAllChildren() end)
            local L = Instance.new("TextLabel", Gui)
            L.Size = UDim2.new(0,300,0,100)
            L.Position = UDim2.new(0.5,-150,0.5,-50)
            L.BackgroundColor3 = Color3.fromRGB(255,255,255)
            L.BackgroundTransparency = 0.15
            L.TextColor3 = Color3.fromRGB(0,70,130)
            L.Font = Enum.Font.GothamBold
            L.TextScaled = true
            corner(L, 12)
            L.Text = "Loading..."
            sDelay(1.2, function() runIt() end)
        end)
    else
        Notify("Wrong Key!", Color3.fromRGB(200,0,0), 2)
    end
end)

BtnGet.MouseButton1Click:Connect(function()
    if type(setclipboard) == "function" then
        pcall(function() setclipboard("https://discord.gg/mPMyz3rB2J") end)
        Notify("Key link copied!", Color3.fromRGB(80,160,230), 2)
    else
        Notify("Clipboard not available. Visit: discord.gg/mPMyz3rB2J", Color3.fromRGB(80,160,230), 3)
    end
end)

-- clear sensitive memory after 30s
sDelay(30, function()
    Key = nil
    Secret = nil
    local scramble = ""
    for i = 1, 16 do scramble = scramble .. string.char(math.random(32,126)) end
    getgenv()[Var] = scramble
end)
spawn(function()
    while true do
        sWait(4)
        if not Gui or not Gui.Parent then
            print("KeySystem GUI removed unexpectedly.")
            break
        end
    end
end)
