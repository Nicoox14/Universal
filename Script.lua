-- Roblox Cheat GUI Script using Fatality UI Library
-- Load Fatality Library
-- NOTE: If you have the source.luau file locally, you can replace the URL with your own hosting
-- or use: local Fatality = loadstring(readfile("path/to/source.luau"))()
local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
local Notification = Fatality:CreateNotifier()

-- Get services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- Function to check if a player is a teammate
local function IsTeammate(player)
    if player == LocalPlayer then
        return true
    end
    
    -- Check if teams are enabled in the game
    local localTeam = LocalPlayer.Team
    local playerTeam = player.Team
    
    -- If teams are enabled and both players have teams
    if localTeam and playerTeam then
        -- If both are on the same team, they are teammates
        if localTeam == playerTeam then
            return true
        end
        -- If teams are different, they are enemies
        return false
    end
    
    -- If teams are not enabled or one player doesn't have a team, check TeamColor
    local localTeamColor = LocalPlayer.TeamColor
    local playerTeamColor = player.TeamColor
    
    if localTeamColor and playerTeamColor then
        if localTeamColor == playerTeamColor then
            return true
        end
        return false
    end
    
    -- If no team system is found, treat all players as enemies (not teammates)
    return false
end

-- Helper function to check if player still exists in game (more reliable than FindFirstChild)
local function PlayerStillExists(player)
    if not player then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if p == player then
            return true
        end
    end
    return false
end

