extends "res://entities/physics_enemy/states/State.gd"

func state_name():
	return 'return_home'

func enter(brain):
	.enter(brain)
	brain.swim_controller.target = brain.home
	
func exit(brain):
	.exit(brain)
	brain.swim_controller.target = null

func update(delta):
	var home_distance = brain.body.position.distance_to(brain.home)
	if home_distance < 4:
		return 'natural_behaviour'

func get_class():
	return 'return_home'
