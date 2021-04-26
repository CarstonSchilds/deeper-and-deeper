extends Node

onready var camera_rig = $CameraRig
var CAMERA_SPEED = 50

func _ready():
	Music.play_master()

func _on_Play_button_up():
#	animation_player.play('fade')
	get_tree().change_scene("res://World.tscn")

func _process(delta):
	camera_rig.position.y += (CAMERA_SPEED * delta)
