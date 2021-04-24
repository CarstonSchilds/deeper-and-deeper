extends KinematicBody2D

var bouyancy = 89.5
var thrust = 0
var weight = 10
var acceleration = Vector2()
var velocity = Vector2()
var facing = Vector2(1, 0)
var max_speed = 100
var drag = 0.99
var gravity = 9
var thrust_to_weight = 2

onready var sprite = $SpritePosition/AnimatedSprite

func _ready():
	pass

func _process(delta):
	var input_vector = get_inputs()
	adjust_facing(input_vector.x, delta)
	self.thrust = input_vector.y
	calculate_forces()
	move()

func adjust_facing(direction, delta):
	self.facing = self.facing.rotated(direction * PI * delta)
	self.rotation = self.facing.angle()

func calculate_forces():
	var environment_vector = Vector2(0, (self.weight * self.gravity) - self.bouyancy)
	var thrust_vector = self.facing.normalized() * self.thrust * self.thrust_to_weight
	self.acceleration += (thrust_vector + environment_vector)
	
func get_inputs():
	return Vector2()

func move():
	self.velocity += self.acceleration
	self.velocity *= self.drag
	self.velocity = self.velocity.clamped(self.max_speed)
	self.move_and_slide(self.velocity)
	self.acceleration = Vector2()
	self.thrust = 0
