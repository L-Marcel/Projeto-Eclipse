class_name View
extends Node2D

@export var on : bool = true;
@export var enemy_can_be_furtive : bool = false;
var danger : bool = false;
var target : Player = null :
	set(value):
		target = value;
		target_changed.emit();

signal target_changed;

var reseting_target : bool = false;

func is_danger():
	return danger;
func get_enemy():
	return target;

func _process(_delta):
	var _target : Player = null;
	var _danger : bool = false;
	if on:
		for raycast in get_children():
			if raycast is ViewRaycast && raycast.is_colliding():
				var collider = raycast.get_collider();
				if collider is Player && !collider.health.is_dead():
					if raycast.out_of_light_range && collider.was_seen > 0:
						_target = collider;
						_danger = !raycast.far;
					elif !raycast.out_of_light_range:
						_target = collider;
						_target.set_was_seen(1 if enemy_can_be_furtive else 2);
						_danger = !raycast.far;
					if _danger:
						break;
	danger = _danger;
	if _target != null:
		target = _target;
		reseting_target = false;
	elif !reseting_target:
		reseting_target = true;
		await get_tree().create_timer(1.0).timeout;
		target = null;