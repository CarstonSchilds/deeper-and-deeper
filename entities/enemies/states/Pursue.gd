extends "res://entities/enemies/states/State.gd"

var engage_from_distance = true

func enter(brain):
	.enter(brain)
	engage_from_distance = true
	if not brain.target:
		var nearby = brain.target_range.get_overlapping_areas()
		for i in nearby:
			if i.name == 'PlayerSoundArea':
				brain.target = i.get_parent()
				break

func exit(brain):
	.exit(brain)

func update(delta):
	var target_distance = brain.body.position.distance_to(brain.target.position)
	var home_distance = brain.body.position.distance_to(brain.home)
	
	# pursuit could start from outside this range
	if target_distance < (brain.threat_range_shape.shape.radius * 1.5):
		engage_from_distance = false
	
	if brain.rest:
		return 'rest'
	if home_distance > brain.leash_range or ( !engage_from_distance and target_distance > (brain.threat_range_shape.shape.radius * 1.5)):
		return 'return_home'
	brain.move_and_steer_towards(brain.target.position)

func get_class():
	return 'pursue'
