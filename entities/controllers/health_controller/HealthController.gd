extends Node

onready var parent = $".."

export(int) var hit_points = 100
export(bool) var dead = false

signal damage(amount)
signal heal(amount)
signal death

func _ready():
	# Be sure that this node is the only "HealthController"
	assert(parent.get_node("HealthController") == self)

func do_damage(amount : int):
	hit_points -= amount
	emit_signal("damage", amount)
	if hit_points <= 0:
		emit_signal("death")

func heal(amount : int):
	hit_points += amount
	emit_signal("heal", amount)
