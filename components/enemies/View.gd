class_name View
extends Node2D

var danger : bool = false;
var target : Player = null;

func is_danger():
	return danger;
func get_enemy():
	return target;

func _process(_delta):
	var _target : Player = null;
	var _danger : bool = false;
	for raycast in get_children():
		if raycast is ViewRaycast && raycast.is_colliding():
			var collider = raycast.get_collider();
			if collider is Player && !collider.health.is_dead():
				_target = collider;
				_target.saw = true;
				_danger = !raycast.far;
				if _danger:
					break;
	danger = _danger;
	if _target != null:
		target = _target;
