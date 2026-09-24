--[[
	SISTEMA COMPLETO DE SERVIDOR PRIVADO
	Versión Definitiva + Confirmación + Arrastrar + Botón flotante
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TeleportEvent = ReplicatedStorage:WaitForChild("TeleportToPrivateServer")

--========================
-- CONFIGURACIÓN
--========================
local COOLDOWN = 12
local TOGGLE_KEY = Enum.KeyCode.P
local isOnCooldown = false
local isProcessing = false
local isOpen = false
local isDragging = false
local dragStart = nil
local startPos = nil

--========================
-- SONIDOS
--========================
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.45
clickSound.Parent = SoundService

local successSound = Instance.new("Sound")
successSound.SoundId = "rbxassetid://6026984224"
successSound.Volume = 0.55
successSound.Parent = SoundService

--========================
-- CREAR INTERFAZ PRINCIPAL
--========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PrivateServerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 210)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 1
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 90)
stroke.Thickness = 1.8
stroke.Transparency = 1
stroke.Parent = mainFrame

-- Título (también sirve para arrastrar)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 15, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Servidor Privado"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Botón Cerrar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -42, 0, 12)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 36)
statusLabel.Position = UDim2.new(0.05, 0, 0, 55)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Listo para cambiar de servidor"
statusLabel.TextColor3 = Color3.fromRGB(170, 170, 190)
statusLabel.TextSize = 15
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Botón principal
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.86, 0, 0, 46)
button.Position = UDim2.new(0.07, 0, 0, 105)
button.BackgroundColor3 = Color3.fromRGB(35, 115, 255)
button.Text = "Cambiar a Server Priv"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 11)
buttonCorner.Parent = button

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(20, 80, 200)
buttonStroke.Thickness = 1.6
buttonStroke.Parent = button

-- Texto de ayuda
local helpLabel = Instance.new("TextLabel")
helpLabel.Size = UDim2.new(1, 0, 0, 22)
helpLabel.Position = UDim2.new(0, 0, 1, -28)
helpLabel.BackgroundTransparency = 1
helpLabel.Text = "Presiona P para abrir/cerrar"
helpLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
helpLabel.TextSize = 13
helpLabel.Font = Enum.Font.Gotham
helpLabel.Parent = mainFrame

--========================
-- BOTÓN FLOTANTE
--========================
local floatButton = Instance.new("TextButton")
floatButton.Name = "FloatButton"
floatButton.Size = UDim2.new(0, 56, 0, 56)
floatButton.Position = UDim2.new(1, -74, 0.5, -28)
floatButton.BackgroundColor3 = Color3.fromRGB(35, 115, 255)
floatButton.Text = "SP"
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.TextSize = 18
floatButton.Font = Enum.Font.GothamBold
floatButton.AutoButtonColor = false
floatButton.Visible = true
floatButton.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(20, 80, 200)
floatStroke.Thickness = 2.2
floatStroke.Parent = floatButton

--========================
-- FUNCIONES
--========================
local function setStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color or Color3.fromRGB(170, 170, 190)
end

local function setButtonState(enabled, text, color)
	button.Text = text or "Cambiar a Server Priv"
	button.BackgroundColor3 = color or Color3.fromRGB(35, 115, 255)
	button.Active = enabled
end

local function openGui()
	if isOpen then return end
	isOpen = true
	mainFrame.Visible = true
	floatButton.Visible = false

	mainFrame.Size = UDim2.new(0, 20, 0, 20)
	mainFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
	mainFrame.BackgroundTransparency = 1
	stroke.Transparency = 1

	TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 340, 0, 210),
		Position = UDim2.new(0.5, -170, 0.5, -105),
		BackgroundTransparency = 0
	}):Play()

	TweenService:Create(stroke, TweenInfo.new(0.35), {Transparency = 0}):Play()
end

local function closeGui()
	if not isOpen then return end
	isOpen = false

	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0.5, -10, 0.5, -10),
		BackgroundTransparency = 1
	})
	TweenService:Create(stroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
	tween:Play()
	tween.Completed:Connect(function()
		mainFrame.Visible = false
		floatButton.Visible = true
	end)
end

--========================
-- ARRASTRAR VENTANA
--========================
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--========================
-- EVENTOS
--========================
button.MouseEnter:Connect(function()
	if not isOnCooldown and not isProcessing and isOpen then
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(55, 140, 255)
		}):Play()
	end
end)

button.MouseLeave:Connect(function()
	if not isOnCooldown and not isProcessing and isOpen then
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35, 115, 255)
		}):Play()
	end
end)

closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	}):Play()
end)

closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	}):Play()
end)

floatButton.MouseEnter:Connect(function()
	TweenService:Create(floatButton, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(55, 140, 255),
		Size = UDim2.new(0, 62, 0, 62)
	}):Play()
end)

floatButton.MouseLeave:Connect(function()
	TweenService:Create(floatButton, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(35, 115, 255),
		Size = UDim2.new(0, 56, 0, 56)
	}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	clickSound:Play()
	closeGui()
end)

floatButton.MouseButton1Click:Connect(function()
	clickSound:Play()
	openGui()
end)

-- Clic del botón principal → Confirmación
button.MouseButton1Click:Connect(function()
	if isOnCooldown or isProcessing or not isOpen then return end

	clickSound:Play()

	-- Confirmación simple
	setStatus("¿Seguro? Haz clic de nuevo para confirmar", Color3.fromRGB(255, 200, 60))
	setButtonState(true, "Confirmar Teletransporte", Color3.fromRGB(255, 140, 40))

	local connection
	connection = button.MouseButton1Click:Connect(function()
		connection:Disconnect()

		if isOnCooldown or isProcessing then return end

		isProcessing = true
		setButtonState(false, "Procesando...", Color3.fromRGB(65, 65, 85))
		setStatus("Creando servidor privado vacío...", Color3.fromRGB(255, 200, 60))
		TeleportEvent:FireServer()
	end)

	-- Cancelar confirmación después de 4 segundos
	task.delay(4, function()
		if connection then
			connection:Disconnect()
			if not isProcessing then
				setButtonState(true, "Cambiar a Server Priv", Color3.fromRGB(35, 115, 255))
				setStatus("Listo para cambiar de servidor", Color3.fromRGB(170, 170, 190))
			end
		end
	end)
end)

TeleportEvent.OnClientEvent:Connect(function(success, message)
	isProcessing = false

	if success then
		successSound:Play()
		setStatus(message or "¡Teletransportando!", Color3.fromRGB(70, 220, 120))
		setButtonState(false, "Teletransportando...", Color3.fromRGB(40, 160, 80))
	else
		setStatus(message or "Error. Intenta de nuevo.", Color3.fromRGB(255, 90, 90))
		setButtonState(true, "Cambiar a Server Priv", Color3.fromRGB(35, 115, 255))

		isOnCooldown = true
		task.delay(COOLDOWN, function()
			isOnCooldown = false
			if not isProcessing then
				setStatus("Listo para cambiar de servidor", Color3.fromRGB(170, 170, 190))
			end
		end)
	end
end)

-- Tecla P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		clickSound:Play()
		if isOpen then
			closeGui()
		else
			openGui()
		end
	end
end)

-- Abrir al entrar
task.delay(0.7, openGui)
