extends "res://entities/Entity.gd"

onready var spotlight = $Spotlight
onready var spotlight_area = $Spotlight/SpotlightArea
onready var glow = $Glow

onready var depth_label = $UI/Depth
onready var throttle_label = $UI/Throttle
onready var buoyancy_label = $UI/Buoyancy
onready var hull_label = $UI/Hull

onready var propellor_pos = $PropAnchor

onready var engine_sound = $"PropAnchor/EngineSoundPlayer"

onready var camera = $"Camera"

var depth = 0
var depth_scale = 3000 # set this based on the max depth of the level
var max_depth = -INF

var control_buoyancy = 50.0
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
	self.current_facing = Vector2(0,-1)

func _process(delta):
	handle_input()
	handle_depth()
	
	self.hull_label.text = "Hull %0.0f" % [self.health]
	self.buoyancy_label.text = "Buoyancy %0.0f" % [control_buoyancy]
	self.throttle_label.text = "Throttle %s" % [throttle_state_names[current_throttle_state]]
	depth_label.text = "Depth %0.0f\nMax %0.0f" % [depth, self.max_depth]
	
	if self.health <= 25:
		self.hull_label.set("custom_colors/font_color", ColorN("red", 1))
		self.buoyancy_label.set("custom_colors/font_color", ColorN("red", 1))
	elif self.health <= 50:
		self.hull_label.set("custom_colors/font_color", ColorN("orange", 1))


func _physics_process(delta):
	handle_collisions(delta)

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
var current_buoyancy_state = 2

var buoyancy_values = [
	0,
	25,
	50,
	75,
	100
]

signal buoyancy_up
signal buoyancy_down

signal sonar_toggle
signal light_toggle

func handle_input():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")
	
	if self.health == 0:
		input_vector.x = 0
		input_vector.y = 0
		
	if input_vector.y > 0 && last_throttle_control <= 0 && current_throttle_state < 4:
		last_throttle_control = 1
		current_throttle_state += 1
		emit_signal(throttle_states[current_throttle_state])
		adjust_sound_area(current_throttle_state)
		control_throttle = throttle_values[current_throttle_state]
		if current_throttle_state != 1:
			sprite.animation = "move"
		else:
			sprite.animation = "idle"

	if input_vector.y < 0 && last_throttle_control >= 0 && current_throttle_state > 0:
		last_throttle_control = -1
		current_throttle_state -= 1
		emit_signal(throttle_states[current_throttle_state])
		adjust_sound_area(current_throttle_state)
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
	
	if self.health <= 25:
		control_buoyancy = min(control_buoyancy, (self.health / 25.0) * 90.0)
		if control_buoyancy < 75 && current_buoyancy_state > 3:
			current_buoyancy_state = 3
		elif control_buoyancy < 50 && current_buoyancy_state > 2:
			current_buoyancy_state = 2
		elif control_buoyancy < 25 && current_buoyancy_state > 1:
			current_buoyancy_state = 1
	
	self.buoyancy = ( control_buoyancy / 100.0 ) * ( SUB_BUOYANCY * 0.1 ) + ( SUB_BUOYANCY * 0.85 )
	
	# SONAR AND SPOTLIGHT CONTROLS
	if Input.is_action_just_released("sonar"):
		emit_signal("sonar_toggle")
		
	if Input.is_action_just_released("spotlight_toggle"):
		self.spotlight.enabled = !self.spotlight.enabled
		self.spotlight_area.monitorable = !self.spotlight_area.monitorable
		emit_signal("light_toggle")
		
	# CAMERA ZOOM CONTROLS
	if Input.is_action_just_released("zoom_in"):
		emit_signal("zoom_in")
		
	if Input.is_action_just_released("zoom_out"):
		emit_signal("zoom_out")

onready var player_sound_area = $"PlayerSoundArea"

func adjust_sound_area(current_throttle_state):
	var size = 0.25
	var amplitude = abs(current_throttle_state - 1)
	if amplitude == 1:
		size = 1
	elif amplitude == 2:
		size = 2
	elif amplitude == 3:
		size = 4
	player_sound_area.scale.x = size
	player_sound_area.scale.y = size
	
onready var water_breach_player = $"WaterBreachPlayer"
var breach_sound_played = false
	
func handle_depth():
	depth = self.global_position.y
	self.glow.energy = bound(map(depth, 0, depth_scale, 0.9, 0.8), 0.9, 0.8)
	self.glow.scale = Vector2(1, 1) * bound(map(depth, 0, depth_scale, 3, 1), 1, 3)
	
	if depth > self.max_depth:
		self.max_depth = depth
		
	if depth > 0 and ! breach_sound_played:
		water_breach_player.play()
		breach_sound_played = true

onready var alarm_player = $"AlarmPlayer"
var alarm_played = false

onready var fade_to_black_animation_player = $"Camera/FadeToBlackLayer/ColorRect/FadeToBlackAnimationPlayer"
var death_fade_to_black_started = false
	
func damage(amount):
	self.health -= amount
	if self.health <= 25 && !alarm_played:
		alarm_player.play()
		alarm_played = true
	if self.health < 0:
		self.health = 0
	
	if self.health == 0 && !death_fade_to_black_started:
		fade_to_black_animation_player.play("FadeOut")

func _on_FadeToBlackAnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://ui/TitleScreen.tscn")

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
				emit_signal("little_damage")
				emit_signal("show_damage")
		colliding[body].duration += delta
		if colliding[body].duration > 1.5:
			colliding[body].duration = 0

signal little_damage
signal big_damage
signal terrain_damage
signal show_damage

func create_collision(body):
	var result = {}
	result.duration = 0
	if "brain" in body:
		body.brain.handle_damaged_player()
	if "damage" in body: # if the body specifies a damage value, then it's an enemy
		result.damage = body.damage
		if result.damage > 5:
			emit_signal("big_damage")
			emit_signal("show_damage")
		else:
			emit_signal("little_damage")
			emit_signal("show_damage")
			
	else: # if the body doesn't specify a damage amount, it is terrain
		result.initial_damage = 5
		result.damage = 1
		emit_signal("terrain_damage")
		emit_signal("show_damage")
	return result

func _on_CollisionDetector_body_entered(body):
	if body.name != 'Player':
		colliding[body] = create_collision(body)

func _on_CollisionDetector_body_exited(body):
	if body.name != 'Player':
		colliding.erase(body)




