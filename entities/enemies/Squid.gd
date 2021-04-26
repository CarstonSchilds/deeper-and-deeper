extends "res://entities/enemies/Enemy.gd"

func _init():
	damage = 15

var transforming = false

func _on_Brain_state_changed(current_state):
	var name = current_state.get_class()
	if name == "natural_behaviour" or name == "return_home" or name == "rest":
		sprite.animation = "idle"
		sprite.rotation = 0
	if name == "pursue":
		sprite.animation = "start_move"
		sprite.rotation = PI/2
		transforming = true

func _on_AnimatedSprite_animation_finished():
	if transforming:
		sprite.animation = "moving"
		transforming = false
