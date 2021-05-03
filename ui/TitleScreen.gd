extends Node

onready var camera_rig = $CameraRig
onready var background = $ParallaxBackground
onready var animation_player = $CameraRig/Sky/AnimationPlayer
onready var sky = $CameraRig/Sky
onready var bubbles = $CameraRig/BubblesParticle
onready var bubbles_sound = $CameraRig/BubblesSound
onready var main = $CameraRig/MainMenu
onready var credits = $CameraRig/Credits
onready var controls = $CameraRig/Controls
var CAMERA_SPEED = 50

func _ready():
	sky.hide()
	Music.play_master()

func _on_Play_button_up():
	sky.show()
	animation_player.play('fade')
	bubbles.emitting = true
	bubbles_sound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://World.tscn")

func _process(delta):
	camera_rig.position.y += (CAMERA_SPEED * delta)


func _on_Back2_button_up():
	controls.visible = false
	main.visible = true


func _on_Back_button_up():
	credits.visible = false
	main.visible = true


func _on_Controls_button_up():
	main.visible = false
	controls.visible = true


func _on_Credits_button_up():
	main.visible = false
	credits.visible = true

