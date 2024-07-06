class_name SawIcon
extends Sprite2D

@export var saw : Texture;
@export var not_saw : Texture;

func update(open : bool = true):
	visible = true;
	texture = saw if open else not_saw;	
