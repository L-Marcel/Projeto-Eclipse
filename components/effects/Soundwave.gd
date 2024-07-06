@tool
class_name Soundwave
extends Node2D

@export var _play : bool = false :
	set(value):
		_play = value;
		if Engine.is_editor_hint():
			if _play:
				_animate();
			else:
				progress = 0;
@export_range(0, 2, 1) var danger : int = 0;
@export var max_size : float = 64.0;
@export var min_size : float = 8.0;
@export_range(0.0, 1.0, 0.001) var progress : float = 0.0 :
	set(value):
		progress = value;
		queue_redraw();
		if progress >= 1.0 && !Engine.is_editor_hint() && is_inside_tree():
			var tween : Tween = get_tree().create_tween();
			tween.tween_property(self, "modulate", Color.TRANSPARENT, duration);
			tween.tween_callback(queue_free);
			tween.play();
@export var duration : float = 0.25;
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_EXPO;
@export var collision : CollisionShape2D;

signal _start;

func set_danger(_danger : int):
	danger = _danger;
func play(_min_size : float = min_size, _max_size : float = max_size, _duration : float = duration, _transition : Tween.TransitionType = transition):
	min_size = _min_size;
	max_size = _max_size;
	duration = _duration;
	transition = _transition;
	_start.emit();

func _animate():
	var tween : Tween = get_tree().create_tween();
	tween.tween_property(self, "progress", 1.0, duration).set_trans(transition);
	tween.play();
func _ready():
	progress = 0.0;
	collision.shape = collision.shape.duplicate();
	queue_redraw();
	if !Engine.is_editor_hint():
		await _start;
	_animate();
	
func _draw():
	var radius : float = min_size + ((max_size - min_size) * progress);
	collision.shape.radius = radius + 0.5;
	var color : Color = Color.WHITE;
	if danger != 0:
		color = Color(1, 0.891, 0);
	draw_circle(Vector2.ZERO, radius, color, false, 1.0);
func _on_area_body_entered(body):
	if body is Enemy:
		body.alert(danger, global_position);
