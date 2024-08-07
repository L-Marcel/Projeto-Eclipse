extends Node

@export var red_health : Health;
@export var green_health : Health;
@export var red_clip : Clip;
@export var green_clip : Clip;

signal ammo_changed;
var _ammunitions : int = 0 :
	set(value):
		_ammunitions = value;
		ammo_changed.emit();

func _ready():
	Game.reset.connect(reset);

func reset():
	red_health.reset();
	green_health.reset();
	red_clip.reset();
	green_clip.reset();
	_ammunitions = 0;

func add_ammo(amount : int):
	if amount > 0:
		_ammunitions += amount;
func get_ammo():
	return _ammunitions;
func consume_ammo(requested : int = 0):
	if requested < 0:
		return 0;
	var consumed : int = min(_ammunitions, requested);
	_ammunitions -= consumed;
	return consumed;
