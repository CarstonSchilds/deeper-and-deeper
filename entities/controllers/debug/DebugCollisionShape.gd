extends Position2D

onready var parent = $".."
onready var debug_shape = $"DebugShape"

export(Color) var color : Color

func _ready():
	debug_shape.color = color

	for node in parent.get_children():
		if node is CollisionShape2D:
			debug_shape.shapes.append(node.shape)

		if node is CollisionPolygon2D:
			debug_shape.polygons.append(node.polygon)
