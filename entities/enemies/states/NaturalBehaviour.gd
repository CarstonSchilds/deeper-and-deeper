extends "res://entities/enemies/states/State.gd"

onready var timer = $Timer
var flip = 1

func _ready():
	pass

func enter(brain):
	.enter(brain)
	timer.start()
	if brain.body.current_facing:
		brain.body.current_facing.y = 0

func exit(brain):
	timer.stop()

func _on_Timer_timeout():
	flip *= -1
	brain.body.current_facing *= -1
	brain.body.scale.x *= -1
#	brain.body.sprite.set_flip_v(self.current_facing.x < 0)

func update(delta):
	if brain.threatened:
		return 'pursue'
	brain.control_vector = Vector2(1, 0) * flip

func get_class():
	return 'natrual_behaviour'
