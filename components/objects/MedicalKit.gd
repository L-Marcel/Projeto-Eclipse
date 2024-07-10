class_name MedicalKit
extends Area2D

@export var sprite : AnimatedSprite2D;

func _ready():
	body_entered.connect(_on_body_entered);
	sprite.play("default");
	
func _on_body_entered(body : Node2D):
	if body is Player:
		body_entered.disconnect(_on_body_entered);
		var players = get_tree().get_nodes_in_group("player");
		for player in players:
			if player is Player:
				player.health.heal(8.0);
		sprite.play("open");
