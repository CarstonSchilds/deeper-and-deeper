extends "res://entities/enemies/states/State.gd"

var rest = false

func state_name():
	return 'attack'

func enter(brain):
	.enter(brain)
	if not brain.swim_controller.target:
		var nearby = brain.target_range.get_overlapping_areas()
		for i in nearby:
			if i.name == 'PlayerSoundArea':
				brain.swim_controller.target = i.get_parent()
				break
	brain.connect("rest", self, "_on_Brain_rest")

func exit(brain):
	.exit(brain)
	brain.disconnect("rest", self, "_on_Brain_rest")

func update(delta):
	if not brain.swim_controller.target:
		return 'return_home'
	
	if rest:
		return 'rest'
		
	var target_distance = brain.body.position.distance_to(brain.swim_controller.target)
	var home_distance = brain.body.position.distance_to(brain.home)
	
	if home_distance > brain.leash_range or target_distance > (brain.threat_range_shape.shape.radius * 1.5):
		return 'return_home'

func _on_Brain_rest():
	rest = true
