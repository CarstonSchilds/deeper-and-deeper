extends Node

onready var player : Node2D =  $".."
onready var body =             $"../PhysicsEntity"
onready var drive_controller = $"../DriveController"
onready var player_position  = $"../PhysicsSmoothing"
onready var sprite =           $"../PhysicsSmoothing/AnimatedSprite"

var spotlight_on = true
onready var spotlight =        $"../PhysicsSmoothing/FrontAnchor/Spotlight"
onready var spotlight_area =   $"../PhysicsSmoothing/FrontAnchor/Spotlight/SpotlightArea"

onready var glow =             $"../PhysicsSmoothing/Glow"
onready var propellor_pos =    $"../PhysicsSmoothing/PropAnchor"
onready var engine_sound =     $"../PhysicsSmoothing/PropAnchor/EngineSoundPlayer"
onready var camera =           $"../PhysicsSmoothing/Camera"

var depth_scale = 4000 # set this based on the max depth of the level
var max_depth = -INF

onready var water_breach_player = $"../PhysicsSmoothing/WaterBreachPlayer"
var breach_sound_played = false

onready var alarm_player =        $"../PhysicsSmoothing/AlarmPlayer"
var alarm_played = false

onready var fade_to_black_animation_player = $"../PhysicsSmoothing/Camera/FadeToBlackLayer/ColorRect/FadeToBlackAnimationPlayer"
var death_fade_to_black_started = false

var inverted = false
var rolling = false

signal rolling
signal not_rolling
signal sonar_toggle
signal light_toggle

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "PlayerController"
	assert(player.get_node("PlayerController") == self)

func _process(delta):
	handle_input()
	handle_depth()
	
func handle_input():
	# ROLL Controls
	if Input.is_action_just_released("barrel_roll"):
		do_roll()
	
	# SONAR AND SPOTLIGHT CONTROLS
	if Input.is_action_just_released("sonar"):
		emit_signal("sonar_toggle")
		
	if Input.is_action_just_released("spotlight_toggle"):
		spotlight_on = !spotlight_on
		emit_signal("light_toggle")
		update_spotlight()
	
func handle_depth():
	var depth_weight = 1 - (( depth_scale - body.depth) / depth_scale )
	depth_weight = max(depth_weight, 0.0)
	depth_weight = min(depth_weight, 1.0)
	glow.energy  = lerp(0.9, 0.8, depth_weight)
	glow.scale   = lerp(Vector2(1, 1), Vector2(0.3, 0.3), depth_weight)
	
	if body.depth > self.max_depth:
		self.max_depth = body.depth
		
	if body.depth > 0 and ! breach_sound_played:
		water_breach_player.play()
		breach_sound_played = true

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

func invert(inverted):
	self.inverted = inverted
	if inverted:
		player_position.scale.y = -1
	else:
		player_position.scale.y = 1

func done_rolling():
	# Called when rolling animation is done
	rolling = false	
	emit_signal("rolling")
	update_spotlight()

func do_roll():
	rolling = true
	emit_signal("not_rolling")
	update_spotlight()
	if inverted:
		print("rolling back!")
		sprite.start_roll_back()
	else:
		print("rolling over!")
		sprite.start_roll_over()

func update_spotlight():
	var is_on = !rolling and spotlight_on
	self.spotlight.enabled = is_on
	self.spotlight_area.monitorable = is_on

