extends Particles2D


onready var gabage_collect_timer = $GabageCollectTimer

func _on_Timer_timeout():
	self.emitting = true
	gabage_collect_timer.start()

func _on_GabageCollectTimer_timeout():
	self.queue_free()
