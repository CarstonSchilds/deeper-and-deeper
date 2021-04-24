extends Node2D

onready var player = $Player
onready var background = $Water
onready var sonar_layer = $SonarLayer

func _ready():
	pass
	
func _process(delta):
	pass
	
func get_background():
	return background
	
func get_sonar_layer():
	return sonar_layer