-- Update character when respawning
LocalPlayer.CharacterAdded:Connect(function(character)
    Character = character
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Show loader
Fatality:Loader({
    Name = "Catality",
    Duration = 2
})

-- Create window
local Window = Fatality.new({
    Name = "Catality",
    Expire = "never",
})

-- Create tabs (menus)
local AimbotTab = Window:AddMenu({
    Name = "AIMBOT",
    Icon = "target"
})

local VisualsTab = Window:AddMenu({
    Name = "VISUALS",
    Icon = "eye"
})

local PlayerTab = Window:AddMenu({
    Name = "PLAYER",
    Icon = "user"
})

local ExploitsTab = Window:AddMenu({
    Name = "EXPLOITS",
    Icon = "settings"
})

local LocalTab = Window:AddMenu({
    Name = "LOCAL",
    Icon = "user-circle"
})

local MiscTab = Window:AddMenu({
    Name = "MISC",
    Icon = "settings"
})

-- Variables for aimbot
local AimbotEnabled = false
local AimbotFOV = 100
local AimbotMode = "Camera"
local AimbotSmoothness = 0.5
local AimbotFOVColor = Color3.fromRGB(255, 0, 0)
local AimbotKey = Enum.KeyCode.E
local AimbotUseMouse = false
local AimbotMouseButton = Enum.UserInputType.MouseButton1
local AimbotTargetPart = "Head"
local AimbotLockDistance = 1500  -- Maximum lock distance in studs
local AimbotConnection = nil
local FOVCircle = nil
local FOVCircleConnection = nil

-- Variables for ESP
local BoxESPEnabled = false
local BoxESPColor = Color3.fromRGB(255, 0, 0)
local CornerBoxESPEnabled = false
local CornerBoxESPColor = Color3.fromRGB(255, 0, 0)
local SkeletonESPEnabled = false
local SkeletonESPColor = Color3.fromRGB(255, 255, 255)
local ChamsEnabled = false
local ChamsColor = Color3.fromRGB(255, 0, 0)
local ChamsRainbowEnabled = false
local ChamsRainbowConnection = nil
local NameESPEnabled = false
local NameESPColor = Color3.fromRGB(255, 255, 255)
local DistanceESPEnabled = false
local DistanceESPColor = Color3.fromRGB(255, 255, 255)
local TracersEnabled = false
local TracersColor = Color3.fromRGB(255, 0, 0)

local ESPBoxes = {}
local CornerBoxes = {}
local SkeletonLines = {}
local ChamsParts = {}
local NameLabels = {}
local DistanceLabels = {}
local TracerLines = {}
local ESPConnection = nil
local PlayerAddedConnection = nil
local PlayerRemovingConnection = nil

-- Variables for Camera features
local ThirdPersonEnabled = false
local ThirdPersonDistance = 10
local ThirdPersonKey = Enum.KeyCode.E
local CameraFieldOfView = 80
local CameraChangeFieldOfViewInScope = false
local ViewmodelChangerEnabled = false
local ViewmodelAngleX = 180
local ViewmodelAngleY = 180
local ViewmodelAngleZ = 180
local ViewmodelCFrameX = 180
local ViewmodelCFrameY = 180
local ViewmodelCFrameZ = 180
local RemoveFlashEnabled = false
local ViewmodelConnection = nil

-- Variables for Sounds
local HitsoundsEnabled = false
local HitsoundsVolume = 100
local HitsoundsSound = "Neverlose"
local KillsoundsEnabled = false
local KillsoundsVolume = 100
local KillsoundsSound = "Neverlose"

-- Sound IDs mapping
local soundIDs = {
    ["Neverlose"] = "6607204501",
    ["Skeet"] = "5447626464",
    ["Rust"] = "5043539486",
    ["Monster kill"] = "",
    ["Fatality"] = "115982072912004",
    ["TF2"] = "3455144981",
    ["TF2 Pan"] = "3431749479",
    ["Beautiful"] = "5709456554",
    ["Minecraft"] = "7273736372",
    ["Minecraft XP"] = "1053296915",
    ["Cod"] = "160432334",
    ["Ray"] = "131179973",
    ["Matchine gun"] = "17705555617",
    ["Retro loud"] = "3976061026",
    ["CSGO"] = "7269900245",
    ["Slap"] = "4888372697",
    ["Squash"] = "3466981613",
    ["Supersmash"] = "2039907664",
    ["Killingspree"] = "937898383",
    ["Godlike"] = "7463103082",
    ["Ownage"] = "6887181639",
    ["Ultrakill"] = "937885646",
    ["1"] = "7349055654",
    ["MCOOF"] = "5869422451",
    ["Quek"] = "4868633804",
    ["Epic"] = "7344303740",
    ["Osu"] = "7149919358",
    ["Bell"] = "97724019712141",
    ["Rocket"] = "9087976483",
    ["Vine Boom"] = "9088081730",
    ["Pow"] = "3516546035",
    ["Bag"] = "364942410",
    ["Baimware"] = "6607339542",
    ["Overwatch"] = "18410058858",
    ["Pop"] = "105543133746827",
    ["Win"] = "341542437",
    ["Denied"] = "7356986865",
    ["Lessgo"] = "6782594987",
    ["Headshot"] = "5764885927",
    ["Bruh"] = "535690488",
    ["Percussion"] = "3466985670",
    ["Bass"] = "12221944",
    ["Electro"] = "3458224686",
    ["Vortex"] = "3466980212",
    ["Retro"] = "3466984142",
    ["Osu Mint"] = "81883450827543",
    ["Snap"] = "93172144688075"
}

-- Variables for Atmosphere
local AmbienceEnabled = false
local AmbienceColor = Color3.fromRGB(255, 255, 255)
local ForceTimeEnabled = false
local ForceTimeValue = 1
local CustomSaturationEnabled = false
local CustomSaturationColor = Color3.fromRGB(255, 255, 255)
local CustomSaturationModifier = 0
local CustomBloomEnabled = false
local CustomBloomIntensity = 0
local CustomBloomSize = 0
local CustomBloomThreshold = 0
local CustomAtmosphereEnabled = false
local CustomAtmosphereColor1 = Color3.fromRGB(255, 255, 255)
local CustomAtmosphereColor2 = Color3.fromRGB(255, 255, 255)
local CustomAtmosphereDensity = 0
local CustomAtmosphereGlaze = 0
local CustomAtmosphereHaze = 0
local CustomBrightnessEnabled = false
local CustomBrightnessMode = "Fullbright"

-- Variables for Movement
local SlideWalkEnabled = false
local SpeedHackEnabled = false
local SpeedHackMethod = "Velocity"
local SpeedHackSpeed = 16
local AutoHopEnabled = false
local OverrideSpeedHackEnabled = false
local OverrideSpeedHackSpeed = 25
local OverrideSpeedHackKey = Enum.KeyCode.E
local MovementConnection = nil
local AutoHopConnection = nil
local SlideWalkConnection = nil

-- Variables for Exploits
local SpinBotEnabled = false
local SpinBotSpeed = 20
local SelfChamsEnabled = false
local SelfChamsColor = Color3.fromRGB(255, 0, 255)
local ViewmodelChamsEnabled = false
local ViewmodelChamsColor = Color3.fromRGB(0, 255, 255)
local ViewmodelChamsRainbowEnabled = false
local ViewmodelChamsRainbowConnection = nil
local ViewmodelChamsOriginalColors = {}  -- Store original colors globally
local ThirdPersonEnabled = false
local ThirdPersonToggleEnabled = false  -- Tracks if toggle is enabled
local ThirdPersonDistance = 10
local ThirdPersonKey = Enum.KeyCode.E
local RejoinEnabled = false
local SelfChamsHighlights = {}
local ViewmodelChamsHighlights = {}
local ViewmodelChamsConnection = nil
local ThirdPersonConnection = nil
local SpinBotConnection = nil
local ShootThroughWallEnabled = false
local ShootThroughWallToggleEnabled = false  -- Tracks if toggle is enabled
local ShootThroughWallKey = Enum.KeyCode.X
local ShootThroughWallDistance = 2  -- Distance to move camera forward in studs
local ShootThroughWallConnection = nil
local HitboxExpanderEnabled = false
local HitboxExpanderSize = 6.5  -- Multiplier for hitbox size (1.5 = 50% larger)
local HitboxExpanderConnection = nil
local OriginalHitboxSizes = {}  -- Store original sizes
local OriginalTransparency = {}  -- Store original transparency
local NoSpreadEnabled = false
local NoSpreadConnection = nil

-- Variables for Local Chams
local WeaponChamsEnabled = false
local WeaponChamsColor = Color3.fromRGB(255, 255, 255)
local WeaponChamsMaterial = "Ghost"
local WeaponChamsTexture = "off"
local WeaponChamsTransparency = 1
local WeaponChamsReflectance = 1

local ArmsChangerEnabled = false
local ArmsChangerColor1 = Color3.fromRGB(255, 255, 255)
local ArmsChangerColor2 = Color3.fromRGB(255, 255, 255)
local ArmsChangerMaterial = "Ghost"
local ArmsChangerTexture = "off"
local ArmsTransparency = 1
local SleeveTransparency = 1
local ArmsReflectance = 1
local SleeveReflectance = 1

local CharacterChamsEnabled = false
local CharacterChamsColor = Color3.fromRGB(255, 255, 255)
local CharacterChamsMaterial = "Ghost"
local CharacterChamsTexture = "off"
local CharacterChamsTransparency = 1

-- Variables for Scope Mods
local RemoveScopeEnabled = false
local ChangeScopeEnabled = false
local ChangeScopeType = "ahueno"

-- Variables for Health Bar ESP
local HealthBarESPEnabled = false
local HealthBarESPColor1 = Color3.fromRGB(0, 255, 0)
local HealthBarESPColor2 = Color3.fromRGB(0, 255, 0)
local HealthBarESPGradient = false
local HealthBarLabels = {}
local HealthBarOutlines = {}

-- Local Chams Helper Tables
local forcefieldanimations = {
    ["off"] = "rbxassetid://0",
    ["web"] = "rbxassetid://301464986",
    ["webbed"] = "rbxassetid://2179243880",
    ["scanning"] = "rbxassetid://5843010904",
    ["pixelated"] = "rbxassetid://140652787",
    ["swirl"] = "rbxassetid://8133639623",
    ["checkerboard"] = "rbxassetid://5790215150",
    ["christmas"] = "rbxassetid://6853532738",
    ["player"] = "rbxassetid://4494641460",
    ["shield"] = "rbxassetid://361073795",
    ["dots"] = "rbxassetid://5830615971",
    ["bubbles"] = "rbxassetid://1461576423",
    ["matrix"] = "rbxassetid://10713189068",
    ["honeycomb"] = "rbxassetid://179898251",
    ["groove"] = "rbxassetid://10785404176",
    ["cloud"] = "rbxassetid://5176277457",
    ["sky"] = "rbxassetid://1494603972",
    ["smudge"] = "rbxassetid://6096634060",
    ["scrapes"] = "rbxassetid://6248583558",
    ["galaxy"] = "rbxassetid://1120738433",
    ["galaxies"] = "rbxassetid://5101923607",
    ["stars"] = "rbxassetid://598201818",
    ["rainbow"] = "rbxassetid://10037165803",
    ["wires"] = "rbxassetid://14127933",
    ["camo"] = "rbxassetid://3280937154",
    ["hexagon"] = "rbxassetid://6175083785",
    ["particles"] = "rbxassetid://1133822388",
    ["triangular"] = "rbxassetid://4504368932",
    ["wall"] = "rbxassetid://4271279"
}

local forcefieldAnimationsDropDown = {}
for i, v in pairs(forcefieldanimations) do
    local okay = {i, i == "off" and true or false}
    table.insert(forcefieldAnimationsDropDown, okay)
end

local materials = {
    ["Ghost"] = Enum.Material.ForceField,
    ["Flat"] = Enum.Material.Neon,
    ["Custom"] = Enum.Material.SmoothPlastic,
    ["Reflective"] = Enum.Material.Glass,
    ["Metallic"] = Enum.Material.Metal
}

local chammedobjects = {
    ["Clothing"] = {},
    ["Arms"] = {},
    ["Weapon Objects"] = {},
    ["Colored Arms"] = {},
    ["Colored Weapons"] = {},
    ["Original"] = {}
}


-- ========== AIMBOT TAB ==========
do
    -- Basic Settings Section
    local BasicSection = AimbotTab:AddSection({
        Position = 'left',
        Name = "BASIC SETTINGS"
    })

    -- Targeting Section
    local TargetingSection = AimbotTab:AddSection({
        Position = 'center',
        Name = "TARGETING"
    })

    -- Advanced Settings Section
    local AdvancedSection = AimbotTab:AddSection({
        Position = 'right',
        Name = "ADVANCED SETTINGS"
    })

    BasicSection:AddToggle({
        Name = "Enable Aimbot",
        Default = false,
        Callback = function(Value)
            AimbotEnabled = Value
            if Value then
                StartAimbot()
            else
                StopAimbot()
            end
        end,
    })

    BasicSection:AddKeybind({
        Name = "Aimbot Key",
        Default = "E",
        Callback = function(Key)
            -- Fatality returns key as string (e.g., "E", "G", etc.)
            -- Convert string to KeyCode enum
            local newKey = nil
            
            if type(Key) == "string" then
                -- Convert to uppercase and try to get KeyCode
                local keyUpper = Key:upper()
                newKey = Enum.KeyCode[keyUpper]
            elseif typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
                newKey = Key
            end
            
            -- Update AimbotKey
            if newKey then
                AimbotKey = newKey
            else
                -- Fallback to E if key not found
                AimbotKey = Enum.KeyCode.E
            end
        end,
    })

    BasicSection:AddToggle({
        Name = "Use Mouse Button",
        Default = false,
        Callback = function(Value)
            AimbotUseMouse = Value
        end,
    })

    BasicSection:AddDropdown({
        Name = "Mouse Button",
        Values = {"Left Mouse", "Right Mouse", "Middle Mouse"},
        Default = "Left Mouse",
        Callback = function(Value)
            local mouseValue = Value
            if type(Value) == "table" then
                mouseValue = Value[1] or "Left Mouse"
            elseif type(Value) ~= "string" then
                mouseValue = "Left Mouse"
            end
            
            if mouseValue == "Left Mouse" then
                AimbotMouseButton = Enum.UserInputType.MouseButton1
            elseif mouseValue == "Right Mouse" then
                AimbotMouseButton = Enum.UserInputType.MouseButton2
            elseif mouseValue == "Middle Mouse" then
                AimbotMouseButton = Enum.UserInputType.MouseButton3
            end
        end,
    })

    BasicSection:AddDropdown({
        Name = "Aimbot Mode",
        Values = {"Camera", "Mouse"},
        Default = "Camera",
        Callback = function(Value)
            if type(Value) == "table" then
                AimbotMode = Value[1] or "Camera"
            elseif type(Value) == "string" then
                AimbotMode = Value
            else
                AimbotMode = "Camera"
            end
        end,
    })

    TargetingSection:AddDropdown({
        Name = "Aim Target",
        Values = {"Head", "Torso"},
        Default = "Head",
        Callback = function(Value)
            if type(Value) == "table" then
                AimbotTargetPart = Value[1] or "Head"
            elseif type(Value) == "string" then
                AimbotTargetPart = Value
            else
                AimbotTargetPart = "Head"
            end
        end,
    })

    AdvancedSection:AddSlider({
        Name = "FOV",
        Min = 0,
        Max = 500,
        Default = 100,
        Type = " Studs",
        Callback = function(Value)
            AimbotFOV = Value
            UpdateFOVCircle()
        end,
    })

    AdvancedSection:AddSlider({
        Name = "Smoothness",
        Min = 0,
        Max = 1,
        Round = 2,
        Default = 0.5,
        Type = "",
        Callback = function(Value)
            AimbotSmoothness = Value
        end,
    })

    AdvancedSection:AddSlider({
        Name = "Lock Distance",
        Min = 50,
        Max = 1500,
        Default = 1500,
        Type = " Studs",
        Callback = function(Value)
            AimbotLockDistance = Value
        end,
    })

    AdvancedSection:AddColorPicker({
        Name = "FOV Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            AimbotFOVColor = Value
            UpdateFOVCircle()
        end
    })
end

-- Function to create FOV circle
function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    if FOVCircleConnection then
        FOVCircleConnection:Disconnect()
        FOVCircleConnection = nil
    end
    
    local Drawing = Drawing.new("Circle")
    Drawing.Visible = true
    Drawing.Transparency = 1
    Drawing.Color = AimbotFOVColor
    Drawing.Thickness = 2
    Drawing.NumSides = 100
    Drawing.Radius = AimbotFOV
    Drawing.Filled = false
    Drawing.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    FOVCircle = Drawing
    
    -- Update circle position on camera movement
    FOVCircleConnection = RunService.RenderStepped:Connect(function()
        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
end

function UpdateFOVCircle()
    if FOVCircle then
        FOVCircle.Radius = AimbotFOV
        FOVCircle.Color = AimbotFOVColor
    end
end

-- Function to get closest player to crosshair
function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    -- Get local player position for distance calculation
    local localCharacter = LocalPlayer.Character
    local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHumanoidRootPart then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        -- Skip local player and teammates
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                -- Calculate 3D distance from local player to target player
                local worldDistance = (humanoidRootPart.Position - localHumanoidRootPart.Position).Magnitude
                
                -- Check if player is within lock distance limit
                if worldDistance <= AimbotLockDistance then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    if onScreen then
                        local centerX = Camera.ViewportSize.X / 2
                        local centerY = Camera.ViewportSize.Y / 2
                        local screenDistance = math.sqrt((screenPoint.X - centerX)^2 + (screenPoint.Y - centerY)^2)
                        
                        if screenDistance <= AimbotFOV and screenDistance < closestDistance then
                            closestDistance = screenDistance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Function to aim at target
function AimAtTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    -- Get the target part based on selection
    local targetPart = nil
    local selectedPart = AimbotTargetPart or "Head" -- Default to Head
    
    -- Extract string from table if needed
    if type(selectedPart) == "table" then
        selectedPart = selectedPart.Name or selectedPart[1] or "Head"
    end
    
    -- Try to find the selected part
    if selectedPart == "Head" then
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    elseif selectedPart == "Torso" then
        -- Try UpperTorso first, then LowerTorso, then HumanoidRootPart
        targetPart = targetPlayer.Character:FindFirstChild("UpperTorso") 
            or targetPlayer.Character:FindFirstChild("LowerTorso")
            or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    
    -- Fallback to Head if selected part doesn't exist
    if not targetPart then
        targetPart = targetPlayer.Character:FindFirstChild("Head")
    end
    
    if not targetPart then return end
    
    local cameraCFrame = Camera.CFrame
    local targetPosition = targetPart.Position
    local cameraPosition = cameraCFrame.Position
    
    -- Calculate direction to target
    local direction = targetPosition - cameraPosition
    if direction.Magnitude < 0.1 then return end -- Too close
    
    local targetLookVector = direction.Unit
    
    -- Get current camera look vector
    local currentLookVector = cameraCFrame.LookVector
    
    -- Smooth interpolation (niedrige Smoothness = insta lock, hohe Smoothness = wenig lock)
    -- Smoothness 0 = insta lock, Smoothness 1 = sehr langsam
    local lerpValue = 1 - AimbotSmoothness
    if lerpValue < 0.01 then lerpValue = 0.01 end
    if lerpValue > 1 then lerpValue = 1 end
    
    -- Lerp between current and target direction - always update to track moving targets
    local smoothLookVector = currentLookVector:Lerp(targetLookVector, lerpValue)
    
    -- Normalize the smooth look vector to ensure proper direction
    smoothLookVector = smoothLookVector.Unit
    
    -- Check aimbot mode (extract string from table if needed)
    local currentAimbotMode = AimbotMode
    if type(currentAimbotMode) == "table" then
        currentAimbotMode = currentAimbotMode.Name or currentAimbotMode[1] or "Camera"
    elseif type(currentAimbotMode) ~= "string" then
        currentAimbotMode = "Camera"
    end
    
    if currentAimbotMode == "Mouse" then
        -- Mouse mode: Use mousemoverel for direct mouse movement (from Open Aimbot)
        if getfenv().mousemoverel then
            local targetScreenPoint, onScreen = Camera:WorldToViewportPoint(targetPosition)
            
            if onScreen then
                local MouseLocation = UserInputService:GetMouseLocation()
                -- Calculate sensitivity: Lower smoothness = stronger lock, higher smoothness = weaker lock
                -- Smoothness 0 = Sensitivity 0.5 (very strong lock)
                -- Smoothness 1 = Sensitivity 100 (very weak lock)
                local Sensitivity = 0.5 + (AimbotSmoothness * 99.5)
                
                -- Move mouse relative to current position
                getfenv().mousemoverel(
                    (targetScreenPoint.X - MouseLocation.X) / Sensitivity,
                    (targetScreenPoint.Y - MouseLocation.Y) / Sensitivity
                )
            end
        else
            -- Fallback to Camera mode if mousemoverel is not available
            local newCFrame = CFrame.lookAt(cameraPosition, cameraPosition + smoothLookVector * direction.Magnitude)
            Camera.CFrame = newCFrame
        end
    else
        -- Camera mode: Directly set camera CFrame
        local newCFrame = CFrame.lookAt(cameraPosition, cameraPosition + smoothLookVector * direction.Magnitude)
        Camera.CFrame = newCFrame
    end
end

-- Function to start aimbot
function StartAimbot()
    if AimbotConnection then 
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    
    CreateFOVCircle()
    
    -- Use RenderStepped and check key state directly - more reliable
    AimbotConnection = RunService.RenderStepped:Connect(function()
        -- Check if key/mouse button is pressed
        local keyDown = false
        
        -- Check if mouse button should be used
        if AimbotUseMouse then
            -- Use mouse button
            if AimbotMouseButton == Enum.UserInputType.MouseButton1 then
                keyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif AimbotMouseButton == Enum.UserInputType.MouseButton2 then
                keyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            elseif AimbotMouseButton == Enum.UserInputType.MouseButton3 then
                keyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
            end
        else
            -- Use keyboard key
            -- Ensure AimbotKey is valid KeyCode
            if typeof(AimbotKey) ~= "EnumItem" or AimbotKey.EnumType ~= Enum.KeyCode then
                AimbotKey = Enum.KeyCode.E
            end
            
            local success, result = pcall(function()
                return UserInputService:IsKeyDown(AimbotKey)
            end)
            
            if success then
                keyDown = result
            end
        end
        
        if AimbotEnabled and keyDown then
            local closestPlayer = GetClosestPlayer()
            if closestPlayer then
                -- Always aim at target, even if already locked
                AimAtTarget(closestPlayer)
            end
        end
    end)
end

-- Function to stop aimbot
function StopAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    if FOVCircleConnection then
        FOVCircleConnection:Disconnect()
        FOVCircleConnection = nil
    end
end

-- ========== VISUALS TAB ==========
do
    local ESPSection = VisualsTab:AddSection({
        Position = 'left',
        Name = "ESP"
    })

    local InfoSection = VisualsTab:AddSection({
        Position = 'center',
        Name = "INFO"
    })

    local ColorsSection = VisualsTab:AddSection({
        Position = 'right',
        Name = "COLORS"
    })

    -- ESP Section: Only Toggles
    ESPSection:AddToggle({
        Name = "Box ESP",
        Default = false,
        Callback = function(Value)
            BoxESPEnabled = Value
            if Value then
                StartBoxESP()
            else
                StopBoxESP()
            end
        end,
    })

    ESPSection:AddToggle({
        Name = "Corner Box ESP",
        Default = false,
        Callback = function(Value)
            CornerBoxESPEnabled = Value
            if Value then
                StartCornerBoxESP()
            else
                StopCornerBoxESP()
            end
        end,
    })

    ESPSection:AddToggle({
        Name = "Skeleton ESP",
        Default = false,
        Callback = function(Value)
            SkeletonESPEnabled = Value
            if Value then
                StartSkeletonESP()
            else
                StopSkeletonESP()
            end
        end,
    })

    ESPSection:AddToggle({
        Name = "Tracers",
        Default = false,
        Callback = function(Value)
            TracersEnabled = Value
            if Value then
                StartTracers()
            else
                StopTracers()
            end
        end,
    })

    ESPSection:AddToggle({
        Name = "Chams",
        Default = false,
        Callback = function(Value)
            ChamsEnabled = Value
            if Value then
                StartChams()
                if ChamsRainbowEnabled then
                    StartChamsRainbow()
                end
            else
                StopChams()
                StopChamsRainbow()
            end
        end,
    })

    ESPSection:AddToggle({
        Name = "Health Bar",
        Default = false,
        Callback = function(Value)
            HealthBarESPEnabled = Value
            if Value then
                StartHealthBarESP()
            else
                StopHealthBarESP()
            end
        end,
    })

    -- Info Section: Name and Distance Toggles
    InfoSection:AddToggle({
        Name = "Name ESP",
        Default = false,
        Callback = function(Value)
            NameESPEnabled = Value
            if Value then
                StartNameESP()
            else
                StopNameESP()
            end
        end,
    })

    InfoSection:AddToggle({
        Name = "Distance ESP",
        Default = false,
        Callback = function(Value)
            DistanceESPEnabled = Value
            if Value then
                StartDistanceESP()
            else
                StopDistanceESP()
            end
        end,
    })

    -- Colors Section: All Color Pickers in order
    ColorsSection:AddColorPicker({
        Name = "Box ESP Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            BoxESPColor = Value
            UpdateESPBoxes()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Corner Box ESP Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            CornerBoxESPColor = Value
            UpdateCornerBoxes()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Skeleton ESP Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            SkeletonESPColor = Value
            UpdateSkeletonESPColors()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Tracers Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            TracersColor = Value
            UpdateTracers()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Chams Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            ChamsColor = Value
            UpdateChams()
        end
    })

    ColorsSection:AddToggle({
        Name = "Chams Rainbow (RGB)",
        Default = false,
        Callback = function(Value)
            ChamsRainbowEnabled = Value
            if Value then
                if ChamsEnabled then
                    StartChamsRainbow()
                end
            else
                StopChamsRainbow()
            end
        end,
    })

    ColorsSection:AddColorPicker({
        Name = "Name ESP Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            NameESPColor = Value
            UpdateNameESPColors()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Distance ESP Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            DistanceESPColor = Value
            UpdateDistanceESPColors()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Health Bar Color 1",
        Default = Color3.fromRGB(0, 255, 0),
        Callback = function(Value)
            HealthBarESPColor1 = Value
            UpdateHealthBarESPColors()
        end
    })

    ColorsSection:AddColorPicker({
        Name = "Health Bar Color 2",
        Default = Color3.fromRGB(0, 255, 0),
        Callback = function(Value)
            HealthBarESPColor2 = Value
            UpdateHealthBarESPColors()
        end
    })

    ColorsSection:AddToggle({
        Name = "Health Bar Gradient",
        Default = false,
        Callback = function(Value)
            HealthBarESPGradient = Value
            UpdateHealthBarESPColors()
        end,
    })

end

-- ========== LOCAL TAB ==========
do
    local WeaponSection = LocalTab:AddSection({
        Position = 'left',
        Name = "WEAPON CHAMS"
    })

    local ArmsSection = LocalTab:AddSection({
        Position = 'center',
        Name = "ARMS CHANGER"
    })

    local CharacterSection = LocalTab:AddSection({
        Position = 'right',
        Name = "CHARACTER CHAMS"
    })

    -- Prepare texture options
    local weaponTextureOptions = {}
    for i, v in pairs(forcefieldAnimationsDropDown) do
        table.insert(weaponTextureOptions, v[1])
    end

    -- Weapon Chams Section
    WeaponSection:AddToggle({
        Name = "Weapon Chams",
        Default = false,
        Callback = function(Value)
            WeaponChamsEnabled = Value
            UpdateWeaponChams()
        end,
    })

    WeaponSection:AddColorPicker({
        Name = "Weapon Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            WeaponChamsColor = Value
            if WeaponChamsEnabled then
                UpdateWeaponChams()
            end
        end
    })

    WeaponSection:AddDropdown({
        Name = "Weapon Material",
        Values = {"Ghost", "Flat", "Custom", "Reflective", "Metallic"},
        Default = "Ghost",
        Callback = function(Value)
            if type(Value) == "table" then
                WeaponChamsMaterial = Value[1] or "Ghost"
            elseif type(Value) == "string" then
                WeaponChamsMaterial = Value
            else
                WeaponChamsMaterial = "Ghost"
            end
            if WeaponChamsEnabled then
                UpdateWeaponChams()
            end
        end,
    })

    WeaponSection:AddDropdown({
        Name = "Weapon Texture",
        Values = weaponTextureOptions,
        Default = "off",
        Callback = function(Value)
            if type(Value) == "table" then
                WeaponChamsTexture = Value[1] or "off"
            elseif type(Value) == "string" then
                WeaponChamsTexture = Value
            else
                WeaponChamsTexture = "off"
            end
            if WeaponChamsEnabled then
                UpdateWeaponChams()
            end
        end,
    })

    WeaponSection:AddSlider({
        Name = "Weapon Transparency",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            WeaponChamsTransparency = Value
            if WeaponChamsEnabled then
                UpdateWeaponChams()
            end
        end,
    })

    WeaponSection:AddSlider({
        Name = "Weapon Reflectance",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            WeaponChamsReflectance = Value
            if WeaponChamsEnabled then
                UpdateWeaponChams()
            end
        end,
    })

    -- Arms Changer Section
    ArmsSection:AddToggle({
        Name = "Arms Changer",
        Default = false,
        Callback = function(Value)
            ArmsChangerEnabled = Value
            UpdateArmChams()
        end,
    })

    ArmsSection:AddColorPicker({
        Name = "Arms Color 1",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            ArmsChangerColor1 = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end
    })

    ArmsSection:AddColorPicker({
        Name = "Arms Color 2",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            ArmsChangerColor2 = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end
    })

    ArmsSection:AddDropdown({
        Name = "Arms Material",
        Values = {"Ghost", "Flat", "Custom", "Reflective", "Metallic"},
        Default = "Ghost",
        Callback = function(Value)
            if type(Value) == "table" then
                ArmsChangerMaterial = Value[1] or "Ghost"
            elseif type(Value) == "string" then
                ArmsChangerMaterial = Value
            else
                ArmsChangerMaterial = "Ghost"
            end
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    ArmsSection:AddDropdown({
        Name = "Arms Texture",
        Values = weaponTextureOptions,
        Default = "off",
        Callback = function(Value)
            if type(Value) == "table" then
                ArmsChangerTexture = Value[1] or "off"
            elseif type(Value) == "string" then
                ArmsChangerTexture = Value
            else
                ArmsChangerTexture = "off"
            end
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    ArmsSection:AddSlider({
        Name = "Arms Transparency",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            ArmsTransparency = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    ArmsSection:AddSlider({
        Name = "Sleeve Transparency",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            SleeveTransparency = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    ArmsSection:AddSlider({
        Name = "Arms Reflectance",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            ArmsReflectance = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    ArmsSection:AddSlider({
        Name = "Sleeve Reflectance",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            SleeveReflectance = Value
            if ArmsChangerEnabled then
                UpdateArmChams()
            end
        end,
    })

    -- Character Chams Section
    CharacterSection:AddToggle({
        Name = "Character Chams",
        Default = false,
        Callback = function(Value)
            CharacterChamsEnabled = Value
            UpdateLocalPlayerChams()
        end,
    })

    CharacterSection:AddColorPicker({
        Name = "Character Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CharacterChamsColor = Value
            if CharacterChamsEnabled then
                UpdateLocalPlayerChams()
            end
        end
    })

    CharacterSection:AddDropdown({
        Name = "Character Material",
        Values = {"Ghost", "Flat", "Custom", "Reflective", "Metallic"},
        Default = "Ghost",
        Callback = function(Value)
            if type(Value) == "table" then
                CharacterChamsMaterial = Value[1] or "Ghost"
            elseif type(Value) == "string" then
                CharacterChamsMaterial = Value
            else
                CharacterChamsMaterial = "Ghost"
            end
            if CharacterChamsEnabled then
                UpdateLocalPlayerChams()
            end
        end,
    })

    CharacterSection:AddDropdown({
        Name = "Character Texture",
        Values = weaponTextureOptions,
        Default = "off",
        Callback = function(Value)
            if type(Value) == "table" then
                CharacterChamsTexture = Value[1] or "off"
            elseif type(Value) == "string" then
                CharacterChamsTexture = Value
            else
                CharacterChamsTexture = "off"
            end
            if CharacterChamsEnabled then
                UpdateLocalPlayerChams()
            end
        end,
    })

    CharacterSection:AddSlider({
        Name = "Character Transparency",
        Min = 0,
        Max = 100,
        Default = 1,
        Type = "",
        Callback = function(Value)
            CharacterChamsTransparency = Value
            if CharacterChamsEnabled then
                UpdateLocalPlayerChams()
            end
        end,
    })

end

-- ========== PLAYER TAB ==========
do
    local CameraSection = PlayerTab:AddSection({
        Position = 'left',
        Name = "CAMERA"
    })

    -- Camera Section
    CameraSection:AddToggle({
        Name = "Third Person",
        Default = false,
        Callback = function(Value)
            ThirdPersonToggleEnabled = Value  -- Track toggle state
            ThirdPersonEnabled = Value
            StartThirdPerson()
        end,
    })

    CameraSection:AddSlider({
        Name = "Third Person Distance",
        Min = 1,
        Max = 100,
        Default = 10,
        Type = " studs",
        Callback = function(Value)
            ThirdPersonDistance = Value
            if ThirdPersonEnabled then
                StartThirdPerson()
            end
        end,
    })

    CameraSection:AddKeybind({
        Name = "Third Person Key",
        Default = "E",
        Callback = function(Key)
            local newKey = nil
            if type(Key) == "string" then
                local keyUpper = Key:upper()
                newKey = Enum.KeyCode[keyUpper]
            elseif typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
                newKey = Key
            end
            if newKey then
                ThirdPersonKey = newKey
            else
                ThirdPersonKey = Enum.KeyCode.E
            end
        end,
    })

    CameraSection:AddSlider({
        Name = "Field of View",
        Min = 60,
        Max = 120,
        Default = 80,
        Type = "",
        Callback = function(Value)
            CameraFieldOfView = Value
            UpdateCameraFOV()
        end,
    })

    CameraSection:AddToggle({
        Name = "In Scope",
        Default = false,
        Callback = function(Value)
            CameraChangeFieldOfViewInScope = Value
        end,
    })

    CameraSection:AddToggle({
        Name = "Remove Flash",
        Default = false,
        Callback = function(Value)
            RemoveFlashEnabled = Value
            UpdateRemoveFlash()
        end,
    })

    local MovementSection = PlayerTab:AddSection({
        Position = 'center',
        Name = "MOVEMENT"
    })

    -- Movement Section
    MovementSection:AddToggle({
        Name = "Slide Walk",
        Default = false,
        Callback = function(Value)
            SlideWalkEnabled = Value
            if Value then
                StartSlideWalk()
            else
                StopSlideWalk()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Speed Hack",
        Default = false,
        Callback = function(Value)
            SpeedHackEnabled = Value
            if Value then
                StartSpeedHack()
            else
                StopSpeedHack()
            end
        end,
    })

    MovementSection:AddDropdown({
        Name = "Method",
        Values = {"Velocity", "CFrame"},
        Default = "Velocity",
        Callback = function(Value)
            if type(Value) == "table" then
                SpeedHackMethod = Value[1] or "Velocity"
            elseif type(Value) == "string" then
                SpeedHackMethod = Value
            else
                SpeedHackMethod = "Velocity"
            end
        end,
    })

    MovementSection:AddSlider({
        Name = "Speed",
        Min = 0,
        Max = 250,
        Default = 16,
        Type = "",
        Callback = function(Value)
            SpeedHackSpeed = Value
        end,
    })

    MovementSection:AddToggle({
        Name = "Auto Hop",
        Default = false,
        Callback = function(Value)
            AutoHopEnabled = Value
            if Value then
                StartAutoHop()
            else
                StopAutoHop()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Override Speed",
        Default = false,
        Callback = function(Value)
            OverrideSpeedHackEnabled = Value
        end,
    })

    MovementSection:AddSlider({
        Name = "Override Speed",
        Min = 0,
        Max = 250,
        Default = 25,
        Type = "",
        Callback = function(Value)
            OverrideSpeedHackSpeed = Value
        end,
    })

    MovementSection:AddKeybind({
        Name = "Override Key",
        Default = "E",
        Callback = function(Key)
            local newKey = nil
            if type(Key) == "string" then
                local keyUpper = Key:upper()
                newKey = Enum.KeyCode[keyUpper]
            elseif typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
                newKey = Key
            end
            if newKey then
                OverrideSpeedHackKey = newKey
            else
                OverrideSpeedHackKey = Enum.KeyCode.E
            end
        end,
    })

end

-- ========== EXPLOITS TAB ==========
do
    local ExploitsSection = ExploitsTab:AddSection({
        Position = 'left',
        Name = "EXPLOITS"
    })

    local SettingsSection = ExploitsTab:AddSection({
        Position = 'center',
        Name = "SETTINGS"
    })

    local ServerSection = ExploitsTab:AddSection({
        Position = 'right',
        Name = "SERVER"
    })

    -- Exploits Section
    ExploitsSection:AddToggle({
        Name = "Shoot Through Wall",
        Default = false,
        Callback = function(Value)
            ShootThroughWallToggleEnabled = Value  -- Track toggle state
            ShootThroughWallEnabled = Value
            if Value then
                StartShootThroughWall()
            else
                StopShootThroughWall()
            end
        end,
    })

    ExploitsSection:AddToggle({
        Name = "No Spread",
        Default = false,
        Callback = function(Value)
            NoSpreadEnabled = Value
            if Value then
                StartNoSpread()
            else
                StopNoSpread()
            end
        end,
    })

    ExploitsSection:AddToggle({
        Name = "Remove Scope",
        Default = false,
        Callback = function(Value)
            RemoveScopeEnabled = Value
            UpdateRemoveScope()
        end,
    })

    ExploitsSection:AddToggle({
        Name = "Change Scope",
        Default = false,
        Callback = function(Value)
            ChangeScopeEnabled = Value
            UpdateChangeScope()
        end,
    })

    ExploitsSection:AddDropdown({
        Name = "Select Scope",
        Values = {"ahueno", "pizdec", "porno"},
        Default = "ahueno",
        Callback = function(Value)
            if type(Value) == "table" then
                ChangeScopeType = Value[1] or "ahueno"
            elseif type(Value) == "string" then
                ChangeScopeType = Value
            else
                ChangeScopeType = "ahueno"
            end
            if ChangeScopeEnabled then
                UpdateChangeScope()
            end
        end,
    })

    -- Settings Section
    SettingsSection:AddSlider({
        Name = "STW Distance",
        Min = 0.5,
        Max = 10,
        Round = 1,
        Default = 2,
        Type = " Studs",
        Callback = function(Value)
            ShootThroughWallDistance = Value
        end,
    })

    SettingsSection:AddKeybind({
        Name = "STW Key",
        Default = "X",
        Callback = function(Key)
            local newKey = nil
            if type(Key) == "string" then
                local keyUpper = Key:upper()
                newKey = Enum.KeyCode[keyUpper]
            elseif typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
                newKey = Key
            end
            if newKey then
                ShootThroughWallKey = newKey
            else
                ShootThroughWallKey = Enum.KeyCode.X
            end
        end,
    })

    -- Server Section
    ServerSection:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end,
    })

    ServerSection:AddButton({
        Name = "Server Hop",
        Callback = function()
            local success, result = pcall(function()
                local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                local serverList = servers.data
                if #serverList > 1 then
                    local randomServer = serverList[math.random(2, #serverList)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, LocalPlayer)
                else
                    Notification:Notify({
                        Title = "Server Hop Failed",
                        Content = "No other servers found!",
                        Duration = 3,
                        Icon = "info"
                    })
                end
            end)
            if not success then
                Notification:Notify({
                    Title = "Server Hop Failed",
                    Content = "Could not find servers!",
                    Duration = 3,
                    Icon = "info"
                })
            end
        end,
    })

    ServerSection:AddButton({
        Name = "Copy Game ID",
        Callback = function()
            setclipboard(tostring(game.PlaceId))
            Notification:Notify({
                Title = "Game ID Copied!",
                Content = "Game ID: " .. game.PlaceId,
                Duration = 3,
                Icon = "clipboard"
            })
        end,
    })

end

-- ========== MISC TAB ==========
do
    local SoundsSection = MiscTab:AddSection({
        Position = 'left',
        Name = "SOUNDS"
    })

    local AtmosphereSection = MiscTab:AddSection({
        Position = 'center',
        Name = "ATMOSPHERE"
    })

    local SettingsSection = MiscTab:AddSection({
        Position = 'right',
        Name = "SETTINGS"
    })

    -- Sounds Section
    SoundsSection:AddToggle({
        Name = "Hitsounds",
        Default = false,
        Callback = function(Value)
            HitsoundsEnabled = Value
        end,
    })

    SoundsSection:AddSlider({
        Name = "Hitsounds Volume",
        Min = 1,
        Max = 100,
        Default = 100,
        Type = "",
        Callback = function(Value)
            HitsoundsVolume = Value
        end,
    })

    local hitsoundOptions = {"Neverlose", "Skeet", "Rust", "Monster kill", "Fatality", "TF2", "TF2 Pan", "Beautiful", "Minecraft", "Minecraft XP", "Cod", "Ray", "Matchine gun", "Retro loud", "CSGO", "Slap", "Squash", "Supersmash", "Killingspree", "Godlike", "Ownage", "Ultrakill", "1", "MCOOF", "Quek", "Epic", "Osu", "Bell", "Rocket", "Vine Boom", "Pow", "Bag", "Baimware", "Overwatch", "Pop", "Win", "Denied", "Lessgo", "Headshot", "Bruh", "Percussion", "Bass", "Electro", "Vortex", "Retro", "Osu Mint", "Snap"}

    SoundsSection:AddDropdown({
        Name = "Select Hitsound",
        Values = hitsoundOptions,
        Default = "Neverlose",
        Callback = function(Value)
            if type(Value) == "table" then
                HitsoundsSound = Value[1] or "Neverlose"
            elseif type(Value) == "string" then
                HitsoundsSound = Value
            else
                HitsoundsSound = "Neverlose"
            end
        end,
    })

    SoundsSection:AddToggle({
        Name = "Killsounds",
        Default = false,
        Callback = function(Value)
            KillsoundsEnabled = Value
        end,
    })

    SoundsSection:AddSlider({
        Name = "Killsounds Volume",
        Min = 1,
        Max = 100,
        Default = 100,
        Type = "",
        Callback = function(Value)
            KillsoundsVolume = Value
        end,
    })

    SoundsSection:AddDropdown({
        Name = "Select Killsound",
        Values = hitsoundOptions,
        Default = "Neverlose",
        Callback = function(Value)
            if type(Value) == "table" then
                KillsoundsSound = Value[1] or "Neverlose"
            elseif type(Value) == "string" then
                KillsoundsSound = Value
            else
                KillsoundsSound = "Neverlose"
            end
        end,
    })

    -- Atmosphere Section
    AtmosphereSection:AddToggle({
        Name = "Ambience",
        Default = false,
        Callback = function(Value)
            AmbienceEnabled = Value
            UpdateAmbience()
        end,
    })

    AtmosphereSection:AddColorPicker({
        Name = "Ambience Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            AmbienceColor = Value
            if AmbienceEnabled then
                UpdateAmbience()
            end
        end
    })

    AtmosphereSection:AddToggle({
        Name = "Force Time",
        Default = false,
        Callback = function(Value)
            ForceTimeEnabled = Value
        end,
    })

    AtmosphereSection:AddSlider({
        Name = "Time",
        Min = 0,
        Max = 24,
        Default = 1,
        Type = "",
        Callback = function(Value)
            ForceTimeValue = Value
            if ForceTimeEnabled then
                UpdateForceTime()
            end
        end,
    })

    AtmosphereSection:AddToggle({
        Name = "Custom Saturation",
        Default = false,
        Callback = function(Value)
            CustomSaturationEnabled = Value
            UpdateCustomSaturation()
        end,
    })

    AtmosphereSection:AddColorPicker({
        Name = "Saturation Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CustomSaturationColor = Value
            if CustomSaturationEnabled then
                UpdateCustomSaturation()
            end
        end
    })

    -- Settings Section
    SettingsSection:AddSlider({
        Name = "Saturation Modifier",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomSaturationModifier = Value
            if CustomSaturationEnabled then
                UpdateCustomSaturation()
            end
        end,
    })

    SettingsSection:AddToggle({
        Name = "Custom Bloom",
        Default = false,
        Callback = function(Value)
            CustomBloomEnabled = Value
            UpdateCustomBloom()
        end,
    })

    SettingsSection:AddSlider({
        Name = "Bloom Intensity",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomBloomIntensity = Value
            if CustomBloomEnabled then
                UpdateCustomBloom()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Bloom Size",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomBloomSize = Value
            if CustomBloomEnabled then
                UpdateCustomBloom()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Bloom Threshold",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomBloomThreshold = Value
            if CustomBloomEnabled then
                UpdateCustomBloom()
            end
        end,
    })

    SettingsSection:AddToggle({
        Name = "Custom Atmosphere",
        Default = false,
        Callback = function(Value)
            CustomAtmosphereEnabled = Value
            UpdateCustomAtmosphere()
        end,
    })

    SettingsSection:AddColorPicker({
        Name = "Atmosphere Color 1",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CustomAtmosphereColor1 = Value
            if CustomAtmosphereEnabled then
                UpdateCustomAtmosphere()
            end
        end
    })

    SettingsSection:AddColorPicker({
        Name = "Atmosphere Color 2",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CustomAtmosphereColor2 = Value
            if CustomAtmosphereEnabled then
                UpdateCustomAtmosphere()
            end
        end
    })

    SettingsSection:AddSlider({
        Name = "Atmosphere Density",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomAtmosphereDensity = Value
            if CustomAtmosphereEnabled then
                UpdateCustomAtmosphere()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Atmosphere Glaze",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomAtmosphereGlaze = Value
            if CustomAtmosphereEnabled then
                UpdateCustomAtmosphere()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Atmosphere Haze",
        Min = 0,
        Max = 100,
        Default = 0,
        Type = "",
        Callback = function(Value)
            CustomAtmosphereHaze = Value
            if CustomAtmosphereEnabled then
                UpdateCustomAtmosphere()
            end
        end,
    })

    SettingsSection:AddToggle({
        Name = "Custom Brightness",
        Default = false,
        Callback = function(Value)
            CustomBrightnessEnabled = Value
            UpdateCustomBrightness()
        end,
    })

    SettingsSection:AddDropdown({
        Name = "Brightness Mode",
        Values = {"Fullbright", "Nightmode"},
        Default = "Fullbright",
        Callback = function(Value)
            if type(Value) == "table" then
                CustomBrightnessMode = Value[1] or "Fullbright"
            elseif type(Value) == "string" then
                CustomBrightnessMode = Value
            else
                CustomBrightnessMode = "Fullbright"
            end
            if CustomBrightnessEnabled then
                UpdateCustomBrightness()
            end
        end,
    })

end

-- ========== MOVEMENT FUNCTIONS ==========

-- Helper function to check if player is alive
local function IsPlayerAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

-- Helper function to get character, root, and humanoid
local function GetCharacter()
    local character = LocalPlayer.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not IsPlayerAlive(character) then return nil end
    if not root or not humanoid then return nil end
    return character, root, humanoid
end

-- Helper function to get Y rotation from CFrame
local function GetYRotation(cframe)
    local _, y = cframe:ToOrientation()
    return CFrame.new(cframe.Position) * CFrame.Angles(0, y, 0)
end

-- Helper function to get move direction
local function GetMoveDirection()
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(1, 0, 0) end
    return dir.Magnitude > 0 and dir.Unit or nil
end

-- Function to start speed hack
function StartSpeedHack()
    if MovementConnection then
        MovementConnection:Disconnect()
        MovementConnection = nil
    end
    
    if not SpeedHackEnabled then
        return
    end
    
    MovementConnection = RunService.Stepped:Connect(function()
        local character, root, humanoid = GetCharacter()
        if not character then return end
        if not SpeedHackEnabled then return end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.Jump = true
        end
        
        local moveDir = GetMoveDirection()
        if not moveDir then return end
        
        local camCF = Camera.CFrame
        local forward = GetYRotation(camCF):VectorToWorldSpace(moveDir)
        local Speed = (OverrideSpeedHackEnabled and UserInputService:IsKeyDown(OverrideSpeedHackKey)) and OverrideSpeedHackSpeed or SpeedHackSpeed
        
        if SpeedHackMethod == "Velocity" then
            local velocity = forward * Speed
            root.Velocity = Vector3.new(velocity.X, root.Velocity.Y, velocity.Z)
        elseif SpeedHackMethod == "CFrame" then
            local offset = forward * (Speed / 50)
            root.CFrame = root.CFrame + Vector3.new(offset.X, 0, offset.Z)
        end
    end)
end

-- Function to stop speed hack
function StopSpeedHack()
    if MovementConnection then
        MovementConnection:Disconnect()
        MovementConnection = nil
    end
end

-- Function to start auto hop
function StartAutoHop()
    if AutoHopConnection then
        AutoHopConnection:Disconnect()
        AutoHopConnection = nil
    end
    
    if not AutoHopEnabled then
        return
    end
    
    AutoHopConnection = RunService.Heartbeat:Connect(function()
        local character, root, humanoid = GetCharacter()
        if not character then return end
        if not AutoHopEnabled then return end
        
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid.Jump = true
        end
    end)
end

-- Function to stop auto hop
function StopAutoHop()
    if AutoHopConnection then
        AutoHopConnection:Disconnect()
        AutoHopConnection = nil
    end
end

-- Function to start slide walk
function StartSlideWalk()
    if SlideWalkConnection then
        SlideWalkConnection:Disconnect()
        SlideWalkConnection = nil
    end
    
    if not SlideWalkEnabled then
        return
    end
    
    -- Create fake animation
    local fakeAnim = Instance.new("Animation")
    fakeAnim.AnimationId = "rbxassetid://0"
    
    -- Hook LoadAnimation to replace RunAnim and JumpAnim
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod and getnamecallmethod() or ""
            
            if method == "LoadAnimation" and SlideWalkEnabled then
                if args[1] and (args[1].Name == "RunAnim" or args[1].Name == "JumpAnim") then
                    args[1] = fakeAnim
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end)
        
        SlideWalkConnection = RunService.Heartbeat:Connect(function()
            if not SlideWalkEnabled then
                if SlideWalkConnection then
                    SlideWalkConnection:Disconnect()
                    SlideWalkConnection = nil
                end
            end
        end)
    end
end

-- Function to stop slide walk
function StopSlideWalk()
    if SlideWalkConnection then
        SlideWalkConnection:Disconnect()
        SlideWalkConnection = nil
    end
end

-- Function to create ESP box for a player
function CreateESPBox(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Remove existing box if it exists
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
    end
    
    -- Create new box
    local espBox = Drawing.new("Square")
    espBox.Visible = true
    espBox.Color = BoxESPColor
    espBox.Thickness = 2
    espBox.Transparency = 1
    espBox.Filled = false
    espBox.Size = Vector2.new(100, 100)
    espBox.Position = Vector2.new(0, 0)
    
    ESPBoxes[player] = espBox
    
    -- INSTANT REMOVE: Clean up when player leaves or character dies
    character:WaitForChild("Humanoid").Died:Connect(function()
        if ESPBoxes[player] then
            ESPBoxes[player].Visible = false  -- INSTANT HIDE
            ESPBoxes[player]:Remove()
            ESPBoxes[player] = nil
        end
    end)
end

-- Function to update ESP boxes
function UpdateESPBoxes()
    for player, box in pairs(ESPBoxes) do
        if box then
            box.Color = BoxESPColor
        end
    end
end

-- Function to update ESP box position and size
function UpdateESPBox(player)
    if not ESPBoxes[player] or not player.Character then 
        if ESPBoxes[player] then
            ESPBoxes[player].Visible = false
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if ESPBoxes[player] then
            ESPBoxes[player].Visible = false
        end
        return
    end
    
    -- Get character CFrame for rotation
    local characterCFrame = humanoidRootPart.CFrame
    local characterPosition = humanoidRootPart.Position
    
    -- Box dimensions (relative to character)
    local boxWidth = 2.5  -- Width of the box
    local boxHeight = 5.2  -- Height of the box (further reduced to make top smaller)
    local boxDepth = 1.5  -- Depth of the box
    local topOffset = 0.05  -- How much the box extends above head (very small)
    
    -- Calculate all 8 corners of the 3D box using character's rotation
    local corners = {}
    
    -- Top corners (above head)
    corners[1] = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2 + topOffset, -boxDepth/2)) -- Top front left
    corners[2] = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2 + topOffset, -boxDepth/2)) -- Top front right
    corners[3] = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2 + topOffset, boxDepth/2)) -- Top back left
    corners[4] = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2 + topOffset, boxDepth/2)) -- Top back right
    
    -- Bottom corners (feet)
    corners[5] = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, -boxDepth/2)) -- Bottom front left
    corners[6] = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, -boxDepth/2)) -- Bottom front right
    corners[7] = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, boxDepth/2)) -- Bottom back left
    corners[8] = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, boxDepth/2)) -- Bottom back right
    
    -- Convert all corners to screen space
    local screenCorners = {}
    local allOnScreen = true
    
    for i, corner in ipairs(corners) do
        local screenPoint, onScreen = Camera:WorldToViewportPoint(corner)
        screenCorners[i] = Vector2.new(screenPoint.X, screenPoint.Y)
        if not onScreen then
            allOnScreen = false
        end
    end
    
    if allOnScreen then
        -- Find bounding box of all corners
        local minX = math.huge
        local maxX = -math.huge
        local minY = math.huge
        local maxY = -math.huge
        
        for _, corner in ipairs(screenCorners) do
            minX = math.min(minX, corner.X)
            maxX = math.max(maxX, corner.X)
            minY = math.min(minY, corner.Y)
            maxY = math.max(maxY, corner.Y)
        end
        
        -- Set box size and position
        ESPBoxes[player].Size = Vector2.new(maxX - minX, maxY - minY)
        ESPBoxes[player].Position = Vector2.new(minX, minY)
        ESPBoxes[player].Visible = true
    else
        ESPBoxes[player].Visible = false
    end
