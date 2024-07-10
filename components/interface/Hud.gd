class_name Hud
extends CanvasLayer

@export var red_bar : Bar;
@export var green_bar : Bar;

func _ready():
	Players.red_health.changed.connect(red_bar.update);
	Players.green_health.changed.connect(green_bar.update);
