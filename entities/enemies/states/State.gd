extends Node

onready var brain = $"../.."
var active = false

func state_name():
	return '?'

func enter(brain):
	active = true

func exit(brain):
	active = false

func update(delta):
	pass
