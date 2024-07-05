extends Node2D

@export var area : Area2D;
var count : int = 0 :
	set(value):
		count = value;
		if count > 0:
			modulate.a = 0.5;
		else:
			modulate.a = 1.0;

func _ready():
	area.body_entered.connect(on_body_entered);
	area.body_exited.connect(on_body_exited);

func on_body_entered(body : Node2D):
	if body is Player:
		count += 1;
		body.furtive = true;

func on_body_exited(body : Node2D):
	if body is Player:
		count -= 1;
		body.furtive = false;
