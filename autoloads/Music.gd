extends Node

var master_music = load("res://assets/music/Master.wav")
onready var music_player = $AudioStreamPlayer
func _ready():
	pass

func play_master():
	music_player.stream = master_music
	music_player.play()
