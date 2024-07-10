extends Node2D

@export var sprite : AnimatedSprite2D;
@export var interaction : Interaction;
@export var tile : TileMapLayer;
var actived : bool = false;

func _ready():
	
	interaction.registry(_on_active);
	interaction.focus.connect(_on_focus);
	interaction.unfocus.connect(_on_unfocus);
	
func _on_focus():
	if !actived:
		sprite.play("focus");

func _on_unfocus():
	if !actived:
		sprite.play("default");

func _on_active(by : Node):
	if by is Player && !by.player_one:
		actived = true;
		sprite.play("actived");
		interaction.unregistry();
		tile.queue_free();