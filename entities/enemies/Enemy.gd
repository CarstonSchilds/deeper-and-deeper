extends "res://entities/Entity.gd"

onready var brain = $Brain
var damage = 3

func _init():
	self.buoyancy = 0
	self.weight = 0

func _ready():
	self.sprite.animation = "idle"

func get_thrust_vector(delta):
	return self.brain.think(delta)
