class_name Flash
extends Node2D

var on : bool = false :
	set(value):
		on = value;
		visible = value;
		if value:
			await get_tree().create_timer(0.1).timeout;
			on = false;
			visible = false;

func _ready():
	visible = on;
