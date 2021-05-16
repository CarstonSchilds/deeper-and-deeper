extends Particles2D


onready var gabage_collect_timer = $GabageCollectTimer
onready var sonar_light = $"SonarLight"

func _on_Timer_timeout():
	self.emitting = true
	sonar_light.enabled = true
	gabage_collect_timer.start()

func _on_GabageCollectTimer_timeout():
	self.queue_free()
