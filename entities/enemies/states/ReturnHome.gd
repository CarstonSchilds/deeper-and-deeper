extends "res://entities/enemies/states/State.gd"



func enter(brain):
	.enter(brain)

func exit(brain):
	.exit(brain)

func update(delta):
	var home_distance = brain.body.position.distance_to(brain.home)
	if home_distance < 4:
		return 'natural_behaviour'
	if brain.threatened:
		return 'pursue'
	brain.move_and_steer_towards(brain.home)

func get_class():
	return 'pursue'
