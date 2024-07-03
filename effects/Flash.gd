class_name Flash
extends Node2D

func _ready():
	await get_tree().create_timer(0.1).timeout;
	queue_free();
