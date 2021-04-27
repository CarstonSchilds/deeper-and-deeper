extends ParallaxBackground

onready var background = $Background
onready var midground = $Midground
onready var foreground = $Foreground
onready var darkness = $Darkness
onready var light = null

func _ready():
	pass
	
func set_light(light):
	self.light = light.duplicate()
	self.add_child(self.light)

func get_light():
	return self.light
	
func disable_darkness():
	self.darkness.visible = false

# Modifying mirroring while the engine is running doesn't appear to work

# var is_mirrored = true

# const MIRROR_SIZE = 4128

# func set_parralax_mirroring(mirror : bool):
#	if mirror && !is_mirrored:
#		background.motion_mirroring = Vector2(0,MIRROR_SIZE)
#		midground.motion_mirroring = Vector2(0,MIRROR_SIZE)
#		foreground.motion_mirroring = Vector2(0,MIRROR_SIZE)
#		is_mirrored = true
#	elif is_mirrored:
#		background.motion_mirroring = Vector2(0,0)
#		midground.motion_mirroring = Vector2(0,0)
#		foreground.motion_mirroring = Vector2(0,0)
#		is_mirrored = false
