extends Node2D

var color : Color
var shapes = []
var polygons = []

func _draw():
	if !color:
		color = ColorN("RED")
	for shape in shapes:
		shape.draw(self.get_canvas_item(), color)
	for polygon in polygons:
		self.draw_colored_polygon(polygon, color)
