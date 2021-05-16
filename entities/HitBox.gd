extends Area2D

onready var parent = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_HitBox_area_entered(area):
	if area.get_parent() == parent:
		pass
	else:
		var health_controller = area.get_parent().get_node("HealthController")
		print("Hit detected")
