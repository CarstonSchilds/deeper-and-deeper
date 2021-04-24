extends "res://entities/entity.gd"

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
	
func get_inputs():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")
	return input_vector
