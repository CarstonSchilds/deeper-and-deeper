extends Node

signal debug_on
signal debug_off

var debug_view = false

func _input(event):
	# Enable / disable debug view
	if Input.is_action_just_released("debug_view"):
		debug_view = !debug_view
		if debug_view:
			emit_signal("debug_on")
		else:
			emit_signal("debug_off")
