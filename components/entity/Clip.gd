class_name Clip
extends Node

@export_range(1, 20) var max_ammonition : int = 10;
var _ammunition : int = 0 :
	set(value):
		_ammunition = value;
		changed.emit();
var _reloading : bool = false;
var _reloading_progress : float = 0.0 :
	set(value):
		_reloading_progress = value;
		reload_changed.emit();

signal changed;
signal reload_changed;
signal reload_finished;
signal reload_tick;
var old_tick : int = 0;

func reset():
	_ammunition = 0;
	_reloading = false;
	_reloading_progress = 0.0;

func get_amount():
	return _ammunition;
func has_ammo():
	return _ammunition > 0;
func is_reloading():
	return _reloading;
func get_reload_needed_progress():
	return float(max_ammonition - _ammunition) / max_ammonition;
func get_progress():
	return _reloading_progress/get_reload_needed_progress();
func get_loaded_ammo():
	return ceil((max_ammonition - _ammunition) * get_progress());


func stop_reloading():
	_reloading = false;
	_reloading_progress = 0.0;
func fire():
	if _ammunition > 0:
		_ammunition -= 1;
	stop_reloading();
func reload():
	if Players.get_ammo() > 0 && get_reload_needed_progress() > 0:
		_reloading = true;

func _ready():
	reload_changed.connect(_on_tick);
	reload_finished.connect(_on_finished);
func _process(_delta):
	if _reloading:
		_reloading_progress += _delta / 2.0;
		if _reloading_progress >= get_reload_needed_progress():
			_reloading_progress = 0.0;
			_reloading = false;
			_ammunition += Players.consume_ammo(max_ammonition - _ammunition);
			reload_finished.emit();
func _on_finished():
	old_tick = 0;
func _on_tick():
	var loaded : int = get_loaded_ammo();
	if old_tick != loaded:
		reload_tick.emit();
		old_tick = loaded;
