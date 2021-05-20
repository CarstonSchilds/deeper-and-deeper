extends Particles2D

func _on_HealthController_damage(amount):
	self.emitting = true
