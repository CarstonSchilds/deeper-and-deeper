extends Node

onready var parent : Node2D = $".."

var anchor

func _ready():
	anchor = parent.global_rotation

func _process(delta):
	parent.global_scale = Vector2(1.0,1.0)
	parent.global_rotation = anchor
