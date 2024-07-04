@tool
class_name FirePoint
extends Marker2D

@export var sprite : AnimatedSprite2D;

var _get_position : Callable = func(): return Vector2.ZERO;

func _ready():
	sprite.frame_changed.connect(on_sprite_frame_changed);
	sprite.animation_changed.connect(update_position);
func on_sprite_frame_changed():
	position = _get_position.call();

func update_position():
	match sprite.animation:
		"idle":
			_get_position = get_idle_position;
		"run":
			_get_position = get_run_position;
		"jump":
			_get_position = get_jump_position;
		"fall":
			_get_position = get_jump_position;
		"crouch":
			_get_position = get_crouch_position;
		"death":
			_get_position = get_death_position;
	on_sprite_frame_changed();

func get_death_position():
	return Vector2.ZERO;
func get_idle_position():
	return Vector2(13, -2 if sprite.frame <= 2 else -1);
func get_run_position():
	var positions : Array[int] = [-3, -5, -2, -4, -5, -2];
	return Vector2(13, positions[sprite.frame]);
func get_jump_position():
	return Vector2(14, -2);
func get_crouch_position():
	var positions : Array[Vector2] = [
		Vector2(13, -2), 
		Vector2(13, -1), 
		Vector2(14, 2)
	];
	return positions[sprite.frame];
