--!strict
--Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

--Packages
local Package = script
local Packages = Package.Parent
assert(Packages)
local Maid = require(Packages:WaitForChild("Maid"))
local Signal = require(Packages:WaitForChild("Signal"))
local ColdFusion = require(Packages:WaitForChild("ColdFusion"))
local FormatUtil = require(Packages:WaitForChild("FormatUtil"))
local TableUtil = require(Packages:WaitForChild("TableUtil"))

--Constants
local STEPS = {
	JUST_BLACK = 1,
	JUST_CELESTIAL_OBJECTS = 2,
	LINES_OVER_STARS = 3,
	GLOW_FILLED_LINES = 4,
	COLOR_FILLED_GLOW = 5,
	FINAL_LOGO = 6,
}
local SPEED = 0.625
local STUDIO_IDS = {
	LogoSequence_BackgroundStars = 12018190942,
	LogoSequence_Body = 12018191073,
	LogoSequence_BodyGlow = 12018191208,
	LogoSequence_FrontWheel = 12023235991,
	LogoSequence_Lines = 12018191693,
	LogoSequence_Moon = 12023236500,
	LogoSequence_Stars = 12018192094,
}
local RBX_ASSET_PREFIX = "rbxassetid://"
local STUDIO_IMAGES = {
	LogoSequence_BackgroundStars = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_BackgroundStars,
	LogoSequence_Body = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_Body,
	LogoSequence_BodyGlow = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_BodyGlow,
	LogoSequence_FrontWheel = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_FrontWheel,
	LogoSequence_Lines = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_Lines,
	LogoSequence_Moon = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_Moon,
	LogoSequence_Stars = RBX_ASSET_PREFIX .. STUDIO_IDS.LogoSequence_Stars,
}

--Types
type Maid = Maid.Maid
type Signal = Signal.Signal
type State<T> = ColdFusion.State<T>
type ValueState<T> = ColdFusion.ValueState<T>

export type StudioSequence = {
	__index: StudioSequence,
	Maid: Maid,
	_IsAlive: boolean,
	new: () -> StudioSequence,
	init: (Maid) -> nil,
	Step: ValueState<number>,
	Size: ValueState<UDim2>,
	Rotation: ValueState<number>,
	AnchorPoint: ValueState<Vector2>,
	Run: (self: StudioSequence) -> nil,
	Destroy: (self: StudioSequence) -> nil,
}

-- Class
local StudioSequence: StudioSequence = {} :: any
StudioSequence.__index = StudioSequence

function StudioSequence:Destroy()
	self.Maid:Destroy()
	local t: any = self
	for k, v in pairs(t) do
		t[k] = nil
	end
	setmetatable(t, nil)
	return nil
end

function StudioSequence:Run()
	self.Step:Set(0)
	ContentProvider:PreloadAsync(TableUtil.values(STUDIO_IMAGES), function()
		task.wait(SPEED * 3)
		if self._IsAlive then
			self.Step:Set(2)
		end
		task.wait(SPEED * 3)
		self.Size:Set(UDim2.fromScale(1, 0.5))
		self.AnchorPoint:Set(Vector2.new(0.5, 0.6))
		self.Rotation:Set(0)
		task.wait(SPEED * 2)
		if self._IsAlive then
			self.Step:Set(3)
		end
		task.wait(SPEED * 4)
		if self._IsAlive then
			self.Step:Set(4)
		end

		task.wait(SPEED * 1)
		if self._IsAlive then
			self.Step:Set(5)
		end
		task.wait(SPEED * 0.75)
		if self._IsAlive then
			self.Step:Set(6)
		end

		task.wait(SPEED * 6)
		if self._IsAlive then
			self.Step:Set(-1)
		end
		task.wait(SPEED * 1)
	end)
	return nil
end

