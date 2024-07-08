@tool
class_name Lamp
extends Node2D

@export var on : bool = true :
	set(value):
		on = value;
		if view && light:
			view.on = on;
			light.enabled = on;
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
		
@export_group("Timer")
@export var timed : bool = false;
@export var delay : float = 0.0;
@export var on_duration : float = 1.0;
@export var off_duration : float = 1.0;

func update():
	if height && view:
		for child in view.get_children():
			if child is ViewRaycast:
				child.target_position.x = height;
	if height && light:
		light.set_scale(Vector2(178.0/49.0, height/248.0));
func start():
	if !timed && Engine.is_editor_hint():
		await get_tree().create_timer(1.0).timeout;
		start();
	elif on && timed:
		on = false;
		await get_tree().create_timer(off_duration).timeout;
		start();
	elif timed:
		on = true;
		await get_tree().create_timer(on_duration).timeout;
		start();

func _ready():
	view.on = on;
	light.enabled = on;
	update();
	await get_tree().create_timer(delay).timeout;
	start();
func _process(_delta):
	if light && randi() % 100 <= 10:
		var max_range : float = 0.2;
		light.energy = 1.0 + randf_range(-max_range, max_range);
