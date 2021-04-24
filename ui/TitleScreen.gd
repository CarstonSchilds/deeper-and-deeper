extends Control

onready var animation_player = $AnimationPlayer

func _on_Play_button_up():
	animation_player.play('fade')
	get_tree().change_scene("res://World.tscn")
