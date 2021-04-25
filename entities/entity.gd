extends KinematicBody2D

var bouyancy = 8.5
var thrust = 1
var weight = 10
var max_speed = 100
var gravity = 0.9
var drag = 0.99
var thrust_scalar = 2
var torque_scalar = 0.5

onready var current_bouyancy = bouyancy
onready var current_thrust = thrust
onready var current_weight = weight
onready var current_drag = drag
onready var current_thrust_scalar = thrust_scalar
onready var current_acceleration = Vector2()
onready var current_velocity = Vector2()
onready var current_facing = Vector2(1, 0)

onready var sprite = $SpritePosition/AnimatedSprite

func _ready():
	pass

func _process(delta):
	var input_vector = get_inputs()
	adjust_facing(input_vector.x, delta)
	self.current_thrust = input_vector.y
	calculate_forces()
	move()

func adjust_facing(direction, delta):
	self.current_facing = self.current_facing.rotated(direction * PI * delta * torque_scalar)
	self.rotation = self.current_facing.angle()

func calculate_forces():
	var depth = self.global_position.y
	# Disable bouyancy above water
	if depth < 0:
		current_bouyancy = max(bouyancy + depth, 0);
	else:
		current_bouyancy = bouyancy;
	
	var environment_vector = Vector2(0, (self.current_weight * self.gravity) - self.current_bouyancy)
	var thrust_vector = self.current_facing.normalized() * self.current_thrust * self.current_thrust_scalar
	self.current_acceleration += (thrust_vector + environment_vector)
	
func get_inputs():
	return Vector2()

func move():
	self.current_velocity += self.current_acceleration
	self.current_velocity *= self.current_drag
	self.current_velocity = self.current_velocity.clamped(self.max_speed)
	self.move_and_slide(self.current_velocity)
	self.current_acceleration = Vector2()
	self.current_thrust = 0
