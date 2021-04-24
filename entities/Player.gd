extends "res://entities/Entity.gd"

onready var sonar = $SonarParticle
onready var light = $Spotlight
onready var sun = $Sun
onready var glow = $Glow
var sonar_range = 300
var sonar_delta = 0
var sonar_active = false
var background_light = null

func _ready():
	pass

func _process(delta):
	sun.energy = map(self.global_position.y, 0, 3000, 1, 0)
	glow.energy = map(self.global_position.y, 0, 3000, 0, 1)

func map(x, input_start, input_end, output_start, output_end):
	return (x - input_start)/(input_end - input_start) * (output_end - output_start) + output_start

func _physics_process(delta):
	if sonar_active:
		var space_state = get_world_2d().direct_space_state
		for i in range(-8, 8):
			var angle_delta = PI/64 * i
			var result = space_state.intersect_ray(global_position, self.facing.rotated(-PI/2 + angle_delta).normalized() * sonar_range, [self])
			if 'position' in result:
				draw_sonar_hit(result)
		sonar_active = false
		print('sonar off!')
	
func draw_sonar_hit(ray_cast_result):
	var particle = sonar.duplicate()
	self.get_parent().get_sonar_layer().add_child(particle)
	particle.global_position = ray_cast_result.position
	particle.emitting = true
	
func get_inputs():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	input_vector.y = Input.get_action_strength("forward_thrust") - Input.get_action_strength("reverse_thrust")
	
	if input_vector.y != 0:
		sprite.animation = "move"
	else:
		sprite.animation = "idle"
		
	if Input.is_action_just_released("sonar_toggle"):
		print('sonar active!')
		self.sonar_active = true

	return input_vector
