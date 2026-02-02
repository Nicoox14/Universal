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

local LocalPlayer = Players.LocalPlayer

-- Function to check if a player is a teammate (DISABLED - always returns false except for LocalPlayer)
local function IsTeammate(player)
    -- Team check completely disabled - show all players
    if player == LocalPlayer then
        return true
    end
    return false  -- Never filter out any players
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

-- Variables for Player features
local WalkspeedEnabled = false
local WalkspeedValue = 16
local JumpPowerEnabled = false
local JumpPowerValue = 50
local FOVChangerEnabled = false
local FOVChangerValue = 70
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local NoclipConnection = nil
local FlyConnection = nil
local OriginalWalkspeed = 16
local OriginalJumpPower = 50
local OriginalFOV = 70

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
local ThirdPersonDistance = 10
local AntiAimEnabled = false
local AntiAimSpeed = 10
local FakeLagEnabled = false
local FakeLagDelay = 0.1
local RejoinEnabled = false
local SelfChamsHighlights = {}
local ViewmodelChamsHighlights = {}
local ViewmodelChamsConnection = nil
local ThirdPersonConnection = nil
local SpinBotConnection = nil
local AntiAimConnection = nil
local FakeLagConnection = nil
local ShootThroughWallEnabled = false
local ShootThroughWallKey = Enum.KeyCode.X
local ShootThroughWallDistance = 2  -- Distance to move camera forward in studs
local ShootThroughWallConnection = nil
local HitboxExpanderEnabled = false
local HitboxExpanderSize = 6.5  -- Multiplier for hitbox size (1.5 = 50% larger)
local HitboxExpanderConnection = nil
local OriginalHitboxSizes = {}  -- Store original sizes
local OriginalTransparency = {}  -- Store original transparency

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
end

-- ========== PLAYER TAB ==========
do
    local MovementSection = PlayerTab:AddSection({
        Position = 'left',
        Name = "MOVEMENT"
    })

    local CameraSection = PlayerTab:AddSection({
        Position = 'center',
        Name = "CAMERA"
    })

    local SettingsSection = PlayerTab:AddSection({
        Position = 'right',
        Name = "SETTINGS"
    })

    -- Movement Section: Only Toggles
    MovementSection:AddToggle({
        Name = "Walkspeed",
        Default = false,
        Callback = function(Value)
            WalkspeedEnabled = Value
            UpdateWalkspeed()
        end,
    })

    MovementSection:AddToggle({
        Name = "Jump Power",
        Default = false,
        Callback = function(Value)
            JumpPowerEnabled = Value
            UpdateJumpPower()
        end,
    })

    MovementSection:AddToggle({
        Name = "Fly",
        Default = false,
        Callback = function(Value)
            FlyEnabled = Value
            if Value then
                StartFly()
            else
                StopFly()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(Value)
            NoclipEnabled = Value
            if Value then
                StartNoclip()
            else
                StopNoclip()
            end
        end,
    })

    -- Camera Section: Only FOV Changer Toggle
    CameraSection:AddToggle({
        Name = "FOV Changer",
        Default = false,
        Callback = function(Value)
            FOVChangerEnabled = Value
            UpdateFOV()
        end,
    })

    -- Settings Section: All Sliders in order
    SettingsSection:AddSlider({
        Name = "Walkspeed Value",
        Min = 0,
        Max = 200,
        Default = 16,
        Type = " Studs/s",
        Callback = function(Value)
            WalkspeedValue = Value
            if WalkspeedEnabled then
                UpdateWalkspeed()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Jump Power Value",
        Min = 0,
        Max = 200,
        Default = 50,
        Type = " Power",
        Callback = function(Value)
            JumpPowerValue = Value
            if JumpPowerEnabled then
                UpdateJumpPower()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "FOV Value",
        Min = 0,
        Max = 120,
        Default = 70,
        Type = " Degrees",
        Callback = function(Value)
            FOVChangerValue = Value
            if FOVChangerEnabled then
                UpdateFOV()
            end
        end,
    })

    SettingsSection:AddSlider({
        Name = "Fly Speed",
        Min = 0,
        Max = 200,
        Default = 50,
        Type = " Studs/s",
        Callback = function(Value)
            FlySpeed = Value
        end,
    })
end

