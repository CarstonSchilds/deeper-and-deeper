extends "res://entities/Entity.gd"

onready var brain = $Brain
var damage = 3

func _init():
	self.animal = true
	self.buoyancy = 0.9
	self.weight = 1

func _ready():
	self.sprite.animation = "idle"

func get_thrust_vector(delta):
	return self.brain.think(delta)
