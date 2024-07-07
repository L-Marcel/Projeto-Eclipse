@tool
class_name InvisibleWall
extends StaticBody2D

@export var collision : CollisionShape2D;
@export var height : float = 256.0 :
	set(value):
		height = value;
		if collision:
			collision.shape.size.y = height;
@export var width : float = 32.0 :
	set(value):
		width = value;
		if collision:
			collision.shape.size.x = width;

func _ready():
	collision.shape = collision.shape.duplicate();
	collision.shape.size.x = width;
	collision.shape.size.y = height;
