extends "res://entities/enemies/states/State.gd"

onready var timer = $"Timer"

func enter(brain):
	.enter(brain)
	if not brain.target:
		var nearby = brain.target_range.get_overlapping_areas()
		for i in nearby:
			if i.name == 'PlayerSoundArea':
				brain.target = i.get_parent()
				break
	timer.start()

func exit(brain):
	.exit(brain)

func update(delta):
	
	if followed_for_too_long:
		followed_for_too_long = false
		return 'attack'
	
	if brain.rest:
		return 'rest'

	brain.move_and_steer_towards(brain.target.position)


func get_class():
	return 'pursue'

var followed_for_too_long = false

func _on_Timer_timeout():
	followed_for_too_long = true
