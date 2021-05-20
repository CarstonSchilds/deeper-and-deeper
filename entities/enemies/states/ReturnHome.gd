extends "res://entities/enemies/states/State.gd"

func state_name():
	return 'return_home'

func enter(brain):
	.enter(brain)
	brain.swim_controller.target = brain.home
	brain.swim_controller.ram_target = false
	
func exit(brain):
	.exit(brain)
	brain.swim_controller.target = null

func update(delta):
	var home_distance = brain.body.global_position.distance_to(brain.home)
	if home_distance < 25:
		return 'natural_behaviour'

func get_class():
	return 'return_home'