-- ========== EXPLOITS TAB ==========
do
    local MovementSection = ExploitsTab:AddSection({
        Position = 'left',
        Name = "EXPLOITS"
    })

    local VisualsSection = ExploitsTab:AddSection({
        Position = 'center',
        Name = "VISUALS"
    })

    local SettingsSection = ExploitsTab:AddSection({
        Position = 'right',
        Name = "SETTINGS"
    })

    -- Movement Section: Only Toggles
    MovementSection:AddToggle({
        Name = "Spin Bot",
        Default = false,
        Callback = function(Value)
            SpinBotEnabled = Value
            if Value then
                StartSpinBot()
            else
                StopSpinBot()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Anti-Aim",
        Default = false,
        Callback = function(Value)
            AntiAimEnabled = Value
            if Value then
                StartAntiAim()
            else
                StopAntiAim()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Fake Lag",
        Default = false,
        Callback = function(Value)
            FakeLagEnabled = Value
            if Value then
                StartFakeLag()
            else
                StopFakeLag()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Shoot Through Wall",
        Default = false,
        Callback = function(Value)
            ShootThroughWallEnabled = Value
            if Value then
                StartShootThroughWall()
            else
                StopShootThroughWall()
            end
        end,
    })

    MovementSection:AddToggle({
        Name = "Silent Aim",
        Default = false,
        Callback = function(Value)
            HitboxExpanderEnabled = Value
            if Value then
                StartHitboxExpander()
            else
                StopHitboxExpander()
            end
        end,
    })

    -- Visuals Section: Only Toggles
    VisualsSection:AddToggle({
        Name = "Self Chams",
        Default = false,
        Callback = function(Value)
            SelfChamsEnabled = Value
            if Value then
                StartSelfChams()
            else
                StopSelfChams()
            end
        end,
    })

    VisualsSection:AddToggle({
        Name = "Viewmodel Chams",
        Default = false,
        Callback = function(Value)
            ViewmodelChamsEnabled = Value
            if Value then
                StartViewmodelChams()
                if ViewmodelChamsRainbowEnabled then
                    StartViewmodelChamsRainbow()
                end
            else
                StopViewmodelChams()
                StopViewmodelChamsRainbow()
            end
        end,
    })

    VisualsSection:AddToggle({
        Name = "Viewmodel Chams Rainbow (RGB)",
        Default = false,
        Callback = function(Value)
            ViewmodelChamsRainbowEnabled = Value
            if Value then
                if ViewmodelChamsEnabled then
                    StartViewmodelChamsRainbow()
                end
            else
                StopViewmodelChamsRainbow()
            end
        end,
    })

    VisualsSection:AddToggle({
        Name = "Third Person",
        Default = false,
        Callback = function(Value)
            ThirdPersonEnabled = Value
            if Value then
                StartThirdPerson()
            else
                StopThirdPerson()
            end
        end,
    })

    -- Settings Section: All Sliders and Keybinds in order
    SettingsSection:AddSlider({
        Name = "Spin Bot Speed",
        Min = 0,
        Max = 100,
        Default = 20,
        Type = " Speed",
        Callback = function(Value)
            SpinBotSpeed = Value
        end,
    })

    SettingsSection:AddSlider({
        Name = "Anti-Aim Speed",
        Min = 0,
        Max = 50,
        Default = 10,
        Type = " Speed",
        Callback = function(Value)
            AntiAimSpeed = Value
        end,
    })

    SettingsSection:AddSlider({
        Name = "Fake Lag Delay",
        Min = 0,
        Max = 1,
        Round = 2,
        Default = 0.1,
        Type = " Seconds",
        Callback = function(Value)
            FakeLagDelay = Value
        end,
    })

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

    SettingsSection:AddSlider({
        Name = "Third Person Dist",
        Min = 0,
        Max = 50,
        Default = 10,
        Type = " Studs",
        Callback = function(Value)
            ThirdPersonDistance = Value
        end,
    })

    SettingsSection:AddColorPicker({
        Name = "Self Chams Color",
        Default = Color3.fromRGB(255, 0, 255),
        Callback = function(Value)
            SelfChamsColor = Value
            UpdateSelfChams()
        end
    })

    SettingsSection:AddColorPicker({
        Name = "Viewmodel Chams Color",
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(Value)
            ViewmodelChamsColor = Value
            UpdateViewmodelChams()
        end
    })

    SettingsSection:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end,
    })

    SettingsSection:AddButton({
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

    SettingsSection:AddButton({
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
        if player == LocalPlayer then return end
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
        if player == LocalPlayer then return end
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
        if player == LocalPlayer then return end
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
        if player == LocalPlayer then return end
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

-- Function to start third person (SIMPLE VERSION)
function StartThirdPerson()
    if ThirdPersonConnection then
        ThirdPersonConnection:Disconnect()
        ThirdPersonConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        -- Make character visible by resetting transparency of all parts
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
                -- Also make sure LocalTransparencyModifier doesn't hide it
                for _, modifier in pairs(part:GetDescendants()) do
                    if modifier:IsA("LocalTransparencyModifier") then
                        modifier.Transparency = 0
                    end
                end
            end
        end
    end
    
    -- Set camera type to scriptable
    Camera.CameraType = Enum.CameraType.Scriptable
    
    ThirdPersonConnection = RunService.RenderStepped:Connect(function()
        if not ThirdPersonEnabled then
            if ThirdPersonConnection then
                ThirdPersonConnection:Disconnect()
                ThirdPersonConnection = nil
            end
            Camera.CameraType = Enum.CameraType.Custom
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Keep character visible
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
                -- Disable LocalTransparencyModifier
                for _, modifier in pairs(part:GetDescendants()) do
                    if modifier:IsA("LocalTransparencyModifier") then
                        modifier.Transparency = 0
                    end
                end
            end
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not humanoidRootPart then return end
        
        -- Set camera subject to humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            Camera.CameraSubject = humanoid
        end
        
        -- Calculate camera position behind character
        local characterCFrame = humanoidRootPart.CFrame
        local cameraOffset = characterCFrame.LookVector * -ThirdPersonDistance
        local cameraHeight = Vector3.new(0, 2, 0) -- Slightly above character
        
        local cameraPosition = humanoidRootPart.Position + cameraOffset + cameraHeight
        local lookAtPosition = head and head.Position or humanoidRootPart.Position
        
        -- Set camera CFrame
        Camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
    end)
    
    -- Handle character respawn
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        wait(0.1)
        if ThirdPersonEnabled then
            -- Make new character visible
            for _, part in pairs(newCharacter:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
            end
        end
    end)
end

-- Function to stop third person
function StopThirdPerson()
    if ThirdPersonConnection then
        ThirdPersonConnection:Disconnect()
        ThirdPersonConnection = nil
    end
    
    Camera.CameraType = Enum.CameraType.Custom
end

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
    if Input.KeyCode == ShootThroughWallKey then
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
