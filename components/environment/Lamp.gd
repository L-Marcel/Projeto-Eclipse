@tool
class_name Lamp
extends Node2D

@export var height : float = 124 :
	set(value):
		height = value;
		update();
@export var view : View :
	set(value):
		view = value;
		update();
@export var light : PointLight2D:
	set(value):
		light = value;
		update();

func update():
	if height && view:
		for child in view.get_children():
			if child is ViewRaycast:
				child.target_position.x = height;
	if height && light:
		light.set_scale(Vector2(178.0/49.0, height/248.0));

func _ready():
	update();

func _process(_delta):
	if light && randi() % 100 <= 10:
		var max_range : float = 0.2;
		light.energy = 1.0 + randf_range(-max_range, max_range);
