extends Node

var is_fullscreen = false

signal fullscreen(is_fullscreen)

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		toggle()

var old_size = OS.window_size
var old_pos  = OS.window_position

func toggle():
	is_fullscreen = !is_fullscreen
	if is_fullscreen:
		old_size = OS.window_size
		old_pos  = OS.window_position
	OS.window_borderless = is_fullscreen
	OS.window_maximized = is_fullscreen
	if !is_fullscreen:
		 OS.window_size = old_size
		 OS.window_position = old_pos

	self.emit_signal("fullscreen", is_fullscreen)
