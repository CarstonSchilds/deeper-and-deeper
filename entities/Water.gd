extends ParallaxBackground

onready var background = $Background
onready var midground = $Midground
onready var foreground = $Foreground
onready var light = null

func _ready():
	pass
	
func set_light(light):
	self.light = light.duplicate()
	self.add_child(self.light)

func get_light():
	return self.light

var is_mirrored = true

func set_parralax_mirroring(mirror : bool):
	if mirror && !is_mirrored:
		background.motion_mirroring = Vector2(4096,4096)
		midground.motion_mirroring = Vector2(4096,4096)
		foreground.motion_mirroring = Vector2(4096,4096)
		is_mirrored = true
	elif is_mirrored:
		background.motion_mirroring = Vector2(4096,0)
		midground.motion_mirroring = Vector2(4096,0)
		foreground.motion_mirroring = Vector2(4096,0)
		is_mirrored = false
