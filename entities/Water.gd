extends ParallaxBackground

onready var light = null

func _ready():
	pass
	
func set_light(light):
	self.light = light.duplicate()
	self.add_child(self.light)

func get_light():
	return self.light
