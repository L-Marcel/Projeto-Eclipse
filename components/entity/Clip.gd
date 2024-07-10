class_name Clip
extends Node

var max_ammonition : int = 10;
var _ammunition : int = 0 :
	set(value):
		_ammunition = value;
		changed.emit();
var _reloading : bool = false;
var _reloading_progress : float = 0.0;

signal changed;

func get_amount():
	return _ammunition;
func has_ammo():
	return _ammunition > 0;
func is_reloading():
	return _reloading;

func fire():
	_ammunition -= 1;
func reload():
	if Players.get_ammo() > 0:
		_reloading = true;

func _process(_delta):
	if _reloading:
		_reloading_progress += _delta;
		if _reloading_progress >= 1.0:
			_reloading_progress = 0.0;
			_reloading = false;
			_ammunition = Players.consume_ammo(max_ammonition);
