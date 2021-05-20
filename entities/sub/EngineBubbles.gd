extends Particles2D

func _on_ThrottleInputController_throttle_change(level):
	if abs(level) > 50:
		self.emitting = true
	else:
		self.emitting = false