function StudioSequence.new()
	local _maid = Maid.new()

	local _fuse = ColdFusion.fuse(_maid)
	local _new = _fuse.new
	local _mount = _fuse.bind
	local _import = _fuse.import

	local _Value = _fuse.Value
	local _Computed = _fuse.Computed

	local AnchorPoint = _Value(Vector2.new(0.625, 0.6))
	local Rotation = _Value(-12)
	local Size = _Value(UDim2.fromScale(2 / 1.5, 1.3 / 1.5))

	local function makeImage(image: string, zIndex: number, transparency: number | State<number>, color: (Color3 | State<Color3>)?): ImageLabel
		local key = ""
		for k, v in pairs(STUDIO_IMAGES) do
			if v == image then
				key = k
			end
		end
		return _new("ImageLabel")({
			Name = key,
			Size = Size:Tween(SPEED * 12),
			Rotation = Rotation:Tween(SPEED * 6),
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Image = image,
			ImageColor3 = color,
			ImageTransparency = transparency,
			ZIndex = zIndex,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = AnchorPoint:Tween(SPEED * 6),
		}) :: ImageLabel
	end

	local Step = _Value(-1)

	local IsSpace = _Computed(function(step: number)
		if STEPS.JUST_CELESTIAL_OBJECTS <= step and STEPS.GLOW_FILLED_LINES > step then
			return 0
		else
			return 1
		end
	end, Step):Tween(SPEED * 3)

	local ScreenGui = _new("ScreenGui")({
		Name = "NightcycleSequence",
		DisplayOrder = 10000,
		IgnoreGuiInset = true,
		Parent = if RunService:IsRunning() then Players.LocalPlayer:WaitForChild("PlayerGui") else game:GetService("CoreGui"),
		Children = {
			_new("Frame")({
				Name = "Background",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(0, 0, 0),
				ZIndex = 0,
			}),
			makeImage(STUDIO_IMAGES.LogoSequence_BackgroundStars, 1, IsSpace),
			makeImage(STUDIO_IMAGES.LogoSequence_Stars, 2, IsSpace),
			makeImage(
				STUDIO_IMAGES.LogoSequence_Moon,
				4.5,
				_Computed(function(step: number)
					if STEPS.JUST_BLACK <= step and STEPS.GLOW_FILLED_LINES >= step then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 2)
			),
			_new("ImageLabel")({
				Name = "LogoSequence_Lines",
				Size = Size:Tween(SPEED * 12),
				Rotation = Rotation:Tween(SPEED * 6),
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Image = STUDIO_IMAGES.LogoSequence_Lines,
				ImageTransparency = _Computed(function(step: number)
					if STEPS.LINES_OVER_STARS == step then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 0.5),
				ZIndex = 4,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = AnchorPoint:Tween(SPEED * 6),
				Children = {
					_new("UIGradient")({
						Transparency = _Computed(
							function(transparency: number)
								local minStep = 0.0001
								local val = math.clamp(1 - transparency + minStep, minStep * 2, 1 - minStep)
								return NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(math.max((val ^ 2) - minStep, minStep), 0),
									NumberSequenceKeypoint.new(val, 1),
									NumberSequenceKeypoint.new(1, 1),
								})
							end,
							_Computed(function(step: number)
								if STEPS.LINES_OVER_STARS == step then
									return 0
								else
									return 1
								end
							end, Step):Tween(SPEED * 6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						),
					}),
				} :: { [number]: any },
			}) :: ImageLabel,
			makeImage(
				STUDIO_IMAGES.LogoSequence_BodyGlow,
				5,
				_Computed(function(step: number): number
					if STEPS.GLOW_FILLED_LINES == step then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 1)
			),
			makeImage(
				STUDIO_IMAGES.LogoSequence_Body,
				6,
				_Computed(function(step: number)
					if STEPS.COLOR_FILLED_GLOW <= step then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 0.75)
			),
			makeImage(
				STUDIO_IMAGES.LogoSequence_FrontWheel,
				6,
				_Computed(function(step: number)
					if STEPS.GLOW_FILLED_LINES <= step then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 0.75)
			),
			_new("TextLabel")({
				Text = FormatUtil.bold(FormatUtil.italic("NIGHTCYCLE")),
				Font = Enum.Font.Michroma,
				RichText = true,
				TextColor3 = Color3.fromHex("#5650fb"),
				-- TextStrokeColor3 = Color3.fromHex("#7b77ff"),
				-- TextStrokeTransparency = _Computed(function(step: number)
				-- 	if STEPS.FINAL_LOGO <= step and step >= STEPS.COLOR_FILLED_GLOW then
				-- 		return 0.5
				-- 	else
				-- 		return 1
				-- 	end
				-- end, Step):Tween(SPEED*3),
				TextStrokeTransparency = 1,
				TextScaled = true,
				BackgroundTransparency = 1,
				TextTransparency = _Computed(function(step: number)
					if STEPS.FINAL_LOGO <= step and step >= STEPS.COLOR_FILLED_GLOW then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 3),
				Size = UDim2.fromScale(0, 0.15),
				AnchorPoint = Vector2.new(0.5, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				AutomaticSize = Enum.AutomaticSize.X,
				Position = UDim2.fromScale(0.5, 0.85),
			}),
			_new("Frame")({
				Name = "Background",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = _Computed(function(step: number)
					if step == -1 then
						return 0
					else
						return 1
					end
				end, Step):Tween(SPEED * 0.75),
				ZIndex = 1000,
			}),
		} :: { [number]: any },
	})

	local self: StudioSequence = setmetatable({
		_IsAlive = true,
		Maid = _maid,
		Step = Step,
		Rotation = Rotation,
		Size = Size,
		AnchorPoint = AnchorPoint,
		Instance = ScreenGui,
	} :: any, StudioSequence)

	return self
end

function StudioSequence.init(maid: Maid)
	if not RunService:IsStudio() then
		local studioMaid = Maid.new()
		maid:GiveTask(studioMaid)

		local sequence = StudioSequence.new()
		studioMaid:GiveTask(sequence)

		sequence:Run()
		task.delay(1, function()
			studioMaid:Destroy()
		end)
	end
	return nil
end

return StudioSequence
