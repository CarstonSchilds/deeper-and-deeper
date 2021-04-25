extends "res://entities/enemies/states/State.gd"

var target = null
var leash_range = 500

func enter(brain):
	.enter(brain)
	self.target = null
	var nearby = brain.target_range.get_overlapping_bodies()
	for i in nearby:
		if i.name == 'Player':
			target = i
			break

func exit(brain):
	.exit(brain)
	self.target = null

func update(delta):
	var target_distance = brain.body.position.distance_to(target.position)
	var home_distance = brain.body.position.distance_to(brain.home)
	if home_distance > leash_range or target_distance > (brain.threat_range_shape.shape.radius * 1.5):
		return 'return_home'
	if target_distance < brain.attack_range_shape.shape.radius:
		return 'attack'
	brain.move_and_steer_towards(target.position)

func get_class():
	return 'pursue'
