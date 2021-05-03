extends ParallaxBackground

onready var background = $Background
onready var midground = $Midground
onready var foreground = $Foreground
onready var darkness = $Darkness
onready var light = null
#
#func _ready():
#	pass
#
#func set_light(light):
#	self.light = light.duplicate()
#	self.add_child(self.light)
#
#func get_light():
#	return self.light
#
#func disable_darkness():
#	self.darkness.visible = false
