extends Node2D

onready var player = $"../../.."
onready var player_controller = player.get_node("PlayerController")
onready var player_position   = player.get_node("PhysicsSmoothing")
onready var body              = player.get_node("PhysicsEntity")
onready var world = $"/root/World"

onready var particle_template = $SonarParticle
onready var sonar_cooldown_timer = $SonarCooldown
onready var sonar_arc = $SonarArc
onready var sonar_ping_player = $"SonarPingPlayer"
onready var sonar_active_particle = $"SonarActiveParticle"
onready var sonar_aggro_area = $"SonarAggroArea"
onready var sonar_aggro_timer = $"SonarAggroArea/SonarAggroTimer"

var sonar_available = true
var sonar_range = 1000
var request_sonar = false

func _process(delta):
	sonar_active_particle.emitting = self.request_sonar and !player_controller.rolling

func _physics_process(delta):
	if sonar_available and request_sonar and !player_controller.rolling:
		do_sonar()

func get_normalized_ray_vector(rot, angle_delta):
	return Vector2.RIGHT.rotated(player_position.rotation + rot + angle_delta).normalized()
	
func do_sonar():
	var arc_material = sonar_arc.process_material
	if player_controller.inverted:
		arc_material.angle = -self.global_rotation_degrees + 180
	else:
		arc_material.angle = -self.global_rotation_degrees
	sonar_arc.emitting = true
	sonar_ping_player.play()
	var space_state = get_world_2d().direct_space_state
	for i in range(-64, 64):
		var angle_delta = PI/256 * i
		var rot = -PI/2
		if player_controller.inverted:
			rot = -rot
		var result = space_state.intersect_ray(self.global_position, self.global_position + get_normalized_ray_vector(rot, angle_delta) * sonar_range, [self])
		if 'position' in result:
			draw_sonar_hit(result)
	aggro_sonar_sensitive_enemies()
	sonar_used()

func sonar_used():
	sonar_available = false
	sonar_cooldown_timer.start()

func _on_SonarCooldown_timeout():
	sonar_available = true
	sonar_ping_player.stop()

func draw_sonar_hit(ray_cast_result):
	var hit_position = ray_cast_result.position
	
	var particle = particle_template.duplicate()
	world.get_sonar_layer().add_child(particle)
	particle.global_position = hit_position
	
	var distance = hit_position - self.global_position
	var particle_timer = particle.get_child(0)
	particle_timer.wait_time = distance.length() * 0.005
	particle_timer.start()

func _on_Player_sonar_toggle():
	self.request_sonar = !self.request_sonar

var heard_sonar = {}

func aggro_sonar_sensitive_enemies():
	sonar_aggro_timer.start()
	var nearby = sonar_aggro_area.get_overlapping_areas()
	for i in nearby:
		if i.name == 'LightDetection':
			var brain = i.get_parent()
			heard_sonar[brain] = brain

func _on_SonarAggroTimer_timeout():
	# Aggro all sonar sensitive enemies in sonar_threats
	for brain in heard_sonar:
		brain.heard_sonar(body)
	heard_sonar = {}
