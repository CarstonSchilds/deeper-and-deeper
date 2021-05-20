extends "res://entities/enemies/states/State.gd"


var followed_for_too_long = false
var rest = false
onready var timer = $"Timer"

func state_name():
	return 'pursue'

func enter(brain):
	.enter(brain)
	followed_for_too_long = false
	rest = false
	brain.connect("rest", self, "_on_Brain_rest")
	timer.start()

func exit(brain):
	.exit(brain)
	brain.disconnect("rest", self, "_on_Brain_rest")

func update(delta):
	if followed_for_too_long:
		return 'attack'

	if rest:
		return 'rest'

func _on_Timer_timeout():
	followed_for_too_long = true

func _on_Brain_rest():
	rest = true
