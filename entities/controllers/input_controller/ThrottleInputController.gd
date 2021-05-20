extends Node

onready var player = $".."
onready var player_controller = player.get_node("PlayerController")
onready var health_controller = player.get_node("HealthController")
onready var drive_controller  = player.get_node("DriveController")
onready var player_sound_area = player.get_node("PhysicsSmoothing/PlayerSoundArea")

var throttle_level = 0.0
var last_throttle_control = 0
var current_throttle_state = 0

var throttle_values = [
	-66,
	-33,
	0,
	33,
	66,
	100
]

var throttle_state_names = [
	"Astern Fast",
	"Astern Slow",
	"Stop",
	"Ahead Slow",
	"Ahead Fast",
	"Ahead Flank"
]

signal throttle_change(level)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "ThrottleInputController"
	assert(player.get_node("ThrottleInputController") == self)

func _input(event):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right")   - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")
	
	if health_controller.hit_points == 0:
		input_vector.x = 0
		input_vector.y = 0

	if input_vector.y > 0 && last_throttle_control <= 0 && current_throttle_state < 3:
		last_throttle_control = 1
		current_throttle_state += 1
		adjust_sound_area(current_throttle_state)
		throttle_level = throttle_values[current_throttle_state + 2]
		emit_signal("throttle_change", throttle_level)

	if input_vector.y < 0 && last_throttle_control >= 0 && current_throttle_state > -2:
		last_throttle_control = -1
		current_throttle_state -= 1
		adjust_sound_area(current_throttle_state)
		throttle_level = throttle_values[current_throttle_state + 2]
		emit_signal("throttle_change", throttle_level)

	if input_vector.y == 0 && last_throttle_control != 0:
		last_throttle_control = 0

	drive_controller.control_vector.x = input_vector.x
	drive_controller.control_vector.y = throttle_level / 100.0

func adjust_sound_area(current_throttle_state):
	var size = 0.25
	var amplitude = abs(current_throttle_state)
	if amplitude == 1:
		size = 1
	elif amplitude == 2:
		size = 2
	elif amplitude == 3:
		size = 4
	player_sound_area.scale.x = size
	player_sound_area.scale.y = size

func get_named_throttle_state():
	return throttle_state_names[self.current_throttle_state + 2]
