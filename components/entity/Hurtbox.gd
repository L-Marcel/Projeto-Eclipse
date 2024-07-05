@tool
class_name Hurtbox
extends CollisionShape2D

@export var health : Health:
	set(value):
		health = value;
		update_configuration_warnings();

func _ready():
	shape = shape.duplicate(true);

func _get_configuration_warnings():
	var errors : Array[String] = [];
	
	if !health:
		errors.append("Precisa ter um contador de vida!");

	return errors;
