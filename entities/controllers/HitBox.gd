extends Area2D

onready var parent = $".."
onready var timer : Timer = $"Timer"

var damage_amount = 5

signal hit_target(target)

func _process(_delta):
	for area in self.get_overlapping_areas():
		if area.get_parent() == parent:
			continue

		var target = area.get_parent().get_parent()
		var health_controller = target.get_node("HealthController")

		if health_controller != null and timer.is_stopped():
			timer.start()
			health_controller.do_damage(damage_amount)
			print("hit!")
			emit_signal("hit_target", target)
