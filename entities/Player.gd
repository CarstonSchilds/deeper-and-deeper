extends "res://entities/Entity.gd"

onready var sprite = $SpritePosition/AnimatedSprite
onready var sonar = $SonarParticle
var sonar_range = 300

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, self.facing.rotated(-PI/2).normalized() * sonar_range, [self])
	if 'position' in result:
		draw_sonar_hit(result)
	
func draw_sonar_hit(ray_cast_result):
	var particle = sonar.duplicate()
	particle.global_position = ray_cast_result.position	
	
func get_inputs():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")

	if input_vector.y != 0:
		sprite.animation = "move"
	else:
		sprite.animation = "idle"

	return input_vector
