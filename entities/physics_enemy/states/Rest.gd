extends "res://entities/physics_enemy/states/State.gd"

onready var timer = $Timer
var done = false

func state_name():
	return 'rest'

func enter(brain):
	.enter(brain)
	brain.swim_controller.target = null
	timer.start()
	brain.body.mass *= 0.9
	done = false

func exit(brain):
	.exit(brain)
	timer.stop()
	brain.body.mass = brain.body.default_mass

func update(delta):
	if done:
		return 'attack'

func _on_Timer_timeout():
	self.done = true

