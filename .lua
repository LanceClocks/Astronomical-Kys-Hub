-- Load necessary libraries
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Revenant", true))()
local Flags = Library.Flags

-- Load AntiChatLogger with error handling
local success, AntiChatLogger = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AnthonyIsntHere/anthonysrepository/main/scripts/AntiChatLogger.lua", true))()
end)

if not success then
    warn("Failed to load AntiChatLogger: " .. AntiChatLogger)
end

-- Initialize Services
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to check if the game environment is valid
local function isEnvironmentValid()
    return game:IsLoaded() and players and replicatedStorage
end

-- Wait for the game to load
local function waitForGameLoaded()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(5) -- Additional wait to ensure everything is loaded
end

-- Function to safely execute a function with error handling
local function safeExecution(func)
    local success, err = xpcall(func, function(err) return debug.traceback(err) end)
    if not success then
        warn("Error during execution: " .. err)
    end
end

-- Create the GUI
local mainUI = Library:CreateWindow("Astronomical Kys Hub")
local spamTab = mainUI:CreateTab("Spam")
local espTab = mainUI:CreateTab("ESP")
local spinbotTab = mainUI:CreateTab("Spinbot")
local creditsTab = mainUI:CreateTab("Credits")

-- Initialize Variables
local isSpamActive = false
local zombies = {} -- Table to hold zombie instances

-- Function to initialize spam feature
local function initSpam()
    local spamInput = spamTab:CreateInput("Message to Spam", function(text)
        Flags.SpamMessage = text
    end)

    spamTab:CreateButton("Start Spamming", function()
        if Flags.SpamMessage and #Flags.SpamMessage > 0 then
            isSpamActive = true
            spawn(function()
                while isSpamActive do
                    game.ReplicatedStorage.DefaultChatSystemChat:Chat(character.Head, Flags.SpamMessage, Enum.ChatColor.Red)
                    task.wait(1) -- Delay between spams
                end
            end)
        else
            warn("Please enter a message to spam.")
        end
    end)

    spamTab:CreateButton("Stop Spamming", function()
        isSpamActive = false
    end)
end

-- Function to toggle ESP for players and zombies
local function toggleESP(enabled)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:find("Zombies") or obj:IsA("Player")) then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = obj:FindFirstChild("Head") -- Assuming all have a Head
            highlight.Enabled = enabled
            highlight.Parent = obj
        end
    end
end

-- Initialize ESP feature
local function initESP()
    espTab:CreateToggle("Toggle ESP", function(state)
        toggleESP(state)
    end)
end

-- Initialize Spinbot feature
local function initSpinbot()
    spinbotTab:CreateInput("Spin Speed", function(speed)
        Flags.SpinSpeed = tonumber(speed) or 10 -- Default to 10 if invalid input
    end)

    spinbotTab:CreateButton("Start Spinbot", function()
        spawn(function()
            while true do
                if character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Flags.SpinSpeed or 10), 0)
                end
                task.wait(0.1) -- Adjust this for spin speed
            end
        end)
    end)
end

-- Initialize Credits Tab
local function initCredits()
    creditsTab:CreateLabel("Nice Stupid Retarded Hub For You Guys")
    creditsTab:CreateLabel("Made by: LanceClocks")
    creditsTab:CreateLabel("Discord: LanceClocks")
end

-- Function to track zombies
local function trackZombies()
    for _, obj in pairs(workspace:GetChildren()) do
        if string.match(obj.Name, "Zombies") then
            table.insert(zombies, obj)
        end
    end
end

-- Cleanup function for zombies
local function cleanupZombies()
    for _, zombie in pairs(zombies) do
        if zombie then
            zombie:Destroy()
        end
    end
end

-- Connect to game events (Example: Player added)
players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        safeExecution(trackZombies)
    end)
end)

-- Initialize all features
local function initialize()
    if not isEnvironmentValid() then
        warn("Environment is not valid, aborting script.")
        return
    end

    waitForGameLoaded()
    initSpam()
    initESP()
    initSpinbot()
    initCredits()
    trackZombies()

    task.wait(5) -- Ensure smooth loading
end

-- Execute initialization safely
spawn(function()
    safeExecution(initialize)
end)

-- Add Environment Check
if not isEnvironmentValid() then
    warn("The environment is not suitable for running the script.")
end
