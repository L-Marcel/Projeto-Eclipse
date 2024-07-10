@icon("res://assets/icons/ProgressBar.svg")
@tool
class_name Bar
extends MarginContainer

@export var disabled : bool = false;
@export var content_scale : float = 1.0;
@export var width : float = 10;
@export var height : float = 3;
@export var border_color : Color = Color(0.18, 0.133, 0.184) :
	set(value):
		border_color = value;
		_update_colors();
@export var back_color : Color = Color(0.608, 0.671, 0.698) :
	set(value):
		back_color = value;
		_update_colors();
@export var fake_color : Color = Color(0.78, 0.863, 0.816) :
	set(value):
		fake_color = value;
		_update_colors();
@export var value_color : Color = Color.WHITE :
	set(value):
		value_color = value;
		_update_colors();

@onready var back_rect : ColorRect = %Back;
@onready var border_rect : NinePatchRect = %Border;
@onready var fake_rect : ColorRect = %Fake;
@onready var value_rect : ColorRect = %Value;

@export_range(0, 500, 1) var base_value : float = 100;
@export_range(0, 500, 1) var current_value_limit : float = 100;
@export_range(0, 500, 1) var current_value : float = 100 :
	set(value):
		if value >= current_value && value >= fake_value:
			fake_value = clamp(value, 0, current_value_limit);
		else:
			start_fake_delay();
		current_value = clamp(value, 0, current_value_limit);
@export_range(0, 60, 1) var fake_change_speed : float = 10;
var fake_value : float = 0;
var can_update_fake_value : bool = false;

func update(value : float, limit : float, base : float):
	current_value_limit = limit;
	current_value = value;
	base_value = base;

func _update_colors():
	if is_node_ready():
		border_rect.modulate = border_color;
		back_rect.color = back_color;
		fake_rect.color = fake_color;
		value_rect.color = value_color;
func _ready():
	_update_colors();

func start_fake_delay():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout;
	can_update_fake_value = true;

func _process(delta):
	if can_update_fake_value:
		fake_value = clamp(fake_value, 0, current_value_limit);
		fake_value = lerp(fake_value, current_value, fake_change_speed * delta);
		if fake_value == current_value:
			can_update_fake_value = false;
			start_fake_delay();

	if current_value_limit <= 0 || disabled:
		hide();
	else:
		show();

	custom_minimum_size.y = height * content_scale;
	custom_minimum_size.x = (2 + ((width - 2) * (current_value_limit/base_value))) * content_scale;
	value_rect.custom_minimum_size.x = (width - 2) * (current_value/base_value);
	fake_rect.custom_minimum_size.x = (width - 2) * (fake_value/base_value);
