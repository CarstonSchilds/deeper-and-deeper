extends AudioStreamPlayer

onready var timer = $"Timer"

var avaiable = true

func _on_Timer_timeout():
	avaiable = true

func _on_HealthController_damage(amount):
	if amount <= 5 and avaiable:
		self.play(0.0)
	avaiable = false
	timer.start()
