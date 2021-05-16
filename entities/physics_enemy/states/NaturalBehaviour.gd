extends "res://entities/physics_enemy/states/State.gd"

var rng = RandomNumberGenerator.new()
var random_patrol_time = 0.0

onready var timer = $Timer
var going_left = true
var patrol_direction = Vector2()

var threat = null

func _ready():
	rng.randomize()
	random_patrol_time = rng.randf_range(-0.5, 0.5)

func state_name():
	return 'natural_behaviour'

func enter(brain):
	.enter(brain)
	brain.connect("threatened", self, "_on_Brain_threatened")
	patrol_direction = brain.home + Vector2(-1000.0, 00.0) # Somewhere far to the left
	threat = null
	
	if brain.no_patrol:
		brain.swim_controller.target = null
	else:
		going_left = true
		timer.wait_time = brain.normal_patrol_time + random_patrol_time + 7.5
		timer.start()
		brain.swim_controller.target = patrol_direction
		brain.swim_controller.ram_target = false

func exit(brain):
	.exit(brain)
	brain.disconnect("threatened", self, "_on_Brain_threatened")
	timer.stop()

func update(delta):
	if threat:
		return 'pursue'

func _on_Timer_timeout():
	going_left = !going_left
	if going_left:
		brain.swim_controller.target = patrol_direction
	else:
		brain.swim_controller.target = brain.home

func _on_Brain_threatened(source):
	self.threat = source
	brain.swim_controller.target = source
	brain.swim_controller.ram_target = true
