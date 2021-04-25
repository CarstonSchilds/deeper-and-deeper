extends "res://entities/Entity.gd"

onready var sonar = $SonarParticle
onready var spotlight = $Spotlight
onready var sun = $Sun
onready var glow = $Glow
onready var depth_label = $UI/Depth
onready var stats_label = $UI/Stats
onready var sonar_cooldown_timer = $SonarCooldown
onready var propellor_pos = $PropAnchor
onready var water = $"../Water"
onready var engine_sound = $"PropAnchor/EngineSoundPlayer"

var depth = 0
var depth_scale = 1500 # set this based on the max depth of the level
var sonar_available = true
var sonar_range = 300
var sonar_delta = 0
var sonar_active = false
var background_light = null
var max_depth = -INF

var control_buoyancy = 100.0
var control_throttle = 0.0
var control_vector = Vector2.ZERO

const SUB_BUOYANCY = 10.0
const SUB_DRAG = 0.0001
const SUB_THRUST = 0.25

func _init():
	self.thrust_scalar = SUB_THRUST
	self.buoyancy = SUB_BUOYANCY
	self.drag_coefficient = SUB_DRAG

func _ready():
	pass

func _process(delta):
	handle_input()
	handle_depth()
	
	self.stats_label.text = "Hull %0.0f\nBuoyancy %0.0f\nThrottle %s" % [self.health, control_buoyancy, throttle_state_names[current_throttle_state]]
	self.depth_label.text = "Current %0.0f\nMax %0.0f" % [depth, self.max_depth]
	

func map(x, input_start, input_end, output_start, output_end):
	return (x - input_start)/(input_end - input_start) * (output_end - output_start) + output_start

func bound(x, minimum, maximum):
	return min(max(x, minimum), maximum)

func _physics_process(delta):
	if sonar_available and sonar_active:
		var particle = sonar.duplicate()
		self.get_node('SonarAnchor').add_child(particle)
		particle.scale = Vector2(0.5, 0.5)
		particle.emitting = true
		var space_state = get_world_2d().direct_space_state
		for i in range(-8, 8):
			var angle_delta = PI/32 * i
			var result = space_state.intersect_ray(self.position, self.position + self.current_facing.rotated(-PI/2 + angle_delta).normalized() * sonar_range, [self])
			if 'position' in result:
				draw_sonar_hit(result)
		sonar_active = false
		sonar_used()

func sonar_used():
	sonar_available = false
	sonar_cooldown_timer.start()

func _on_SonarCooldown_timeout():
	print('got callback')
	sonar_available = true

func draw_sonar_hit(ray_cast_result):
	var particle = sonar.duplicate()
	self.get_parent().get_sonar_layer().add_child(particle)
	particle.global_position = ray_cast_result.position
	particle.emitting = true


signal astern
signal stop
signal ahead_slow
signal ahead_fast
signal ahead_flank

var last_throttle_control = 0
var current_throttle_state = 1

var throttle_states = [
	"astern",
	"stop",
	"ahead_slow",
	"ahead_fast",
	"ahead_flank"
]

var throttle_state_names = [
	"Astern",
	"Stop",
	"Ahead Slow",
	"Ahead Fast",
	"Ahead Flank"
]

var throttle_values = [
	-33,
	0,
	33,
	66,
	100
]

var last_buoyancy_control = 0
var current_buoyancy_state = 4

var buoyancy_values = [
	0,
	25,
	50,
	75,
	100
]


func handle_input():
	
	# THROTTLE CONTROLS
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")
		
	if input_vector.y > 0 && last_throttle_control <= 0 && current_throttle_state < 4:
		last_throttle_control = 1
		current_throttle_state += 1
		emit_signal(throttle_states[current_throttle_state])
		control_throttle = throttle_values[current_throttle_state]
		if current_throttle_state != 1:
			sprite.animation = "move"
		else:
			sprite.animation = "idle"

	if input_vector.y < 0 && last_throttle_control >= 0 && current_throttle_state > 0:
		last_throttle_control = -1
		current_throttle_state -= 1
		emit_signal(throttle_states[current_throttle_state])
		control_throttle = throttle_values[current_throttle_state]
		if current_throttle_state != 1:
			sprite.animation = "move"
		else:
			sprite.animation = "idle"
		
	if input_vector.y == 0 && last_throttle_control != 0:
		last_throttle_control = 0
	
	control_vector.x = input_vector.x
	control_vector.y = control_throttle / 100.0
	
	# BUOYANCY CONTROLS
	var buoyancy_input = Input.get_action_strength("buoyancy_up") - Input.get_action_strength("buoyancy_down")
	
	if buoyancy_input > 0 && last_buoyancy_control <= 0 && current_buoyancy_state < 4:
		last_buoyancy_control = 1
		current_buoyancy_state += 1
		control_buoyancy = buoyancy_values[current_buoyancy_state]

	if buoyancy_input < 0 && last_buoyancy_control >= 0 && current_buoyancy_state > 0:
		last_buoyancy_control = -1
		current_buoyancy_state -= 1
		control_buoyancy = buoyancy_values[current_buoyancy_state]
	
	if buoyancy_input == 0 && last_buoyancy_control != 0:
		last_buoyancy_control = 0
	
	self.buoyancy = ( control_buoyancy / 100.0 ) * ( SUB_BUOYANCY * 0.1 ) + ( SUB_BUOYANCY * 0.85 )
	
	# SONAR AND SPOTLIGHT CONTROLS
	if Input.is_action_just_released("sonar_toggle"):
		self.sonar_active = true
	if Input.is_action_just_released("spotlight_toggle"):
		self.spotlight.enabled = !self.spotlight.enabled


func handle_depth():
	depth = self.global_position.y
	self.sun.energy = bound(map(depth, 0, depth_scale, 1, 0), 0, 1)
	self.glow.energy = bound(map(depth, 0, depth_scale, 0, 1), 0, 1)
	self.glow.scale = Vector2(1, 1) * bound(map(depth, 0, depth_scale, 5, 1), 1, 5)
	
	if depth > self.max_depth:
		self.max_depth = depth
		
	# Enable water BG mirroring so we don't reach the end of it
	if depth > 2048:
		water.set_parralax_mirroring(true)
	else:
		water.set_parralax_mirroring(false)


func get_control_vector():
	return control_vector
