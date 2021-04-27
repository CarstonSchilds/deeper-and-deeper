extends Node2D

onready var player = $Player
onready var background = $Water
onready var sonar_layer = $SonarLayer
#onready var animation_player = $MainMenuTransition/AnimationPlayer
#onready var main_menu_transition = $MainMenuTransition

func _ready():
	pass
#	animation_player.play_backwards('fade')
#	yield(animation_player, 'animation_finished')
#	main_menu_transition.hide()
	
func _process(delta):
	pass

func get_background():
	return background
	
func get_sonar_layer():
	return sonar_layer
