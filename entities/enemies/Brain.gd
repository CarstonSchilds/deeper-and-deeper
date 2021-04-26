extends Node2D

var leash_range = 400
var light_sensitive = false
var sonar_sensitive = false
var no_patrol = false
var normal_patrol_time = 2.0
var control_vector = Vector2()
var home = Vector2()
var body = null
var current_state = null
var threatened = false
var rest = false
var target = null

onready var state_map = {
	'natural_behaviour': $States/NaturalBehaviour,
	'pursue': $States/Pursue,
	'return_home': $States/ReturnHome,
	'rest': $States/Rest
}
var state_stack = []

signal state_changed(current_state)

onready var target_range = $ThreatRange
onready var threat_range_shape = $ThreatRange/CollisionShape2D

func _ready():
	self.body = self.get_parent()
	self.home = Vector2(self.body.position)
	current_state = state_map['natural_behaviour']
	current_state.enter(self)

func notify():
	pass

func think(delta):
	var new_state = current_state.update(delta)
	if new_state:
		self.change_state(new_state)
	return self.control_vector

func change_state(state):
	current_state.exit(self)
	
	if state == 'previous':
		state_stack.pop_front()
	elif state in state_map.keys():
		state_stack.push_front(state_map[state])
	else:
		var new_state = state_map[state]
		state_stack[0] = new_state
	
	current_state = state_stack[0]
	if state != 'previous':
		current_state.enter(self)
	emit_signal('state_changed', current_state)

func handle_damaged_player():
	self.rest = true

func _on_ThreatRange_area_entered(area):
	if area.name == 'PlayerSoundArea':
		self.threatened = true

func _on_ThreatRange_area_exited(area):
	if area.name == 'PlayerSoundArea':
		self.threatened = false

func move_and_steer_towards(target):
	var vector_to_target = self.body.position.direction_to(target)
	var normalized_vector_to_target = vector_to_target.normalized()
	self.body.current_facing = normalized_vector_to_target
	self.control_vector = normalized_vector_to_target * 0.5

func _on_LightDetection_area_entered(area):
	if self.light_sensitive and area.name == 'SpotlightArea' and !self.threatened:
		self.threatened = true
		self.target = area.get_parent().get_parent()

func heard_sonar(target):
	if self.sonar_sensitive and !self.threatened:
		self.threatened = true
		self.target = target