end

-- Function to remove ESP box for a player
function RemoveESPBox(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

-- Function to start Box ESP
function StartBoxESP()
    if ESPConnection then return end
    
    -- Create ESP boxes for all existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateESPBox(player)
            else
                -- Wait for character to load
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if BoxESPEnabled then
                        CreateESPBox(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players joining
    PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        
        if player.Character then
            CreateESPBox(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if BoxESPEnabled then
                    CreateESPBox(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        RemoveESPBox(player)
    end)
    
    -- Update ESP boxes every frame
    ESPConnection = RunService.RenderStepped:Connect(function()
        if BoxESPEnabled then
            -- Create boxes for players who don't have one yet
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not ESPBoxes[player] then
                    CreateESPBox(player)
                end
            end
            
            -- Clean up boxes for players who no longer exist or are dead
            for player, box in pairs(ESPBoxes) do
                if not PlayerStillExists(player) or not player.Character or IsTeammate(player) then
                    RemoveESPBox(player)
                elseif box and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        if box then
                            box.Visible = false
                        end
                    else
                        UpdateESPBox(player)
                    end
                end
            end
        end
    end)
end

-- Function to stop Box ESP
function StopBoxESP()
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    
    if PlayerAddedConnection then
        PlayerAddedConnection:Disconnect()
        PlayerAddedConnection = nil
    end
    
    if PlayerRemovingConnection then
        PlayerRemovingConnection:Disconnect()
        PlayerRemovingConnection = nil
    end
    
    -- Remove all ESP boxes
    for player, box in pairs(ESPBoxes) do
        if box then
            box:Remove()
        end
    end
    ESPBoxes = {}
end

-- ========== CORNER BOX ESP ==========
function CreateCornerBox(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Create 8 lines for 4 corners (2 lines per corner)
    local corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = true
        line.Color = CornerBoxESPColor
        line.Thickness = 2
        line.Transparency = 1
        corners[i] = line
    end
    
    CornerBoxes[player] = corners
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        if CornerBoxes[player] then
            for _, line in pairs(CornerBoxes[player]) do
                line.Visible = false  -- INSTANT HIDE
                line:Remove()
            end
            CornerBoxes[player] = nil
        end
    end)
end

function UpdateCornerBox(player)
    if not CornerBoxes[player] or not player.Character then 
        if CornerBoxes[player] then
            for _, line in pairs(CornerBoxes[player]) do
                line.Visible = false
            end
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if CornerBoxes[player] then
            for _, line in pairs(CornerBoxes[player]) do
                line.Visible = false
            end
        end
        return
    end
    
    -- Use same dimensions as normal box
    local characterCFrame = humanoidRootPart.CFrame
    local boxWidth = 2.5
    local boxHeight = 5.2
    local boxDepth = 1.5
    local topOffset = 0.05
    
    -- Calculate corners using same method as normal box
    local topPosition = characterCFrame:PointToWorldSpace(Vector3.new(0, boxHeight/2 + topOffset, 0))
    local bottomPosition = characterCFrame:PointToWorldSpace(Vector3.new(0, -boxHeight/2, 0))
    
    local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPosition)
    local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPosition)
    
    if topOnScreen and bottomOnScreen then
        local height = math.abs(topScreen.Y - bottomScreen.Y)
        local width = height * 0.5
        
        local corners = CornerBoxes[player]
        local cornerLength = height * 0.2
        
        -- Top left corner (2 lines)
        corners[1].From = Vector2.new(topScreen.X - width/2, topScreen.Y)
        corners[1].To = Vector2.new(topScreen.X - width/2 + cornerLength, topScreen.Y)
        corners[2].From = Vector2.new(topScreen.X - width/2, topScreen.Y)
        corners[2].To = Vector2.new(topScreen.X - width/2, topScreen.Y + cornerLength)
        
        -- Top right corner (2 lines)
        corners[3].From = Vector2.new(topScreen.X + width/2, topScreen.Y)
        corners[3].To = Vector2.new(topScreen.X + width/2 - cornerLength, topScreen.Y)
        corners[4].From = Vector2.new(topScreen.X + width/2, topScreen.Y)
        corners[4].To = Vector2.new(topScreen.X + width/2, topScreen.Y + cornerLength)
        
        -- Bottom left corner (2 lines)
        corners[5].From = Vector2.new(bottomScreen.X - width/2, bottomScreen.Y)
        corners[5].To = Vector2.new(bottomScreen.X - width/2 + cornerLength, bottomScreen.Y)
        corners[6].From = Vector2.new(bottomScreen.X - width/2, bottomScreen.Y)
        corners[6].To = Vector2.new(bottomScreen.X - width/2, bottomScreen.Y - cornerLength)
        
        -- Bottom right corner (2 lines)
        corners[7].From = Vector2.new(bottomScreen.X + width/2, bottomScreen.Y)
        corners[7].To = Vector2.new(bottomScreen.X + width/2 - cornerLength, bottomScreen.Y)
        corners[8].From = Vector2.new(bottomScreen.X + width/2, bottomScreen.Y)
        corners[8].To = Vector2.new(bottomScreen.X + width/2, bottomScreen.Y - cornerLength)
        
        for _, line in pairs(corners) do
            line.Visible = true
        end
    else
        for _, line in pairs(CornerBoxes[player]) do
            line.Visible = false
        end
    end
end

function UpdateCornerBoxes()
    for player, corners in pairs(CornerBoxes) do
        if corners then
            for _, line in pairs(corners) do
                line.Color = CornerBoxESPColor
            end
        end
    end
end

function StartCornerBoxESP()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateCornerBox(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if CornerBoxESPEnabled then
                        CreateCornerBox(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateCornerBox(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if CornerBoxESPEnabled then
                    CreateCornerBox(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if CornerBoxes[player] then
            for _, line in pairs(CornerBoxes[player]) do
                line:Remove()
            end
            CornerBoxes[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if CornerBoxESPEnabled then
            -- Create boxes for players who don't have one yet
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not CornerBoxes[player] then
                    CreateCornerBox(player)
                end
            end
            
            for player, corners in pairs(CornerBoxes) do
                if corners and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        for _, line in pairs(corners) do
                            line.Visible = false
                        end
                    else
                        UpdateCornerBox(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if CornerBoxes[player] then
                        for _, line in pairs(CornerBoxes[player]) do
                            line:Remove()
                        end
                        CornerBoxes[player] = nil
                    end
                end
            end
        end
    end)
end

function StopCornerBoxESP()
    for player, corners in pairs(CornerBoxes) do
        if corners then
            for _, line in pairs(corners) do
                line:Remove()
            end
        end
    end
    CornerBoxes = {}
end

-- ========== SKELETON ESP ==========
function CreateSkeletonESP(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local skeletonLines = {}
    SkeletonLines[player] = skeletonLines
    
    humanoid.Died:Connect(function()
        if SkeletonLines[player] then
            for _, line in pairs(SkeletonLines[player]) do
                if line then
                    line.Visible = false  -- INSTANT HIDE
                    line:Remove()
                end
            end
            SkeletonLines[player] = nil
        end
    end)
end

function UpdateSkeletonESP(player)
    if not SkeletonLines[player] or not player.Character then 
        if SkeletonLines[player] then
            for _, line in pairs(SkeletonLines[player]) do
                if line then
                    line.Visible = false
                end
            end
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local upperTorso = character:FindFirstChild("UpperTorso")
    local lowerTorso = character:FindFirstChild("LowerTorso")
    local torso = upperTorso or character:FindFirstChild("Torso")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not head or not humanoid or humanoid.Health <= 0 then
        if SkeletonLines[player] then
            for _, line in pairs(SkeletonLines[player]) do
                if line then
                    line.Visible = false
                end
            end
        end
        return
    end
    
    -- Bone connections for R6 and R15
    local bones = {}
    
    -- Head to Torso
    if head and torso then
        table.insert(bones, {head, torso})
    end
    
    -- Torso connections
    if upperTorso and lowerTorso then
        table.insert(bones, {upperTorso, lowerTorso})
    end
    if torso and humanoidRootPart then
        table.insert(bones, {torso, humanoidRootPart})
    end
    
    -- Arms (R6 and R15)
    local leftUpperArm = character:FindFirstChild("LeftUpperArm")
    local leftLowerArm = character:FindFirstChild("LeftLowerArm")
    local leftHand = character:FindFirstChild("LeftHand")
    
    local rightUpperArm = character:FindFirstChild("RightUpperArm")
    local rightLowerArm = character:FindFirstChild("RightLowerArm")
    local rightHand = character:FindFirstChild("RightHand")
    
    if leftUpperArm and torso then
        table.insert(bones, {torso, leftUpperArm})
        if leftLowerArm then
            table.insert(bones, {leftUpperArm, leftLowerArm})
            if leftHand then
                table.insert(bones, {leftLowerArm, leftHand})
            end
        end
    end
    
    if rightUpperArm and torso then
        table.insert(bones, {torso, rightUpperArm})
        if rightLowerArm then
            table.insert(bones, {rightUpperArm, rightLowerArm})
            if rightHand then
                table.insert(bones, {rightLowerArm, rightHand})
            end
        end
    end
    
    -- Legs (R6 and R15)
    local leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
    local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
    local leftFoot = character:FindFirstChild("LeftFoot")
    
    local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
    local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
    local rightFoot = character:FindFirstChild("RightFoot")
    
    local legParent = lowerTorso or humanoidRootPart
    
    if leftUpperLeg and legParent then
        table.insert(bones, {legParent, leftUpperLeg})
        if leftLowerLeg then
            table.insert(bones, {leftUpperLeg, leftLowerLeg})
            if leftFoot then
                table.insert(bones, {leftLowerLeg, leftFoot})
            end
        end
    end
    
    if rightUpperLeg and legParent then
        table.insert(bones, {legParent, rightUpperLeg})
        if rightLowerLeg then
            table.insert(bones, {rightUpperLeg, rightLowerLeg})
            if rightFoot then
                table.insert(bones, {rightLowerLeg, rightFoot})
            end
        end
    end
    
    -- Update or create lines
    for i, bone in ipairs(bones) do
        if bone[1] and bone[2] then
            local point1, onScreen1 = Camera:WorldToViewportPoint(bone[1].Position)
            local point2, onScreen2 = Camera:WorldToViewportPoint(bone[2].Position)
            
            if onScreen1 and onScreen2 then
                if not SkeletonLines[player][i] then
                    local line = Drawing.new("Line")
                    line.Visible = true
                    line.Color = SkeletonESPColor
                    line.Thickness = 2
                    line.Transparency = 1
                    SkeletonLines[player][i] = line
                end
                
                SkeletonLines[player][i].From = Vector2.new(point1.X, point1.Y)
                SkeletonLines[player][i].To = Vector2.new(point2.X, point2.Y)
                SkeletonLines[player][i].Visible = true
            elseif SkeletonLines[player][i] then
                SkeletonLines[player][i].Visible = false
            end
        end
    end
end

function UpdateSkeletonESPColors()
    for player, lines in pairs(SkeletonLines) do
        if lines then
            for _, line in pairs(lines) do
                if line then
                    line.Color = SkeletonESPColor
                end
            end
        end
    end
end

function StartSkeletonESP()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateSkeletonESP(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if SkeletonESPEnabled then
                        CreateSkeletonESP(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateSkeletonESP(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if SkeletonESPEnabled then
                    CreateSkeletonESP(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if SkeletonLines[player] then
            for _, line in pairs(SkeletonLines[player]) do
                if line then
                    line:Remove()
                end
            end
            SkeletonLines[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if SkeletonESPEnabled then
            -- Create skeleton for players who don't have one yet
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not SkeletonLines[player] then
                    CreateSkeletonESP(player)
                end
            end
            
            for player, lines in pairs(SkeletonLines) do
                if lines and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        for _, line in pairs(lines) do
                            if line then
                                line.Visible = false
                            end
                        end
                    else
                        UpdateSkeletonESP(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if SkeletonLines[player] then
                        for _, line in pairs(SkeletonLines[player]) do
                            if line then
                                line:Remove()
                            end
                        end
                        SkeletonLines[player] = nil
                    end
                end
            end
        end
    end)
end

function StopSkeletonESP()
    for player, lines in pairs(SkeletonLines) do
        if lines then
            for _, line in pairs(lines) do
                if line then
                    line:Remove()
                end
            end
        end
    end
    SkeletonLines = {}
end

-- ========== CHAMS ==========
function CreateChams(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    local parts = {}
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local highlight = Instance.new("Highlight")
            highlight.Enabled = true
            highlight.FillColor = ChamsColor
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = ChamsColor
            highlight.OutlineTransparency = 0
            highlight.Parent = part
            table.insert(parts, highlight)
        end
    end
    
    ChamsParts[player] = parts
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        if ChamsParts[player] then
            for _, highlight in pairs(ChamsParts[player]) do
                highlight:Destroy()
            end
            ChamsParts[player] = nil
        end
    end)
end

function UpdateChams()
    for player, highlights in pairs(ChamsParts) do
        if highlights and not IsTeammate(player) then
            for _, highlight in pairs(highlights) do
                highlight.FillColor = ChamsColor
                highlight.OutlineColor = ChamsColor
            end
        end
    end
end

function StartChams()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateChams(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if ChamsEnabled then
                        CreateChams(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateChams(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if ChamsEnabled then
                    CreateChams(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if ChamsParts[player] then
            for _, highlight in pairs(ChamsParts[player]) do
                highlight:Destroy()
            end
            ChamsParts[player] = nil
        end
    end)
end

function StopChams()
    for player, highlights in pairs(ChamsParts) do
        if highlights then
            for _, highlight in pairs(highlights) do
                highlight:Destroy()
            end
        end
    end
    ChamsParts = {}
end

-- Function to start Chams Rainbow
function StartChamsRainbow()
    if ChamsRainbowConnection then
        ChamsRainbowConnection:Disconnect()
        ChamsRainbowConnection = nil
    end
    
    ChamsRainbowConnection = RunService.RenderStepped:Connect(function()
        if not ChamsRainbowEnabled or not ChamsEnabled then
            if ChamsRainbowConnection then
                ChamsRainbowConnection:Disconnect()
                ChamsRainbowConnection = nil
            end
            return
        end
        
        -- Rainbow color calculation (HSV: 0-1 range)
        local hue = (tick() * 0.2) % 1  -- Slower speed for smooth transition
        ChamsColor = Color3.fromHSV(hue, 1, 1)
        UpdateChams()
    end)
end

-- Function to stop Chams Rainbow
function StopChamsRainbow()
    if ChamsRainbowConnection then
        ChamsRainbowConnection:Disconnect()
        ChamsRainbowConnection = nil
    end
end

-- ========== NAME ESP ==========
function CreateNameESP(player)
    if not player or not player.Character then return end
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = true
    nameLabel.Color = NameESPColor
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = player.Name
    nameLabel.Transparency = 1
    
    NameLabels[player] = nameLabel
    
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if NameLabels[player] then
            NameLabels[player].Visible = false  -- INSTANT HIDE
            NameLabels[player]:Remove()
            NameLabels[player] = nil
        end
    end)
end

function UpdateNameESP(player)
    if not NameLabels[player] or not player.Character then 
        if NameLabels[player] then
            NameLabels[player].Visible = false
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if NameLabels[player] then
            NameLabels[player].Visible = false
        end
        return
    end
    
    -- Get box position to place name above box
    local characterCFrame = humanoidRootPart.CFrame
    local boxWidth = 2.5
    local boxHeight = 5.2
    local boxDepth = 1.5
    local topOffset = 0.05
    
    -- Calculate top corners of box
    local topFrontLeft = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2 + topOffset, -boxDepth/2))
    local topFrontRight = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2 + topOffset, -boxDepth/2))
    local topBackLeft = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2 + topOffset, boxDepth/2))
    local topBackRight = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2 + topOffset, boxDepth/2))
    
    -- Project to screen space
    local topFrontLeftScreen, topFrontLeftOnScreen = Camera:WorldToViewportPoint(topFrontLeft)
    local topFrontRightScreen, topFrontRightOnScreen = Camera:WorldToViewportPoint(topFrontRight)
    local topBackLeftScreen, topBackLeftOnScreen = Camera:WorldToViewportPoint(topBackLeft)
    local topBackRightScreen, topBackRightOnScreen = Camera:WorldToViewportPoint(topBackRight)
    
    if topFrontLeftOnScreen or topFrontRightOnScreen or topBackLeftOnScreen or topBackRightOnScreen then
        -- Find top Y position of box
        local topY = math.huge
        if topFrontLeftOnScreen then topY = math.min(topY, topFrontLeftScreen.Y) end
        if topFrontRightOnScreen then topY = math.min(topY, topFrontRightScreen.Y) end
        if topBackLeftOnScreen then topY = math.min(topY, topBackLeftScreen.Y) end
        if topBackRightOnScreen then topY = math.min(topY, topBackRightScreen.Y) end
        
        -- Find center X position of box
        local minX = math.huge
        local maxX = -math.huge
        if topFrontLeftOnScreen then minX = math.min(minX, topFrontLeftScreen.X); maxX = math.max(maxX, topFrontLeftScreen.X) end
        if topFrontRightOnScreen then minX = math.min(minX, topFrontRightScreen.X); maxX = math.max(maxX, topFrontRightScreen.X) end
        if topBackLeftOnScreen then minX = math.min(minX, topBackLeftScreen.X); maxX = math.max(maxX, topBackLeftScreen.X) end
        if topBackRightOnScreen then minX = math.min(minX, topBackRightScreen.X); maxX = math.max(maxX, topBackRightScreen.X) end
        
        local centerX = (minX + maxX) / 2
        
        -- Position name above box with fixed offset
        local nameY = topY - 20  -- Fixed offset above box (doesn't scale with distance)
        
        NameLabels[player].Position = Vector2.new(centerX, nameY)
        NameLabels[player].Size = 16  -- Fixed size, doesn't change with distance
        NameLabels[player].Visible = true
    else
        NameLabels[player].Visible = false
    end
end

function UpdateNameESPColors()
    for player, label in pairs(NameLabels) do
        if label then
            label.Color = NameESPColor
        end
    end
end

function StartNameESP()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateNameESP(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if NameESPEnabled then
                        CreateNameESP(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateNameESP(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if NameESPEnabled then
                    CreateNameESP(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if NameLabels[player] then
            NameLabels[player]:Remove()
            NameLabels[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if NameESPEnabled then
            -- Create name ESP for players who don't have one yet
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not NameLabels[player] then
                    CreateNameESP(player)
                end
            end
            
            for player, label in pairs(NameLabels) do
                if label and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        label.Visible = false
                    else
                        UpdateNameESP(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if NameLabels[player] then
                        NameLabels[player]:Remove()
                        NameLabels[player] = nil
                    end
                end
            end
        end
    end)
end

function StopNameESP()
    for player, label in pairs(NameLabels) do
        if label then
            label:Remove()
        end
    end
    NameLabels = {}
end

-- ========== DISTANCE ESP ==========
function CreateDistanceESP(player)
    if not player or not player.Character then return end
    
    local distanceLabel = Drawing.new("Text")
    distanceLabel.Visible = true
    distanceLabel.Color = DistanceESPColor
    distanceLabel.Size = 14
    distanceLabel.Center = true
    distanceLabel.Outline = true
    distanceLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    distanceLabel.Transparency = 1
    
    DistanceLabels[player] = distanceLabel
    
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if DistanceLabels[player] then
            DistanceLabels[player].Visible = false  -- INSTANT HIDE
            DistanceLabels[player]:Remove()
            DistanceLabels[player] = nil
        end
    end)
end

function UpdateDistanceESP(player)
    if not DistanceLabels[player] or not player.Character then 
        if DistanceLabels[player] then
            DistanceLabels[player].Visible = false
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if DistanceLabels[player] then
            DistanceLabels[player].Visible = false
        end
        return
    end
    
    -- Get box position to place distance below box
    local characterCFrame = humanoidRootPart.CFrame
    local boxWidth = 2.5
    local boxHeight = 5.2
    local boxDepth = 1.5
    
    -- Calculate bottom corners of box
    local bottomFrontLeft = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, -boxDepth/2))
    local bottomFrontRight = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, -boxDepth/2))
    local bottomBackLeft = characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, boxDepth/2))
    local bottomBackRight = characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, boxDepth/2))
    
    -- Project to screen space
    local bottomFrontLeftScreen, bottomFrontLeftOnScreen = Camera:WorldToViewportPoint(bottomFrontLeft)
    local bottomFrontRightScreen, bottomFrontRightOnScreen = Camera:WorldToViewportPoint(bottomFrontRight)
    local bottomBackLeftScreen, bottomBackLeftOnScreen = Camera:WorldToViewportPoint(bottomBackLeft)
    local bottomBackRightScreen, bottomBackRightOnScreen = Camera:WorldToViewportPoint(bottomBackRight)
    
    if bottomFrontLeftOnScreen or bottomFrontRightOnScreen or bottomBackLeftOnScreen or bottomBackRightOnScreen then
        -- Find bottom Y position of box (lowest Y value = bottom of box on screen)
        local bottomY = -math.huge
        local validBottomY = false
        if bottomFrontLeftOnScreen then 
            bottomY = math.max(bottomY, bottomFrontLeftScreen.Y)
            validBottomY = true
        end
        if bottomFrontRightOnScreen then 
            bottomY = math.max(bottomY, bottomFrontRightScreen.Y)
            validBottomY = true
        end
        if bottomBackLeftOnScreen then 
            bottomY = math.max(bottomY, bottomBackLeftScreen.Y)
            validBottomY = true
        end
        if bottomBackRightOnScreen then 
            bottomY = math.max(bottomY, bottomBackRightScreen.Y)
            validBottomY = true
        end
        
        if validBottomY then
            -- Find center X position of box
            local minX = math.huge
            local maxX = -math.huge
            if bottomFrontLeftOnScreen then minX = math.min(minX, bottomFrontLeftScreen.X); maxX = math.max(maxX, bottomFrontLeftScreen.X) end
            if bottomFrontRightOnScreen then minX = math.min(minX, bottomFrontRightScreen.X); maxX = math.max(maxX, bottomFrontRightScreen.X) end
            if bottomBackLeftOnScreen then minX = math.min(minX, bottomBackLeftScreen.X); maxX = math.max(maxX, bottomBackLeftScreen.X) end
            if bottomBackRightOnScreen then minX = math.min(minX, bottomBackRightScreen.X); maxX = math.max(maxX, bottomBackRightScreen.X) end
            
            local centerX = (minX + maxX) / 2
            
            -- Position distance below box with STATIC pixel offset (always 20 pixels, never changes)
            local staticOffset = 20  -- Fixed pixel offset, doesn't scale with distance
            local distanceY = bottomY + staticOffset
            
            local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            DistanceLabels[player].Text = math.floor(distance) .. " studs"
            DistanceLabels[player].Position = Vector2.new(centerX, distanceY)
            DistanceLabels[player].Size = 14  -- Fixed size, doesn't change with distance
            DistanceLabels[player].Visible = true
        else
            DistanceLabels[player].Visible = false
        end
    else
        DistanceLabels[player].Visible = false
    end
end

function UpdateDistanceESPColors()
    for player, label in pairs(DistanceLabels) do
        if label then
            label.Color = DistanceESPColor
        end
    end
end

function StartDistanceESP()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateDistanceESP(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if DistanceESPEnabled then
                        CreateDistanceESP(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateDistanceESP(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if DistanceESPEnabled then
                    CreateDistanceESP(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if DistanceLabels[player] then
            DistanceLabels[player]:Remove()
            DistanceLabels[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if DistanceESPEnabled then
            -- Create distance ESP for players who don't have one yet
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not DistanceLabels[player] then
                    CreateDistanceESP(player)
                end
            end
            
            for player, label in pairs(DistanceLabels) do
                if label and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        label.Visible = false
                    else
                        UpdateDistanceESP(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if DistanceLabels[player] then
                        DistanceLabels[player]:Remove()
                        DistanceLabels[player] = nil
                    end
                end
            end
        end
    end)
end

function StopDistanceESP()
    for player, label in pairs(DistanceLabels) do
        if label then
            label:Remove()
        end
    end
    DistanceLabels = {}
end

-- ========== TRACERS ==========
function CreateTracer(player)
    if not player or not player.Character then return end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = true
    tracer.Color = TracersColor
    tracer.Thickness = 1
    tracer.Transparency = 1
    
    TracerLines[player] = tracer
    
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if TracerLines[player] then
            TracerLines[player].Visible = false  -- INSTANT HIDE
            TracerLines[player]:Remove()
            TracerLines[player] = nil
        end
    end)
end

function UpdateTracer(player)
    if not TracerLines[player] or not player.Character then 
        if TracerLines[player] then
            TracerLines[player].Visible = false
        end
        return 
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    -- INSTANT REMOVE: Check if player is dead
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if TracerLines[player] then
            TracerLines[player].Visible = false
        end
        return
    end
    
    local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    
    if onScreen then
        local centerX = Camera.ViewportSize.X / 2
        local bottomY = Camera.ViewportSize.Y
        
        TracerLines[player].From = Vector2.new(centerX, bottomY)
        TracerLines[player].To = Vector2.new(screenPoint.X, screenPoint.Y)
        TracerLines[player].Visible = true
    else
        TracerLines[player].Visible = false
    end
end

function UpdateTracers()
    for player, tracer in pairs(TracerLines) do
        if tracer then
            tracer.Color = TracersColor
        end
    end
end

function StartTracers()
    -- Create for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateTracer(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if TracersEnabled then
                        CreateTracer(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateTracer(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if TracersEnabled then
                    CreateTracer(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if TracerLines[player] then
            TracerLines[player]:Remove()
            TracerLines[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if TracersEnabled then
            for player, tracer in pairs(TracerLines) do
                if tracer and player.Character and not IsTeammate(player) then
                    -- INSTANT REMOVE: Check if dead before updating
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        tracer.Visible = false
                    else
                        UpdateTracer(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if TracerLines[player] then
                        TracerLines[player]:Remove()
                        TracerLines[player] = nil
                    end
                end
            end
        end
    end)
end

function StopTracers()
    for player, tracer in pairs(TracerLines) do
        if tracer then
            tracer:Remove()
        end
    end
    TracerLines = {}
end

-- ========== EXPLOITS FEATURES ==========
-- Function to start spin bot
function StartSpinBot()
    if SpinBotConnection then
        SpinBotConnection:Disconnect()
        SpinBotConnection = nil
    end
    
    SpinBotConnection = RunService.RenderStepped:Connect(function()
        if not SpinBotEnabled then
            if SpinBotConnection then
                SpinBotConnection:Disconnect()
                SpinBotConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Rotate character
        local currentCFrame = humanoidRootPart.CFrame
        local rotation = CFrame.Angles(0, math.rad(SpinBotSpeed), 0)
        humanoidRootPart.CFrame = currentCFrame * rotation
    end)
end

-- Function to stop spin bot
function StopSpinBot()
    if SpinBotConnection then
        SpinBotConnection:Disconnect()
        SpinBotConnection = nil
    end
end

-- Function to start self chams
function StartSelfChams()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Remove existing highlights
    StopSelfChams()
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Make part transparent with color
            part.Transparency = 0.9  -- Almost fully transparent
            part.Color = SelfChamsColor
            
            -- Add highlight for outline
            local highlight = Instance.new("Highlight")
            highlight.Enabled = true
            highlight.FillColor = SelfChamsColor
            highlight.FillTransparency = 0.9  -- Fully transparent fill
            highlight.OutlineColor = SelfChamsColor
            highlight.OutlineTransparency = 0  -- Visible outline
            highlight.Parent = part
            table.insert(SelfChamsHighlights, highlight)
        end
    end
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        wait(0.1)
        if SelfChamsEnabled then
            StartSelfChams()
        end
    end)
end

-- Function to update self chams
function UpdateSelfChams()
    for _, highlight in pairs(SelfChamsHighlights) do
        if highlight and highlight.Parent then
            local part = highlight.Parent
            if part:IsA("BasePart") then
                part.Color = SelfChamsColor
            end
            highlight.FillColor = SelfChamsColor
            highlight.OutlineColor = SelfChamsColor
        end
    end
end

-- Function to stop self chams
function StopSelfChams()
    for _, highlight in pairs(SelfChamsHighlights) do
        if highlight then
            local part = highlight.Parent
            if part and part:IsA("BasePart") then
                part.Transparency = 0  -- Reset transparency
            end
            highlight:Destroy()
        end
    end
    SelfChamsHighlights = {}
end

-- Function to get all BaseParts from a container (WORKING VERSION)
local function getAllBaseParts(container)
    local parts = {}
    if not container or not container.GetChildren then return parts end
    for _, v in ipairs(container:GetChildren()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            table.insert(parts, v)
        elseif v:IsA("Model") or v:IsA("Folder") then
            for _, p in ipairs(getAllBaseParts(v)) do
                table.insert(parts, p)
            end
        end
    end
    return parts
end

-- Function to get all viewmodel parts (WORKING VERSION)
local function getAllViewmodelParts()
    local parts = {}
    local camera = Workspace.CurrentCamera
    local lp = LocalPlayer

    -- Camera children (classic viewmodel)
    for _, p in ipairs(getAllBaseParts(camera)) do 
        table.insert(parts, p) 
    end

    -- Arsenal and common viewmodel folders/models
    local candidates = {
        Workspace:FindFirstChild("Viewmodel"),
        Workspace:FindFirstChild("Camera"),
        Workspace:FindFirstChild("Ignore"),
        camera and camera:FindFirstChild("Viewmodel"),
        camera and camera:FindFirstChild("Arms"),
        camera and camera:FindFirstChild("Gun"),
        lp and lp.Character,
    }
    for _, obj in ipairs(candidates) do
        if obj then
            for _, p in ipairs(getAllBaseParts(obj)) do
                table.insert(parts, p)
            end
        end
    end

    -- Remove duplicates
    local seen = {}
    local unique = {}
    for _, part in ipairs(parts) do
        if not seen[part] then
            seen[part] = true
            table.insert(unique, part)
        end
    end
    return unique
end

-- Function to start viewmodel chams - USING WORKING LOGIC
function StartViewmodelChams()
    if ViewmodelChamsConnection then
        ViewmodelChamsConnection:Disconnect()
        ViewmodelChamsConnection = nil
    end
    
    -- Remove existing highlights
    StopViewmodelChams()
    
    -- Function to apply chams to parts
    local function applyChamsToParts()
        for _, part in ipairs(getAllViewmodelParts()) do
            pcall(function()
                -- Store original properties if not already stored
                if not ViewmodelChamsOriginalColors[part] then
                    ViewmodelChamsOriginalColors[part] = {
                        color = part.Color,
                        material = part.Material,
                        transparency = part.Transparency
                    }
                end
                
                -- Apply solid glowing chams - VERY TRANSPARENT WITH GLOW
                part.Material = Enum.Material.Neon  -- Glowing material
                part.Color = ViewmodelChamsColor
                part.Transparency = 0.85  -- Very transparent
                
                -- Add or update highlight with transparent style (FILLED WITH OUTLINE)
                local highlight = part:FindFirstChild("ViewmodelChamHighlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ViewmodelChamHighlight"
                    highlight.Enabled = true
                    highlight.FillColor = ViewmodelChamsColor
                    highlight.FillTransparency = 0.85  -- Very transparent fill
                    highlight.OutlineColor = ViewmodelChamsColor
                    highlight.OutlineTransparency = 0  -- Visible outline
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- Always visible
                    highlight.Parent = part
                    table.insert(ViewmodelChamsHighlights, highlight)
                else
                    highlight.FillColor = ViewmodelChamsColor
                    highlight.FillTransparency = 0.85  -- Very transparent fill
                    highlight.OutlineColor = ViewmodelChamsColor
                    highlight.OutlineTransparency = 0  -- Visible outline
                end
            end)
        end
    end
    
    -- Function to reset parts
    local function resetParts()
        for _, part in ipairs(getAllViewmodelParts()) do
            pcall(function()
                if ViewmodelChamsOriginalColors[part] then
                    part.Color = ViewmodelChamsOriginalColors[part].color
                    part.Material = ViewmodelChamsOriginalColors[part].material
                    part.Transparency = ViewmodelChamsOriginalColors[part].transparency
                    ViewmodelChamsOriginalColors[part] = nil
                end
                local highlight = part:FindFirstChild("ViewmodelChamHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end)
        end
    end
    
    -- Apply chams continuously
    ViewmodelChamsConnection = RunService.RenderStepped:Connect(function()
        if not ViewmodelChamsEnabled then
            if ViewmodelChamsConnection then
                ViewmodelChamsConnection:Disconnect()
                ViewmodelChamsConnection = nil
            end
            resetParts()
            return
        end
        
        applyChamsToParts()
    end)
    
    -- Reapply on camera or character change
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if ViewmodelChamsEnabled then
            applyChamsToParts()
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function()
        if ViewmodelChamsEnabled then
            wait(0.1)
            applyChamsToParts()
        end
    end)
end

-- Function to update viewmodel chams
function UpdateViewmodelChams()
    -- Update all viewmodel parts with new color (solid glowing style)
    for _, part in ipairs(getAllViewmodelParts()) do
        pcall(function()
            part.Color = ViewmodelChamsColor
            part.Material = Enum.Material.Neon  -- Glowing material
            part.Transparency = 0.85  -- Very transparent
            local highlight = part:FindFirstChild("ViewmodelChamHighlight")
            if highlight then
                highlight.FillColor = ViewmodelChamsColor
                highlight.FillTransparency = 0.85  -- Very transparent fill
                highlight.OutlineColor = ViewmodelChamsColor
                highlight.OutlineTransparency = 0  -- Visible outline
            end
        end)
    end
end

-- Function to stop viewmodel chams
function StopViewmodelChams()
    if ViewmodelChamsConnection then
        ViewmodelChamsConnection:Disconnect()
        ViewmodelChamsConnection = nil
    end
    
    -- Reset all viewmodel parts to original state
    for _, part in ipairs(getAllViewmodelParts()) do
        pcall(function()
            if ViewmodelChamsOriginalColors[part] then
                part.Color = ViewmodelChamsOriginalColors[part].color
                part.Material = ViewmodelChamsOriginalColors[part].material
                part.Transparency = ViewmodelChamsOriginalColors[part].transparency
                ViewmodelChamsOriginalColors[part] = nil
            else
                -- Fallback: reset to default if no original color stored
                part.Transparency = 0
            end
            local highlight = part:FindFirstChild("ViewmodelChamHighlight")
            if highlight then
                highlight:Destroy()
            end
        end)
    end
    
    -- Clean up highlights and lights
    for _, item in pairs(ViewmodelChamsHighlights) do
        if item and typeof(item) ~= "RBXScriptConnection" then
            if item.Parent then
                item:Destroy()
            end
        end
    end
    ViewmodelChamsHighlights = {}
    ViewmodelChamsOriginalColors = {}  -- Clear stored colors
end

-- Function to start Viewmodel Chams Rainbow
function StartViewmodelChamsRainbow()
    if ViewmodelChamsRainbowConnection then
        ViewmodelChamsRainbowConnection:Disconnect()
        ViewmodelChamsRainbowConnection = nil
    end
    
    ViewmodelChamsRainbowConnection = RunService.RenderStepped:Connect(function()
        if not ViewmodelChamsRainbowEnabled or not ViewmodelChamsEnabled then
            if ViewmodelChamsRainbowConnection then
                ViewmodelChamsRainbowConnection:Disconnect()
                ViewmodelChamsRainbowConnection = nil
            end
            return
        end
        
        -- Rainbow color calculation (HSV: 0-1 range)
        local hue = (tick() * 0.2) % 1  -- Slower speed for smooth transition
        ViewmodelChamsColor = Color3.fromHSV(hue, 1, 1)
        UpdateViewmodelChams()
    end)
end

-- Function to stop Viewmodel Chams Rainbow
function StopViewmodelChamsRainbow()
    if ViewmodelChamsRainbowConnection then
        ViewmodelChamsRainbowConnection:Disconnect()
        ViewmodelChamsRainbowConnection = nil
    end
end

-- Function to start third person (from new.lua)
function StartThirdPerson()
    if ThirdPersonEnabled and ThirdPersonKey then
        RunService:BindToRenderStep("ThirdPerson", 1, function()
            LocalPlayer.CameraMaxZoomDistance = ThirdPersonDistance
            LocalPlayer.CameraMinZoomDistance = ThirdPersonDistance
        end)
    else
        RunService:UnbindFromRenderStep("ThirdPerson")
        for v = 1, 5 do
            task.wait()
            LocalPlayer.CameraMaxZoomDistance = 0
            LocalPlayer.CameraMinZoomDistance = 0
        end
    end
end

-- Function to stop third person
function StopThirdPerson()
    RunService:UnbindFromRenderStep("ThirdPerson")
    for v = 1, 5 do
        task.wait()
        LocalPlayer.CameraMaxZoomDistance = 0
        LocalPlayer.CameraMinZoomDistance = 0
    end
end

-- Keybind handler for Third Person
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    if Input.KeyCode == ThirdPersonKey then
        -- Only allow keybind to work if toggle is enabled
        if not ThirdPersonToggleEnabled then
            return  -- Do nothing if toggle is off
        end
        
        -- Toggle the feature on/off
        ThirdPersonEnabled = not ThirdPersonEnabled
        StartThirdPerson()
    end
end)

-- Function to start anti-aim
function StartAntiAim()
    if AntiAimConnection then
        AntiAimConnection:Disconnect()
        AntiAimConnection = nil
    end
    
    AntiAimConnection = RunService.RenderStepped:Connect(function()
        if not AntiAimEnabled then
            if AntiAimConnection then
                AntiAimConnection:Disconnect()
                AntiAimConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Rotate character in opposite direction
        local currentCFrame = humanoidRootPart.CFrame
        local rotation = CFrame.Angles(0, math.rad(AntiAimSpeed), 0)
        humanoidRootPart.CFrame = currentCFrame * rotation
    end)
end

-- Function to stop anti-aim
function StopAntiAim()
    if AntiAimConnection then
        AntiAimConnection:Disconnect()
        AntiAimConnection = nil
    end
end

-- Function to start fake lag
function StartFakeLag()
    if FakeLagConnection then
        FakeLagConnection:Disconnect()
        FakeLagConnection = nil
    end
    
    local lastUpdate = tick()
    
    FakeLagConnection = RunService.Heartbeat:Connect(function()
        if not FakeLagEnabled then
            if FakeLagConnection then
                FakeLagConnection:Disconnect()
                FakeLagConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Freeze character position periodically
        if tick() - lastUpdate >= FakeLagDelay then
            humanoidRootPart.Anchored = true
            wait(0.01)
            humanoidRootPart.Anchored = false
            lastUpdate = tick()
        end
    end)
end

-- Function to stop fake lag
function StopFakeLag()
    if FakeLagConnection then
        FakeLagConnection:Disconnect()
        FakeLagConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Anchored = false
        end
    end
end

-- Function to start shoot through wall
function StartShootThroughWall()
    if ShootThroughWallConnection then
        ShootThroughWallConnection:Disconnect()
        ShootThroughWallConnection = nil
    end
    
    ShootThroughWallConnection = RunService.RenderStepped:Connect(function()
        if not ShootThroughWallEnabled then
            if ShootThroughWallConnection then
                ShootThroughWallConnection:Disconnect()
                ShootThroughWallConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local camera = Camera
        if not camera then return end
        
        -- Get current camera CFrame
        local currentCFrame = camera.CFrame
        
        -- Calculate forward direction (where camera is looking)
        local lookVector = currentCFrame.LookVector
        
        -- Move camera forward by the specified distance
        local forwardOffset = lookVector * ShootThroughWallDistance
        
        -- Set new camera position (slightly forward to see through walls)
        camera.CFrame = currentCFrame + forwardOffset
    end)
end

-- Function to stop shoot through wall
function StopShootThroughWall()
    if ShootThroughWallConnection then
        ShootThroughWallConnection:Disconnect()
        ShootThroughWallConnection = nil
    end
    
    -- Camera will automatically reset to normal position when connection is disconnected
end

-- Function to start hitbox expander
function StartHitboxExpander()
    if HitboxExpanderConnection then
        HitboxExpanderConnection:Disconnect()
        HitboxExpanderConnection = nil
    end
    
    -- Expand hitboxes for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            ExpandPlayerHitboxes(player)
        end
    end
    
    -- Handle new players joining
    HitboxExpanderConnection = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer and player.Character then
            ExpandPlayerHitboxes(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if HitboxExpanderEnabled then
                    ExpandPlayerHitboxes(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    -- Handle character respawns
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                if HitboxExpanderEnabled then
                    wait(0.1)  -- Wait for character to fully load
                    ExpandPlayerHitboxes(player)
                end
            end)
        end
    end
end

-- Function to expand hitboxes for a specific player
function ExpandPlayerHitboxes(player)
    if not player or not player.Character then return end
    
    local character = player.Character
    
    -- Expand hitboxes for important body parts
    local partsToExpand = {
        "Head",
        "HumanoidRootPart",
        "UpperTorso",
        "LowerTorso",
        "Torso"
    }
    
    for _, partName in ipairs(partsToExpand) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            -- Store original size if not already stored
            if not OriginalHitboxSizes[part] then
                OriginalHitboxSizes[part] = part.Size
            end
            
            -- Store original transparency if not already stored
            if not OriginalTransparency[part] then
                OriginalTransparency[part] = part.Transparency
            end
            
            -- Expand the hitbox
            part.Size = OriginalHitboxSizes[part] * HitboxExpanderSize
            
            -- Make parts transparent so they're invisible
            part.Transparency = 1.0  -- Very transparent (almost invisible)
            
            -- Make sure CanCollide is true so the hitbox works
            part.CanCollide = false
        end
    end
end

-- Function to stop hitbox expander
function StopHitboxExpander()
    if HitboxExpanderConnection then
        HitboxExpanderConnection:Disconnect()
        HitboxExpanderConnection = nil
    end
    
    -- Reset all hitboxes to original size and transparency
    for part, originalSize in pairs(OriginalHitboxSizes) do
        if part and part.Parent then
            part.Size = originalSize
            -- Reset transparency if we stored it
            if OriginalTransparency[part] then
                part.Transparency = OriginalTransparency[part]
            end
        end
    end
    
    -- Clear stored sizes and transparency
    OriginalHitboxSizes = {}
    OriginalTransparency = {}
end

-- ========== NOSPREAD FUNCTIONS ==========
-- NoSpread function (working version)
local function noSpread(weapon)
    if NoSpreadEnabled then
        local spread = weapon:FindFirstChild("Spread")
        if spread then
            for _, v in ipairs(spread:GetDescendants()) do
                if v:IsA("NumberValue") then
                    v.Value = 0
                end
            end
        end
    end
end

-- Function to start nospread
function StartNoSpread()
    if NoSpreadConnection then
        NoSpreadConnection:Disconnect()
        NoSpreadConnection = nil
    end
    
    local WeaponsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
    
    if WeaponsFolder then
        -- Apply to all existing weapons
        for _, weapon in ipairs(WeaponsFolder:GetChildren()) do
            noSpread(weapon)
        end
        
        -- Monitor for new weapons
        WeaponsFolder.ChildAdded:Connect(function(weapon)
            if NoSpreadEnabled then
                noSpread(weapon)
            end
        end)
        
        -- Continuously update spread values
        NoSpreadConnection = RunService.Heartbeat:Connect(function()
            if not NoSpreadEnabled then
                if NoSpreadConnection then
                    NoSpreadConnection:Disconnect()
                    NoSpreadConnection = nil
                end
                return
            end
            
            if WeaponsFolder then
                for _, weapon in ipairs(WeaponsFolder:GetChildren()) do
                    noSpread(weapon)
                end
            end
        end)
    end
end

-- Function to stop nospread
function StopNoSpread()
    if NoSpreadConnection then
        NoSpreadConnection:Disconnect()
        NoSpreadConnection = nil
    end
end

-- ========== SOUNDS FUNCTIONS ==========
-- Function to play hitsound
local function PlayHitsound()
    if not HitsoundsEnabled then return end
    
    local soundID = soundIDs[HitsoundsSound]
    if not soundID or soundID == "" then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundID
    sound.Volume = HitsoundsVolume / 10
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Function to play killsound
local function PlayKillsound()
    if not KillsoundsEnabled then return end
    
    local soundID = soundIDs[KillsoundsSound]
    if not soundID or soundID == "" then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundID
    sound.Volume = KillsoundsVolume / 10
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Hook hitsounds (when player deals damage)
local oldKills = 0
local oldDamage = 0

-- Check for kills
task.spawn(function()
    while true do
        task.wait(0.1)
        if LocalPlayer and LocalPlayer:FindFirstChild("Status") then
            local status = LocalPlayer.Status
            if status:FindFirstChild("Kills") then
                local currentKills = status.Kills.Value
                if currentKills > oldKills then
                    PlayKillsound()
                    oldKills = currentKills
                end
            end
        end
    end
end)

-- Check for hits (damage)
task.spawn(function()
    while true do
        task.wait(0.1)
        if LocalPlayer and LocalPlayer:FindFirstChild("Additionals") then
            local additionals = LocalPlayer.Additionals
            if additionals:FindFirstChild("TotalDamage") then
                local currentDamage = additionals.TotalDamage.Value
                if currentDamage > oldDamage then
                    PlayHitsound()
                    oldDamage = currentDamage
                end
            end
        end
    end
end)

-- ========== ATMOSPHERE FUNCTIONS ==========
-- Function to update ambience
function UpdateAmbience()
    if AmbienceEnabled then
        Lighting.OutdoorAmbient = AmbienceColor
        Lighting.Ambient = AmbienceColor
    else
        Lighting.OutdoorAmbient = Color3.fromRGB(165, 156, 140)
        Lighting.Ambient = Color3.fromRGB(130, 118, 95)
    end
end

-- Function to update force time
function UpdateForceTime()
    if ForceTimeEnabled then
        Lighting.ClockTime = ForceTimeValue
    else
        Lighting.ClockTime = 9
    end
end

-- Function to update custom saturation
function UpdateCustomSaturation()
    if not Camera:FindFirstChild("ColorCorrection") then
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Parent = Camera
    end
    
    local colorCorrection = Camera:FindFirstChild("ColorCorrection")
    if colorCorrection then
        if CustomSaturationEnabled then
            colorCorrection.TintColor = CustomSaturationColor
            colorCorrection.Saturation = CustomSaturationModifier / 100
        else
            colorCorrection.Saturation = 0
            colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        end
    end
end

-- Function to update custom bloom
function UpdateCustomBloom()
    if not Camera:FindFirstChild("Bloom") then
        local bloom = Instance.new("BloomEffect")
        bloom.Parent = Camera
    end
    
    local bloom = Camera:FindFirstChild("Bloom")
    if bloom then
        bloom.Enabled = CustomBloomEnabled
        if CustomBloomEnabled then
            bloom.Intensity = CustomBloomIntensity / 100
            bloom.Size = CustomBloomSize * 14 / 25
            bloom.Threshold = CustomBloomThreshold / 400
        else
            bloom.Intensity = 0
            bloom.Size = 0
            bloom.Threshold = 0
        end
    end
end

-- Function to update custom atmosphere
function UpdateCustomAtmosphere()
    if not Camera:FindFirstChild("Atmosphere") then
        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Camera
    end
    
    local atmosphere = Camera:FindFirstChild("Atmosphere")
    if atmosphere then
        if CustomAtmosphereEnabled then
            atmosphere.Color = CustomAtmosphereColor1
            atmosphere.Decay = CustomAtmosphereColor2
            atmosphere.Density = CustomAtmosphereDensity / 100
            atmosphere.Glare = CustomAtmosphereGlaze / 10
            atmosphere.Haze = CustomAtmosphereHaze / 10
        else
            atmosphere.Density = 0
            atmosphere.Glare = 0
            atmosphere.Haze = 0
        end
    end
end

-- Function to update custom brightness
function UpdateCustomBrightness()
    if CustomBrightnessEnabled then
        if CustomBrightnessMode == "Fullbright" then
            Lighting.Brightness = 10
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        elseif CustomBrightnessMode == "Nightmode" then
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(130, 118, 95)
        Lighting.OutdoorAmbient = Color3.fromRGB(165, 156, 140)
    end
end

-- Auto-update atmosphere features
RunService.RenderStepped:Connect(function()
    if ForceTimeEnabled then
        UpdateForceTime()
    end
    if AmbienceEnabled then
        UpdateAmbience()
    end
    if CustomSaturationEnabled then
        UpdateCustomSaturation()
    end
    if CustomBloomEnabled then
        UpdateCustomBloom()
    end
    if CustomAtmosphereEnabled then
        UpdateCustomAtmosphere()
    end
    if CustomBrightnessEnabled then
        UpdateCustomBrightness()
    end
end)

-- ========== LOCAL CHAMS FUNCTIONS ==========
-- Helper function to get selected name from dropdown
local function GetSelectedName(values)
    for i, v in pairs(values) do
        if v then
            return i
        end
    end
    return nil
end

-- Helper function to check if player is alive
local function IsPlayerAlive(character)
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health > 0 then
        return true
    else
        return false
    end
end

-- Function to save viewmodel (weapons and arms)
local function saveViewmodel()
    chammedobjects["Weapon Objects"] = {}
    chammedobjects["Arms"] = {}
    chammedobjects["Clothing"] = {}
    chammedobjects["Original"] = {}
    
    local character = LocalPlayer.Character
    if not character or not IsPlayerAlive(character) then
        return
    end
    
    local camera = Camera
    if not camera then return end
    
    if camera:FindFirstChild("Arms") then
        for i, v in pairs(camera.Arms:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Right Arm") and v:FindFirstChild("Left Arm") then
                table.insert(chammedobjects["Arms"], v["Right Arm"])
                table.insert(chammedobjects["Arms"], v["Left Arm"])
                
                local rGlove = v["Right Arm"]:FindFirstChild("RGlove") or v["Right Arm"]:FindFirstChild("Glove")
                local lGlove = v["Left Arm"]:FindFirstChild("LGlove") or v["Left Arm"]:FindFirstChild("Glove")
                if rGlove then table.insert(chammedobjects["Clothing"], rGlove) end
                if lGlove then table.insert(chammedobjects["Clothing"], lGlove) end
                
                local rSleeve = v["Right Arm"]:FindFirstChild("Sleeve")
                local lSleeve = v["Left Arm"]:FindFirstChild("Sleeve")
                if rSleeve then table.insert(chammedobjects["Clothing"], rSleeve) end
                if lSleeve then table.insert(chammedobjects["Clothing"], lSleeve) end
            elseif (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("SpecialMesh") or v:IsA("SurfaceAppearance")) and (v.Transparency == 0 or v.Name == "HumanoidRootPart") then
                if v.Name == "HumanoidRootPart" then
                    v.Transparency = 1
                else
                    table.insert(chammedobjects["Weapon Objects"], v)
                    local surfaceAppearance = v:FindFirstChild("SurfaceAppearance")
                    if surfaceAppearance then
                        table.insert(chammedobjects["Weapon Objects"], surfaceAppearance)
                    end
                end
            end
        end
    else
        return
    end
    
    -- Save original properties
    for idx, objects in pairs({chammedobjects["Arms"], chammedobjects["Clothing"], chammedobjects["Weapon Objects"]}) do
        for i, v in pairs(objects) do
            if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("SpecialMesh") then
                local property = {
                    Color = v.Color,
                    Material = v.Material,
                    Reflectance = v.Reflectance,
                    Transparency = v.Transparency
                }
                if v:IsA("MeshPart") then
                    property.TextureID = v.TextureID
                elseif v:IsA("SpecialMesh") then
                    property.TextureId = v.TextureId
                end
                chammedobjects["Original"][v] = property
                
                local hiddenMesh = v:FindFirstChildOfClass("MeshPart") or v:FindFirstChildOfClass("SpecialMesh")
                if hiddenMesh then
                    if hiddenMesh:IsA("MeshPart") then
                        chammedobjects["Original"][hiddenMesh] = {
                            TextureID = hiddenMesh.TextureID
                        }
                    else
                        chammedobjects["Original"][hiddenMesh] = {
                            TextureId = hiddenMesh.TextureId,
                            VertexColor = hiddenMesh.VertexColor
                        }
                    end
                end
            elseif v:IsA("SurfaceAppearance") then
                chammedobjects["Original"][v] = {
                    Parent = v.Parent
                }
            end
        end
    end
end

-- Function to update weapon chams
function UpdateWeaponChams()
    -- Reset previous chams
    for i, v in pairs(chammedobjects["Colored Weapons"]) do
        local originalproperties = chammedobjects["Original"][v]
        if originalproperties then
            for i2, v2 in pairs(originalproperties) do
                v[i2] = v2
            end
        end
    end
    chammedobjects["Colored Weapons"] = {}
    
    if not WeaponChamsEnabled then
        return
    end
    
    saveViewmodel()
    
    local animation = ""
    local thing = chammedobjects["Colored Weapons"]
    local materialName = WeaponChamsMaterial
    if materialName == "Ghost" then
        animation = forcefieldanimations[WeaponChamsTexture] or forcefieldanimations["off"]
    end
    
    for i, v in pairs(chammedobjects["Weapon Objects"]) do
        if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            table.insert(thing, v)
            v.Transparency = WeaponChamsTransparency / 100
            if v.Name ~= "Dot" then
                v.Color = WeaponChamsColor
                v.Material = materials[materialName] or materials["Ghost"]
                v.Reflectance = WeaponChamsReflectance / 100
                if v:IsA("MeshPart") then
                    v.TextureID = animation
                end
                if v:IsA("SpecialMesh") then
                    v.TextureId = animation
                end
                local hiddenMesh = v:FindFirstChildOfClass("MeshPart") or v:FindFirstChildOfClass("SpecialMesh")
                if hiddenMesh then
                    if hiddenMesh:IsA("MeshPart") then
                        hiddenMesh.TextureID = animation
                        hiddenMesh.Color = v.Color
                        hiddenMesh.Material = v.Material
                        hiddenMesh.Reflectance = v.Reflectance
                    else
                        hiddenMesh.TextureId = animation
                        hiddenMesh.VertexColor = Vector3.new(v.Color.R, v.Color.G, v.Color.B)
                    end
                    table.insert(thing, hiddenMesh)
                end
            end
        elseif v:IsA("SurfaceAppearance") then
            table.insert(thing, v)
            v.Parent = nil
        end
    end
end

-- Function to update arm chams
function UpdateArmChams()
    -- Reset previous chams
    for i, v in pairs(chammedobjects["Colored Arms"]) do
        local originalproperties = chammedobjects["Original"][v]
        if originalproperties then
            for i2, v2 in pairs(originalproperties) do
                v[i2] = v2
            end
        end
    end
    chammedobjects["Colored Arms"] = {}
    
    if not ArmsChangerEnabled then
        return
    end
    
    saveViewmodel()
    
    local thing = chammedobjects["Colored Arms"]
    local animation = ""
    local materialName = ArmsChangerMaterial
    if materialName == "Ghost" then
        animation = forcefieldanimations[ArmsChangerTexture] or forcefieldanimations["off"]
    end
    
    for idx, objects in pairs({chammedobjects["Arms"], chammedobjects["Clothing"]}) do
        for i, v in pairs(objects) do
            if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("SpecialMesh") then
                v.Color = (idx == 1 and ArmsChangerColor1) or ArmsChangerColor2
                v.Transparency = (idx == 1 and ArmsTransparency) or SleeveTransparency
                v.Transparency = v.Transparency / 100
                v.Material = materials[materialName] or materials["Ghost"]
                table.insert(thing, v)
                v.Reflectance = (idx == 1 and ArmsReflectance) or SleeveReflectance
                v.Reflectance = v.Reflectance / 100
                if v:IsA("SpecialMesh") then
                    v.VertexColor = Vector3.new(v.Color.R, v.Color.G, v.Color.B)
                    if v:IsA("MeshPart") then
                        v.TextureID = animation
                    else
                        v.TextureId = animation
                    end
                end
                local hiddenMesh = v:FindFirstChildOfClass("MeshPart") or v:FindFirstChildOfClass("SpecialMesh")
                if hiddenMesh then
                    table.insert(thing, hiddenMesh)
                    if hiddenMesh:IsA("MeshPart") then
                        hiddenMesh.TextureID = animation
                    else
                        hiddenMesh.VertexColor = Vector3.new(v.Color.R, v.Color.G, v.Color.B)
                        hiddenMesh.TextureId = animation
                    end
                end
            end
        end
    end
end

-- Function to update local player chams
function UpdateLocalPlayerChams()
    if not (ThirdPersonEnabled and CharacterChamsEnabled and IsPlayerAlive(LocalPlayer.Character)) then
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local materialName = CharacterChamsMaterial
    local material = materials[materialName] or materials["Ghost"]
    local color = CharacterChamsColor
    local transparency = CharacterChamsTransparency / 100
    local texture = ""
    
    if materialName == "Ghost" then
        texture = forcefieldanimations[CharacterChamsTexture] or forcefieldanimations["off"]
    end
    
    local function applyChamsToPart(part)
        if part.Name == "HumanoidRootPart" or part.Name == "___" or part.Transparency == 1 then return end
        part.Color = color
        part.Material = material
        part.Transparency = transparency
        
        if part:IsA("UnionOperation") then
            part.UsePartColor = true
        elseif part:IsA("MeshPart") then
            part.TextureID = texture
        end
        
        local mesh = part:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.VertexColor = Vector3.new(color.R, color.G, color.B)
            mesh.TextureId = texture
        end
    end
    
    local function applyChamsToAccessory(accessory)
        local handle = accessory:FindFirstChild("Handle")
        if not handle then return end
        
        for _, child in pairs(accessory:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                child.Color = color
                child.Material = material
                child.Transparency = transparency
                
                if child:IsA("MeshPart") then
                    child.TextureID = texture
                elseif child:IsA("SpecialMesh") then
                    child.TextureId = texture
                    child.VertexColor = Vector3.new(color.R, color.G, color.B)
                end
                
                local mesh = child:FindFirstChildOfClass("MeshPart") or child:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    if mesh:IsA("MeshPart") then
                        mesh.Color = color
                        mesh.Material = material
                        mesh.Reflectance = child.Reflectance
                        mesh.TextureID = texture
                    else
                        mesh.VertexColor = Vector3.new(color.R, color.G, color.B)
                        mesh.TextureId = texture
                    end
                end
            end
        end
    end
    
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            applyChamsToPart(v)
        elseif v:IsA("Accessory") then
            applyChamsToAccessory(v)
        elseif v:IsA("Shirt") or v:IsA("Pants") then
            v:Destroy()
        end
    end
end

-- Auto-update chams when camera changes
local CanApplyChamses = true
Camera.ChildAdded:Connect(function()
    CanApplyChamses = false
    task.wait()
    saveViewmodel()
    CanApplyChamses = true
end)

-- Auto-update chams on stepped
RunService.Stepped:Connect(function()
    if CanApplyChamses then
        if WeaponChamsEnabled then
            UpdateWeaponChams()
        end
        if ArmsChangerEnabled then
            UpdateArmChams()
        end
        if CharacterChamsEnabled and ThirdPersonEnabled then
            UpdateLocalPlayerChams()
        end
    end
end)

-- Update exploits on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.1)
    if SpinBotEnabled then
        StartSpinBot()
    end
    if SelfChamsEnabled then
        StartSelfChams()
    end
    if ViewmodelChamsEnabled then
        StartViewmodelChams()
        if ViewmodelChamsRainbowEnabled then
            StartViewmodelChamsRainbow()
        end
    end
    if ThirdPersonEnabled then
        StartThirdPerson()
    end
    if AntiAimEnabled then
        StartAntiAim()
    end
    if FakeLagEnabled then
        StartFakeLag()
    end
    if ShootThroughWallEnabled then
        StartShootThroughWall()
    end
    if HitboxExpanderEnabled then
        StartHitboxExpander()
    end
    if NoSpreadEnabled then
        StartNoSpread()
    end
    -- Reset and reapply local chams
    task.wait(0.5)
    if WeaponChamsEnabled then
        saveViewmodel()
        UpdateWeaponChams()
    end
    if ArmsChangerEnabled then
        saveViewmodel()
        UpdateArmChams()
    end
    if CharacterChamsEnabled then
        UpdateLocalPlayerChams()
    end
end)

-- ========== PLAYER FEATURES ==========
-- Function to update walkspeed
function UpdateWalkspeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if WalkspeedEnabled then
        OriginalWalkspeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = WalkspeedValue
    else
        humanoid.WalkSpeed = OriginalWalkspeed
    end
end

-- Function to update jump power
function UpdateJumpPower()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if JumpPowerEnabled then
        OriginalJumpPower = humanoid.JumpPower
        humanoid.JumpPower = JumpPowerValue
    else
        humanoid.JumpPower = OriginalJumpPower
    end
end

-- Function to update FOV
function UpdateFOV()
    if FOVChangerEnabled then
        OriginalFOV = Camera.FieldOfView
        Camera.FieldOfView = FOVChangerValue
    else
        Camera.FieldOfView = OriginalFOV
    end
end

-- Function to update camera FOV
function UpdateCameraFOV()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or character:FindFirstChild("Humanoid").Health <= 0 then
        return
    end
    
    -- Check if scope is visible
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local gui = playerGui:FindFirstChild("GUI")
        if gui then
            local crosshairs = gui:FindFirstChild("Crosshairs")
            if crosshairs then
                local scope = crosshairs:FindFirstChild("Scope")
                if scope and scope.Visible == true and not CameraChangeFieldOfViewInScope then
                    return
                end
            end
        end
    end
    
    Camera.FieldOfView = CameraFieldOfView
end

-- Function to update remove flash
function UpdateRemoveFlash()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local blnd = playerGui:FindFirstChild("Blnd")
        if blnd then
            local blind = blnd:FindFirstChild("Blind")
            if blind then
                blind.Visible = not RemoveFlashEnabled
            end
        end
    end
end

-- Function to start viewmodel changer
function StartViewmodelChanger()
    if ViewmodelConnection then
        ViewmodelConnection:Disconnect()
        ViewmodelConnection = nil
    end
    
    ViewmodelConnection = RunService.RenderStepped:Connect(function()
        if not ViewmodelChangerEnabled then
            if ViewmodelConnection then
                ViewmodelConnection:Disconnect()
                ViewmodelConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local camera = Camera
        if not camera then return end
        
        -- Find arms in camera
        local arms = camera:FindFirstChild("Arms")
        if arms then
            for _, v in pairs(arms:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    local currentCFrame = v.CFrame
                    -- Apply angle rotation
                    local angleRotation = CFrame.Angles(
                        math.rad(ViewmodelAngleX - 180),
                        math.rad(ViewmodelAngleY - 180),
                        math.rad(ViewmodelAngleZ - 180)
                    )
                    -- Apply CFrame offset
                    local cframeOffset = CFrame.new(
                        math.rad(ViewmodelCFrameX - 180),
                        math.rad(ViewmodelCFrameY - 180),
                        math.rad(ViewmodelCFrameZ - 180)
                    )
                    v.CFrame = currentCFrame * angleRotation * cframeOffset
                end
            end
        end
    end)
end

-- Function to stop viewmodel changer
function StopViewmodelChanger()
    if ViewmodelConnection then
        ViewmodelConnection:Disconnect()
        ViewmodelConnection = nil
    end
end

-- Auto-update camera FOV
RunService.RenderStepped:Connect(function()
    UpdateCameraFOV()
end)

-- Auto-update remove flash
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    UpdateRemoveFlash()
end)

-- Initial update
task.spawn(function()
    task.wait(1)
    UpdateRemoveFlash()
end)

-- ========== HEALTH BAR ESP FUNCTIONS ==========
function CreateHealthBarESP(player)
    if not player or not player.Character then return end
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = true
    healthBar.Color = HealthBarESPColor1
    healthBar.Thickness = 1
    healthBar.Transparency = 1
    healthBar.Filled = true
    
    local healthBarOutline = Drawing.new("Square")
    healthBarOutline.Visible = true
    healthBarOutline.Color = Color3.fromRGB(10, 10, 10)
    healthBarOutline.Thickness = 1
    healthBarOutline.Transparency = 0.7
    healthBarOutline.Filled = true
    
    HealthBarLabels[player] = healthBar
    HealthBarOutlines[player] = healthBarOutline
end

function UpdateHealthBarESP(player)
    if not HealthBarLabels[player] or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
        if HealthBarLabels[player] then
            HealthBarLabels[player].Visible = false
        end
        if HealthBarOutlines[player] then
            HealthBarOutlines[player].Visible = false
        end
        return
    end
    
    local characterCFrame = humanoidRootPart.CFrame
    local boxWidth = 2.5
    local boxHeight = 5.2
    local boxDepth = 1.5
    
    -- Calculate bounding box corners
    local corners = {
        characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2, -boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2, -boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, -boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, -boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, boxHeight/2, boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, boxHeight/2, boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(-boxWidth/2, -boxHeight/2, boxDepth/2)),
        characterCFrame:PointToWorldSpace(Vector3.new(boxWidth/2, -boxHeight/2, boxDepth/2))
    }
    
    -- Project to screen space
    local screenCorners = {}
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    local hasValidCorner = false
    
    for _, corner in ipairs(corners) do
        local screenPoint, onScreen = Camera:WorldToViewportPoint(corner)
        if onScreen then
            table.insert(screenCorners, screenPoint)
            minX = math.min(minX, screenPoint.X)
            maxX = math.max(maxX, screenPoint.X)
            minY = math.min(minY, screenPoint.Y)
            maxY = math.max(maxY, screenPoint.Y)
            hasValidCorner = true
        end
    end
    
    if hasValidCorner then
        local fullSize = maxY - minY
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local chunk = fullSize * healthPercent
        
        -- Position health bar on the left side
        local barX = minX - 5
        local barY = maxY - chunk
        local barWidth = 2
        local barHeight = chunk
        
        -- Update health bar
        HealthBarLabels[player].Size = Vector2.new(barWidth, barHeight)
        HealthBarLabels[player].Position = Vector2.new(barX, barY)
        
        -- Update outline
        if HealthBarOutlines[player] then
            HealthBarOutlines[player].Size = Vector2.new(4, fullSize + 2)
            HealthBarOutlines[player].Position = Vector2.new(barX - 1, minY - 1)
            HealthBarOutlines[player].Visible = true
        end
        
        if HealthBarESPGradient then
            local color = HealthBarESPColor1:Lerp(HealthBarESPColor2, healthPercent)
            HealthBarLabels[player].Color = color
        else
            HealthBarLabels[player].Color = HealthBarESPColor1
        end
        
        HealthBarLabels[player].Visible = true
    else
        HealthBarLabels[player].Visible = false
        if HealthBarOutlines[player] then
            HealthBarOutlines[player].Visible = false
        end
    end
end

function UpdateHealthBarESPColors()
    for player, bar in pairs(HealthBarLabels) do
        if bar and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                if HealthBarESPGradient then
                    bar.Color = HealthBarESPColor1:Lerp(HealthBarESPColor2, healthPercent)
                else
                    bar.Color = HealthBarESPColor1
                end
            end
        end
    end
end

function StartHealthBarESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) then
            if player.Character then
                CreateHealthBarESP(player)
            else
                local characterConnection
                characterConnection = player.CharacterAdded:Connect(function(character)
                    if HealthBarESPEnabled then
                        CreateHealthBarESP(player)
                    end
                    characterConnection:Disconnect()
                end)
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer or IsTeammate(player) then return end
        if player.Character then
            CreateHealthBarESP(player)
        else
            local characterConnection
            characterConnection = player.CharacterAdded:Connect(function(character)
                if HealthBarESPEnabled then
                    CreateHealthBarESP(player)
                end
                characterConnection:Disconnect()
            end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if HealthBarLabels[player] then
            HealthBarLabels[player]:Remove()
            HealthBarLabels[player] = nil
        end
        if HealthBarOutlines[player] then
            HealthBarOutlines[player]:Remove()
            HealthBarOutlines[player] = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if HealthBarESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsTeammate(player) and player.Character and not HealthBarLabels[player] then
                    CreateHealthBarESP(player)
                end
            end
            
            for player, bar in pairs(HealthBarLabels) do
                if bar and player.Character and not IsTeammate(player) then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        bar.Visible = false
                    else
                        UpdateHealthBarESP(player)
                    end
                elseif not PlayerStillExists(player) or IsTeammate(player) then
                    if HealthBarLabels[player] then
                        HealthBarLabels[player]:Remove()
                        HealthBarLabels[player] = nil
                    end
                    if HealthBarOutlines[player] then
                        HealthBarOutlines[player]:Remove()
                        HealthBarOutlines[player] = nil
                    end
                end
            end
        end
    end)
end

function StopHealthBarESP()
    for player, bar in pairs(HealthBarLabels) do
        if bar then
            bar:Remove()
        end
    end
    for player, outline in pairs(HealthBarOutlines) do
        if outline then
            outline:Remove()
        end
    end
    HealthBarLabels = {}
    HealthBarOutlines = {}
end

-- ========== SCOPE FUNCTIONS ==========
local Crosshairs = nil
local ScopeConnection = nil

function UpdateRemoveScope()
    if not RemoveScopeEnabled then
        if ScopeConnection then
            ScopeConnection:Disconnect()
            ScopeConnection = nil
        end
        return
    end
    
    -- Get Crosshairs UI
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        if playerGui then
            Crosshairs = playerGui:WaitForChild("GUI", 10)
            if Crosshairs then
                Crosshairs = Crosshairs:WaitForChild("Crosshairs", 10)
            end
        end
    end)
    
    if not Crosshairs then return end
    
    -- Update Crosshairs visibility
    if ScopeConnection then
        ScopeConnection:Disconnect()
    end
    
    ScopeConnection = RunService.RenderStepped:Connect(function()
        if not RemoveScopeEnabled or not Crosshairs then
            if ScopeConnection then
                ScopeConnection:Disconnect()
                ScopeConnection = nil
            end
            return
        end
        
        for _, v in pairs(Crosshairs:GetChildren()) do
            if v.Name:match("Frame") then
                v.BackgroundTransparency = RemoveScopeEnabled and 1 or 0
            elseif v.Name:match("Scope") then
                v.ImageTransparency = RemoveScopeEnabled and 1 or 0
            end
        end
    end)
end

function UpdateChangeScope()
    -- Change scope is handled via hookmetamethod and UI updates
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        if playerGui then
            local gui = playerGui:WaitForChild("GUI", 10)
            if gui then
                local scopeLabel = gui:FindFirstChild("ScopeLabel")
                if not scopeLabel then
                    scopeLabel = Instance.new("ImageLabel")
                    scopeLabel.Name = "ScopeLabel"
                    scopeLabel.Parent = gui
                end
                
                local scopeImages = {
                    ["ahueno"] = "rbxassetid://89734938358129",
                    ["pizdec"] = "rbxassetid://94612942804832",
                    ["porno"] = "rbxassetid://99619927433581"
                }
                
                if ChangeScopeEnabled and ChangeScopeType then
                    local imageId = scopeImages[ChangeScopeType] or scopeImages["ahueno"]
                    scopeLabel.Image = imageId
                    scopeLabel.ImageTransparency = 1
                else
                    scopeLabel.ImageTransparency = 1
                end
            end
        end
    end)
end

-- Hook for Remove Scope Blur
if hookmetamethod then
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, k, v)
        if RemoveScopeEnabled and self.Name == "Blur" and self.Parent and self.Parent.Name == "Scope" then
            return oldNewIndex(self, k, 0)
        end
        return oldNewIndex(self, k, v)
    end)
end

-- Function to start fly
function StartFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        if not bodyVelocity or not bodyVelocity.Parent then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = humanoidRootPart
        end
        
        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Get movement input
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        
        -- Vertical movement
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Normalize and apply speed
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * FlySpeed
        end
        
        bodyVelocity.Velocity = moveDirection
    end)
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(0.1) -- Wait for character to fully load
        if FlyEnabled then
            StartFly()
        end
    end)
end

-- Function to stop fly
function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            for _, v in pairs(humanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end

-- Function to start noclip
function StartNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(0.1) -- Wait for character to fully load
        if NoclipEnabled then
            StartNoclip()
        end
    end)
end

-- Function to stop noclip
function StopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Update character features on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.1) -- Wait for character to fully load
    if WalkspeedEnabled then
        UpdateWalkspeed()
    end
    if JumpPowerEnabled then
        UpdateJumpPower()
    end
    if FlyEnabled then
        StartFly()
    end
    if NoclipEnabled then
        StartNoclip()
    end
end)

-- Input Handler for Shoot Through Wall Keybind
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    -- Check if Shoot Through Wall keybind is pressed
    -- Only work if Shoot Through Wall toggle is enabled (like Aimbot)
    if Input.KeyCode == ShootThroughWallKey then
        -- Only allow keybind to work if toggle is enabled
        if not ShootThroughWallToggleEnabled then
            return  -- Do nothing if toggle is off
        end
        
        -- Toggle the feature on/off
        ShootThroughWallEnabled = not ShootThroughWallEnabled
        if ShootThroughWallEnabled then
            StartShootThroughWall()
            Notification:Notify({
                Title = "Shoot Through Wall",
                Content = "Enabled - Camera moved forward",
                Duration = 2,
                Icon = "info"
            })
        else
            StopShootThroughWall()
            Notification:Notify({
                Title = "Shoot Through Wall",
                Content = "Disabled - Camera reset",
                Duration = 2,
                Icon = "info"
            })
        end
    end
end)



-- Initialize
Notification:Notify({
    Title = "Successfully Initialized!",
    Content = "Have Fun!",
    Duration = 5,
    Icon = "check"
})
