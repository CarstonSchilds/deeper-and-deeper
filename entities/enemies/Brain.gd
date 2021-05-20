extends Node2D

export(float) var leash_range = 200.0
export(bool)  var light_sensitive = false
export(bool)  var sonar_sensitive = false
export(bool)  var no_patrol = false
export(float) var normal_patrol_time = 2.0

onready var parent : Node2D = $".."
onready var body : CollisionObject2D = $"../../PhysicsEntity"
onready var home = body.global_position
onready var swim_controller = $"../../SwimController"
onready var target_range = $"ThreatRange"
onready var threat_range_shape = $"ThreatRange/CollisionShape2D"

onready var state_map = {
	'natural_behaviour':  $"States/NaturalBehaviour",
	'attack':             $"States/Attack",
	'pursue':             $"States/Pursue",
	'flee':               $"States/Flee",
	'return_home':        $"States/ReturnHome",
	'rest':               $"States/Rest"
}

onready var current_state = state_map['natural_behaviour']
var state_stack = []

signal threatened(target)
signal rest
signal state_changed(current_state)

func _ready():
	current_state.call_deferred("enter", self)

func _process(delta):
	var new_state = current_state.update(delta)
	if new_state:
		self.change_state(new_state)

func change_state(state_name):
	assert(state_name in state_map.keys())
	current_state.exit(self)
	current_state = state_map[state_name]
	current_state.enter(self)
	emit_signal('state_changed', current_state)

func _on_ThreatRange_area_entered(area):
	if area.name == 'PlayerSoundArea':
		emit_signal("threatened", area.get_parent())

func _on_LightDetection_area_entered(area):
	if self.light_sensitive and area.name == 'SpotlightArea':
		emit_signal("threatened", area.get_parent())

func heard_sonar(source):
	if self.sonar_sensitive:
		emit_signal("threatened", source)

func damaged_target(source):
	emit_signal("rest")
