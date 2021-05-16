extends Node

onready var layer = $".."
onready var parent = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	layer.offset = parent.global_position
