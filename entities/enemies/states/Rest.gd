extends "res://entities/enemies/states/State.gd"

onready var timer = $Timer
var done = false
var saved_buoyancy

func _ready():
	pass

func enter(brain):
	.enter(brain)
	timer.start()
	self.saved_buoyancy = brain.body.buoyancy
	brain.rest = false
	done = false
	

func exit(brain):
	timer.stop()
	brain.body.buoyancy = self.saved_buoyancy

func _on_Timer_timeout():
	self.done = true

func update(delta):
	if done:
		return 'pursue'
	brain.body.buoyancy = 1
	brain.control_vector = Vector2(0, 0)
	

func get_class():
	return 'rest'
