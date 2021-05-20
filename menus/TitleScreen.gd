extends Node

onready var camera_rig = $CameraRig
onready var background = $ParallaxBackground
onready var animation_player = $CameraRig/Sky/AnimationPlayer
onready var sky = $CameraRig/Sky
onready var bubbles = $UI/Bubbles/BubblesParticle
onready var bubbles_sound = $UI/Bubbles/BubblesSound
onready var main = $UI/MainMenu
onready var credits = $UI/Credits
onready var controls = $UI/Controls
onready var options = $UI/Options

onready var bloop_player = $"UI/Options/SfxVolumeSlider/BloopPlayer"
onready var bloop_player_timer = $"UI/Options/SfxVolumeSlider/BloopPlayer/Timer"

var CAMERA_SPEED = 10

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

func _on_Credits_button_up():
	main.visible = false
	credits.visible = true

func _on_Back_button_up():
	credits.visible = false
	main.visible = true

func _on_Controls_button_up():
	main.visible = false
	controls.visible = true

func _on_Back2_button_up():
	controls.visible = false
	main.visible = true

func _on_Options_button_up():
	options.visible = true
	main.visible = false

func _on_Back3_button_up():
	options.visible = false
	main.visible = true

func _on_MasterVolumeSlider_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, lerp_DB_Volume(value))

func _on_MusicVolumeSlider_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, lerp_DB_Volume(value))

func _on_SfxVolumeSlider_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, lerp_DB_Volume(value))
	play_Bloop()

func _on_SfxVolumeSlider_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		play_Bloop()

func play_Bloop():
	if bloop_player_timer.is_stopped():
		bloop_player_timer.start()
		bloop_player.play()

func lerp_DB_Volume(value):
	return (value * 18.0 / 100.0) - 9.0
