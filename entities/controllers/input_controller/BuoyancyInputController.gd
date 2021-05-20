extends Node

onready var player = $".."
onready var body              = player.get_node("PhysicsEntity")
onready var player_controller = player.get_node("PlayerController")
onready var health_controller = player.get_node("HealthController")
onready var drive_controller  = player.get_node("DriveController")
onready var player_sound_area = player.get_node("PhysicsSmoothing/PlayerSoundArea")

var last_buoyancy_control = 0
var current_buoyancy_state = 2
var control_buoyancy = 50.0

var buoyancy_values = [
	0,
	25,
	50,
	75,
	100
]

signal buoyancy_up
signal buoyancy_down

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "BuoyancyInputController"
	assert(player.get_node("BuoyancyInputController") == self)

func _input(_event):
	# BUOYANCY CONTROLS
	var buoyancy_input = Input.get_action_strength("buoyancy_up") - Input.get_action_strength("buoyancy_down")
	
	if buoyancy_input > 0 && last_buoyancy_control <= 0 && current_buoyancy_state < 4:
		last_buoyancy_control = 1
		current_buoyancy_state += 1
		control_buoyancy = buoyancy_values[current_buoyancy_state]
		emit_signal("buoyancy_up")

	if buoyancy_input < 0 && last_buoyancy_control >= 0 && current_buoyancy_state > 0:
		last_buoyancy_control = -1
		current_buoyancy_state -= 1
		control_buoyancy = buoyancy_values[current_buoyancy_state]
		emit_signal("buoyancy_down")
	
	if buoyancy_input == 0 && last_buoyancy_control != 0:
		last_buoyancy_control = 0

	if health_controller.hit_points <= 25:
		control_buoyancy = min(control_buoyancy, (health_controller.hit_points / 25.0) * 90.0)
		if control_buoyancy < 75 && current_buoyancy_state > 3:
			current_buoyancy_state = 3
		elif control_buoyancy < 50 && current_buoyancy_state > 2:
			current_buoyancy_state = 2
		elif control_buoyancy < 25 && current_buoyancy_state > 1:
			current_buoyancy_state = 1
	
	var mass_range = body.default_mass * 0.2
	var mass_weight = ( 50.0 - control_buoyancy ) / 50.0 
	var new_mass = body.default_mass + lerp(-mass_range, mass_range, mass_weight + 0.5)
	body.mass = new_mass
