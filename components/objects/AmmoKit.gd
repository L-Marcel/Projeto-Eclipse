class_name AmmoKit
extends Area2D

@export var sprite : AnimatedSprite2D;

func _ready():
	body_entered.connect(_on_body_entered);
	sprite.play("default");
	
func _on_body_entered(body : Node2D):
	if body is Player:
		body_entered.disconnect(_on_body_entered);
		Players.add_ammo(16);
		sprite.play("void");
