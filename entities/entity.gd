extends KinematicBody2D

var health = 100
var buoyancy = 9
var thrust = 0
var weight = 10
var max_speed = 100
var gravity = 0.9
var drag_coefficient = 0.0001
var drag_ratio = 3 # perpendicular drag = parallel drag * drag_ratio 
var thrust_scalar = 2
var torque_scalar = 0.5


onready var current_buoyancy = buoyancy
onready var current_thrust = thrust
onready var current_weight = weight
onready var current_drag_coefficient = drag_coefficient
onready var current_thrust_scalar = thrust_scalar
onready var current_acceleration = Vector2()
onready var current_velocity = Vector2()
onready var current_facing = Vector2(1, 0)

onready var sprite = $SpritePosition/AnimatedSprite

func _ready():
	pass

func _process(delta):
	var input_vector = get_control_vector()
	adjust_facing(input_vector.x, delta)
	self.current_thrust = input_vector.y
	calculate_forces()
	move()

func adjust_facing(direction, delta):
	self.current_facing = self.current_facing.rotated(direction * PI * delta * torque_scalar).normalized()
	self.rotation = self.current_facing.angle()

func calculate_forces():
	var depth = self.global_position.y
	# Disable buoyancy above water
	if depth < 0:
		current_buoyancy = max(buoyancy + depth, 0);
	else:
		current_buoyancy = buoyancy;
	
	var environment_vector = Vector2(0, (self.current_weight * self.gravity) - self.current_buoyancy)
	var thrust_vector = self.current_facing * self.current_thrust * self.current_thrust_scalar
	var parallel_velocity = self.current_facing * self.current_facing.dot(self.current_velocity)
	var perpendicular_velocity = self.current_velocity - parallel_velocity
	var parallel_drag = parallel_velocity.normalized() * parallel_velocity.length_squared() * current_drag_coefficient * -1
	var perpendicular_drag = perpendicular_velocity.normalized() * perpendicular_velocity.length_squared() * current_drag_coefficient * drag_ratio * -1
	
	self.current_acceleration += (thrust_vector + environment_vector + parallel_drag + perpendicular_drag)
	
func get_control_vector():
	return Vector2()

func move():
	self.current_velocity += self.current_acceleration
	self.current_velocity = self.current_velocity.clamped(self.max_speed)
	self.move_and_slide(self.current_velocity)
	self.current_acceleration = Vector2()
	self.current_thrust = 0

