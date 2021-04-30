extends "res://entities/enemies/states/State.gd"

func enter(brain):
	.enter(brain)
	if not brain.target:
		var nearby = brain.target_range.get_overlapping_areas()
		for i in nearby:
			if i.name == 'PlayerSoundArea':
				brain.target = i.get_parent()
				break

func exit(brain):
	.exit(brain)

func update(delta):
	if brain.rest:
		return 'rest'
		
	var target_distance = brain.body.position.distance_to(brain.target.position)
	var home_distance = brain.body.position.distance_to(brain.home)
	
	if home_distance > brain.leash_range or target_distance > (brain.threat_range_shape.shape.radius * 1.5):
		return 'return_home'

	brain.move_and_steer_towards(brain.target.position)


func get_class():
	return 'attack'
