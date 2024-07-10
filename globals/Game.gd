extends CanvasLayer

@export var control : Control;
@export var description_label : Label;
@export var tip_label : Label;
@export var in_action_player : AudioStreamPlayer;
@export var game_over_player : AudioStreamPlayer;
var can_reset : bool = false;

signal reset;

func game_over(description : String):
	if !visible:
		get_tree().paused = true;
		game_over_player.play();
		in_action_player.stop();
		description_label.modulate.a = 0.0;
		tip_label.modulate.a = 0.0;
		control.modulate.a = 0.0;
		visible = true;
		description_label.text = description;
		var tween : Tween = create_tween();
		tween.tween_property(control, "modulate", Color.WHITE, 2.0);
		tween.tween_property(description_label, "modulate", Color.WHITE, 0.5).set_delay(1.0);
		tween.tween_property(tip_label, "modulate", Color.WHITE, 0.5).set_delay(1.5);
		tween.play();
		can_reset = true;
func start():
	tip_label.modulate.a = 0.0;
	game_over_player.stop();
	in_action_player.play();
	visible = false;
	get_tree().paused = false;
func _ready():
	start();

func _process(_delta):
	if Input.is_action_just_pressed("start") && tip_label.modulate.a >= 0.25 && can_reset:
		can_reset = false;
		reset.emit();
		start();
		get_tree().change_scene_to_file("res://Level01.tscn");
