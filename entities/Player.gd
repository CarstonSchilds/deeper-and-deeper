extends "res://entities/Entity.gd"

signal hit_player

onready var spotlight = $Spotlight
onready var spotlight_area = $Spotlight/SpotlightArea
onready var sun = $Sun
onready var glow = $Glow
onready var depth_label = $UI/Depth
onready var stats_label = $UI/Stats
onready var propellor_pos = $PropAnchor
onready var water = $"../Water"
onready var engine_sound = $"PropAnchor/EngineSoundPlayer"
onready var camera = $"Camera"

var depth = 0
var depth_scale = 1500 # set this based on the max depth of the level
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
	handle_collisions(delta)
	self.stats_label.text = "Hull %0.0f\nBuoyancy %0.0f\nThrottle %s" % [self.health, control_buoyancy, throttle_state_names[current_throttle_state]]
	self.depth_label.text = "Current %0.0f\nMax %0.0f" % [depth, self.max_depth]
	

func map(x, input_start, input_end, output_start, output_end):
	return (x - input_start)/(input_end - input_start) * (output_end - output_start) + output_start

func bound(x, minimum, maximum):
	return min(max(x, minimum), maximum)

signal astern
signal stop
signal ahead_slow
signal ahead_fast
signal ahead_flank
signal zoom_in
signal zoom_out

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

signal buoyancy_up
signal buoyancy_down

signal sonar
signal light

func handle_input():
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
		emit_signal("buoyancy_up")

	if buoyancy_input < 0 && last_buoyancy_control >= 0 && current_buoyancy_state > 0:
		last_buoyancy_control = -1
		current_buoyancy_state -= 1
		control_buoyancy = buoyancy_values[current_buoyancy_state]
		emit_signal("buoyancy_down")
		
	
	if buoyancy_input == 0 && last_buoyancy_control != 0:
		last_buoyancy_control = 0
	
	self.buoyancy = ( control_buoyancy / 100.0 ) * ( SUB_BUOYANCY * 0.1 ) + ( SUB_BUOYANCY * 0.85 )
	
	# SONAR AND SPOTLIGHT CONTROLS
	if Input.is_action_just_released("sonar_toggle"):
		emit_signal("sonar")
		
	if Input.is_action_just_released("spotlight_toggle"):
		self.spotlight.enabled = !self.spotlight.enabled
		self.spotlight_area.monitorable = !self.spotlight_area.monitorable
		emit_signal("light")
		
	# CAMERA ZOOM CONTROLS
	if Input.is_action_just_released("zoom_in"):
		emit_signal("zoom_in")
		
	if Input.is_action_just_released("zoom_out"):
		emit_signal("zoom_out")

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

func damage(amount):
	self.health -= amount

func get_control_vector():
	return control_vector

var colliding = {}

func handle_collisions(delta):
	for body in colliding.keys():
		if colliding[body].duration == 0:
			if "initial_damage" in colliding[body]:
				self.damage(colliding[body].initial_damage)
				colliding[body].erase("initial_damage")
			else:
				self.damage(colliding[body].damage)
		colliding[body].duration += delta
		if colliding[body].duration > 1.5:
			colliding[body].duration = 0

func create_collision(body):
	var result = {}
	result.duration = 0
	if "brain" in body:
		body.brain.handle_damaged_player()
	if "damage" in body: # if the body specifies a damage value, then it's an enemy
		result.damage = body.damage
	else: # if the body doesn't specify a damage amount, it is terrain
		result.initial_damage = 5
		result.damage = 1
	return result

func _on_CollisionDetector_body_entered(body):
	if body.name != 'Player':
		colliding[body] = create_collision(body)

func _on_CollisionDetector_body_exited(body):
	if body.name != 'Player':
		colliding.erase(body)
