extends KinematicBody2D


onready var sprite = $SpritePosition/Sprite
var bouyancy = 2000
var thrust = 0
var max_thrust = 5
var min_thrust = -2
var weight = 100
var acceleration = Vector2()
var velocity = Vector2()
var facing = Vector2(1,0)
var max_speed = 200
var drag = 0.1
var gravity = 10

func _ready():
	pass

func _process(delta):
	var input_vector = get_inputs()
	adjust_facing(input_vector.x, delta)
	adjust_thrust(input_vector.y, delta)
	calculate_forces()
	move()

func adjust_facing(direction, delta):
	facing = facing.rotated(direction * PI * delta)
	sprite.rotation = (facing * -1).angle()

func adjust_thrust(direction, delta):
	thrust += (direction * 3 * delta)
	thrust = max(thrust, min_thrust)
	thrust = min(thrust, max_thrust)

func calculate_forces():
	self.acceleration += Vector2(0, bouyancy - (weight * gravity))
	var thrust_vector = facing.normalized() * thrust
	self.acceleration += thrust_vector
	
func get_inputs():
	return Vector2()
	
func move():
	self.velocity += self.acceleration * drag
	self.velocity = self.velocity.clamped(self.max_speed)
	self.rotation = self.velocity.angle() + PI / 2
	self.move_and_slide(self.velocity)
	self.acceleration = Vector2()
