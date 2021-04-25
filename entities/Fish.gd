extends "res://entities/Entity.gd"

onready var timer = $Timer

func _init():
	self.buoyancy = 0
	self.weight = 0

func _ready():
	self.sprite.animation = "idle"
	self.init(2)
	self.sprite.set_flip_h(true)

func init(patrol_time):
	self.timer.wait_time = patrol_time
	self.timer.start()

func get_control_vector():
	return Vector2(0, 1)

func _on_Timer_timeout():
	self.current_facing *= -1
	self.sprite.set_flip_v(self.current_facing.x < 0)

