extends "res://entities/enemies/states/State.gd"

var done = false
var rest = false
onready var timer = $"Timer"

func state_name():
	return 'flee'

func enter(brain):
	.enter(brain)
	brain.swim_controller.flee = true
	done = false
	timer.start()

func exit(brain):
	.exit(brain)
	brain.swim_controller.flee = false

func update(delta):
	if done:
		return 'rest'

func _on_Timer_timeout():
	done = true
