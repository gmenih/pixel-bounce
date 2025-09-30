-- Central configuration for all game tuning parameters

Config = {
	rngSeed = 0,

	physics = {
		fixedDt = 1 / 120, -- 120 Hz
		bouncerBaseSpeed = 180.0, -- px/s
		bouncerRadius = 10.0, -- px
		magnetRadius = 0.0, -- px (level 0)
		magnetStrength = 1200.0, -- px/s^2
		sparkRadius = 4.0, -- px
		maxSparks = 120,
		spawnPerSecond = 2, -- baseline
		wallPadding = 8, -- min spawn distance from wall
	},

	corner = {
		proximityPx = 14.0, -- distance threshold to vertex
		angleDeg = 18.0, -- within ± this of the corner bisector
		burstCount = 30, -- Sparks spawned on Burst
		boostMultiplier = 2.0, -- temporary multiplier
		boostDuration = 6.0, -- seconds
		effectWeights = {
			Clone = 0.5,
			Burst = 0.35,
			Boost = 0.15,
		},
	},

	upgrades = {
		speed = {
			base = 100,
			growth = 1.35,
			delta = 0.10, -- +10% speed per level
		},
		size = {
			base = 120,
			growth = 1.35,
			delta = 1.5, -- +1.5 px radius per level
		},
		magnet = {
			base = 150,
			growth = 1.4,
			delta = 22, -- +22 px per level
		},
		cornering = {
			base = 200,
			growth = 1.45,
			proximityDelta = 2.0,
			angleDelta = 2.0,
		},
	},

	screens = {
		shapes = { 4, 6, 8 },
		secondScreenUnlockCorners = 100,
	},

	arena = {
		centerX = 640,
		centerY = 360,
		radius = 480,
	},

	colors = {
		background = { 0.15, 0.15, 0.15 },
		arena = { 0.3, 0.3, 0.3 },
		bouncer = { 1, 1, 1 },
		spark = { 0.8, 0.8, 0.8 },
		hud = { 1, 1, 1 },
		button = { 0.4, 0.4, 0.4 },
		buttonHover = { 0.5, 0.5, 0.5 },
		buttonText = { 1, 1, 1 },
	},

	ui = {
		buttonTextOffsetY = 20,
		titleOffsetY = 60,
		menuPlayButtonOffsetY = 40,
		pauseResumeButtonOffsetY = -40,
		pauseQuitButtonOffsetY = 40,
		hudPadding = 10,
		hudLineHeight = 20,
		upgradesPanelBottomMargin = 30,
	},

	window = {
		width = 1280,
		height = 720,
		title = "Bounce Network - Prototype",
		resizable = false,
		vsync = true,
		msaa = 0,
	},
}

return Config

