extends "res://entities/enemies/states/State.gd"

onready var timer = $Timer
var flip = 1

var rng = RandomNumberGenerator.new()

var random_patrol_time = 0.0

func _ready():
	rng.randomize()
	random_patrol_time = rng.randf_range(-0.5, 0.5)

func enter(brain):
	.enter(brain)
	flip = 1
	timer.wait_time = brain.normal_patrol_time + random_patrol_time
	timer.start()
	if brain.body.current_facing:
		brain.body.current_facing.y = 0

func exit(brain):
	timer.stop()

func _on_Timer_timeout():
	flip *= -1
	brain.body.current_facing *= -1

func update(delta):
	if brain.threatened:
		return 'pursue'
	if brain.no_patrol:
		brain.stop_moving()
	else:
		brain.control_vector = Vector2(brain.body.current_facing.x, 0)

func get_class():
	return 'natural_behaviour'
