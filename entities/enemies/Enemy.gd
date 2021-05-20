extends Node2D

export(bool) var sonar_sensitive = false
export(bool) var light_sensitive = false
export(bool) var no_patrol = false

export(int) var damage = 5
export(float) var attack_leash_range = 500.0

export(float) var rest_time = 1.5
export(float) var normal_patrol_time = 4.0
export(float) var random_patrol_time = 0.5
export(float) var pursue_time = 7.5
export(float) var flee_time   = 5.0

onready var brain  = $"PhysicsSmoothing/Brain"
onready var hitbox = $"PhysicsSmoothing/HitBox"

onready var rest_timer   = $"PhysicsSmoothing/Brain/States/Rest/Timer"
onready var patrol_timer = $"PhysicsSmoothing/Brain/States/NaturalBehaviour/Timer"
onready var natural_behaviour_state = $"PhysicsSmoothing/Brain/States/NaturalBehaviour"
onready var pursue_timer = $"PhysicsSmoothing/Brain/States/Pursue/Timer"
onready var flee_timer   = $"PhysicsSmoothing/Brain/States/Flee/Timer"

func _ready():
	brain.sonar_sensitive = sonar_sensitive
	brain.light_sensitive = light_sensitive
	brain.no_patrol = no_patrol
	hitbox.damage_amount = damage

	rest_timer.wait_time = rest_time
	patrol_timer.wait_time = normal_patrol_time
	natural_behaviour_state.random_patrol_time = random_patrol_time
	pursue_timer.wait_time = pursue_time
	flee_timer.wait_time = flee_time
