extends Node

var rng = RandomNumberGenerator.new()

	
onready var flare = $".."
onready var animation_player : AnimationPlayer = $"AnimationPlayer"
onready var glow_light : Light2D = $"../Glow"

export var glow_amount = 0.0

var   flicker = 0.0
var   flicker_frames = 0
const flicker_on = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.current_animation = "glow"

func _process(delta):
	if flicker_frames % flicker_on == 0:
		flicker_frames = 0
		flicker = rng.randf_range(-0.05, 0.05)
	flicker_frames += 1
	glow_light.energy = glow_amount + flicker
	glow_light.texture_scale = 2.0 + ( glow_amount + flicker ) * 3.0

func _on_Timer_timeout():
	flare.queue_free()
