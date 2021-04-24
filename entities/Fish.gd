extends "res://entities/Entity.gd"

onready var timer = $Timer

func _ready():
	self.sprite.animation = "idle"
	self.bouyancy = 0
	self.weight = 0
	self.init(2)
	self.sprite.set_flip_h(true)

func init(patrol_time):
	self.timer.wait_time = patrol_time
	self.timer.start()

func get_inputs():
	return Vector2(0, 1)

func _on_Timer_timeout():
	self.facing *= -1
	self.sprite.set_flip_v(self.facing.x < 0)

