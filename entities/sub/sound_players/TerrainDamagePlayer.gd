extends AudioStreamPlayer

onready var timer = $"Timer"

var avaiable = true

func _on_Player_terrain_damage():
	if avaiable:
		self.play(0.0)
	avaiable = false
	timer.start()

func _on_Timer_timeout():
	avaiable = true
