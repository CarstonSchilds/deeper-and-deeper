extends Node2D

onready var world = self.get_tree().get_root().get_node("World")

#Load the resourse using preload
const flare_scn = preload("res://entities/flare/Flare.tscn")

export(float) var flare_impulse = 50.0
export(float) var flare_angular_velocity = 5.0

func _input(event):
	if event.is_action_pressed("flares"):
		_make_flare()

func _make_flare():
	var new_instance : RigidBody2D = flare_scn.instance()
	
	new_instance.position = self.global_position
	new_instance.apply_central_impulse(Vector2.DOWN.rotated(self.global_rotation) * flare_impulse)
	new_instance.angular_velocity = flare_angular_velocity
	
	#Attach it to the world
	world.add_child(new_instance)
