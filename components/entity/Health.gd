@icon("res://assets/icons/Heart.svg")
class_name Health
extends Node

@export var _total : float = 100;
@export var _limit : float = 100;
@export var _base : float = 100;
@export var invencible : bool = false;

signal death;
signal changed(value : float, limit : float, base : float);
signal damaged;

func hurt(amount : float):
	if invencible:
		return;
	damaged.emit();
	var limit : float = get_limit();
	_total = clamp(_total - amount, 0, limit);
	changed.emit(_total, limit, _base);
	if _total == 0:
		death.emit();
func heal(amount : float):
	var limit : float = get_limit();
	_total = clamp(_total + amount, 0, limit);
	changed.emit(_total, limit, _base);

func set_total(value : float):
	_total = value;
	changed.emit(_total, get_limit(), _base);
func get_total():
	return min(_total, get_limit());
func get_limit():
	return max(_limit, 0);
func is_dead():
	return get_total() <= 0;
