extends CanvasLayer

@export var control : Control;
@export var description_label : Label;
@export var tip_label : Label;
@export var title_label : Label;
@export var in_action_player : AudioStreamPlayer;
@export var game_over_player : AudioStreamPlayer;
@export var alarm_player : AudioStreamPlayer;
@export var victory : AudioStreamPlayer;
@export var alarm_bar : Bar;
@export var alarm_icon : TextureRect;
var can_reset : bool = false;

var alarm_progress : float = 0.0 :
	set(value):
		alarm_progress = value;
		if alarm_bar:
			alarm_bar.update(alarm_progress, 1.0, 1.0);
var enemies_alerted : int = 0;

signal reset;

func game_over(description : String, type : int = 0):
	enemies_alerted = 0;
	if !control.visible:
		get_tree().paused = true;
		match type:
			0:
				game_over_player.play();
				tip_label.text = "Apertem Enter ou Select para tentar novamente";
				title_label.text = "Fracasso";
			1:
				alarm_player.play();
				tip_label.text = "Apertem Enter ou Select para tentar novamente";
				title_label.text = "Fracasso";
			2:
				victory.play(30.0);
				tip_label.text = "Apertem Enter ou Select para jogar novamente ou F8 para fechar o jogo.";
				title_label.text = "Vitória";
		in_action_player.stop();
		description_label.modulate.a = 0.0;
		tip_label.modulate.a = 0.0;
		control.modulate.a = 0.0;
		control.visible = true;
		description_label.text = description;
		var tween : Tween = create_tween();
		tween.tween_property(control, "modulate", Color.WHITE, 2.0);
		tween.tween_property(description_label, "modulate", Color.WHITE, 0.5).set_delay(1.0);
		tween.tween_property(tip_label, "modulate", Color.WHITE, 0.5).set_delay(1.5);
		tween.play();
		can_reset = true;
func start():
	enemies_alerted = 0;
	alarm_progress = 0;
	tip_label.modulate.a = 0.0;
	game_over_player.stop();
	alarm_player.stop();
	victory.stop();
	in_action_player.play();
	control.visible = false;
	get_tree().paused = false;
func _ready():
	start();

func _process(delta):
	if alarm_progress != 0 && alarm_icon.texture is AnimatedTexture:
		alarm_icon.texture.pause = false;
	elif alarm_progress == 0 && alarm_icon.texture is AnimatedTexture:
		alarm_icon.texture.pause = true;
		alarm_icon.texture.current_frame = 0;
		
	if !control.visible:
		enemies_alerted = max(0, enemies_alerted);
		if enemies_alerted > 0:
			alarm_progress = clamp(alarm_progress + (delta / 10.0) * enemies_alerted, 0.0, 1.0);
		else:
			alarm_progress = clamp(alarm_progress -(delta / 10.0), 0.0, 1.0);
		if alarm_progress >= 1.0 && !control.visible:
			game_over("O alarme tocou! Os dados se perderam...", true);
	if Input.is_action_just_pressed("close"):
		get_tree().quit();
	if Input.is_action_just_pressed("start") && tip_label.modulate.a >= 0.25 && can_reset:
		can_reset = false;
		reset.emit();
		start();
		get_tree().change_scene_to_file("res://Level01.tscn");
		enemies_alerted = 0;
