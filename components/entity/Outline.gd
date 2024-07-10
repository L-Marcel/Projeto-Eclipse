@tool
class_name Outline
extends AnimatedSprite2D

@export var on : bool = false :
	set(value):
		on = value;
		_on_animation_changed();
@export var interaction : Interaction;
@export var main : AnimatedSprite2D;

func _ready():
	if !Engine.is_editor_hint():
		interaction.focus.connect(_on_focus);
		interaction.unfocus.connect(_on_unfocus);
	main.frame_changed.connect(_on_frame_changed);
	main.animation_changed.connect(_on_animation_changed);
func _on_unfocus():
	on = interaction.focused && interaction.is_possible();
func _on_focus():
	on = interaction.focused && interaction.is_possible();
func _on_frame_changed():
	if animation == main.animation:
		frame = main.frame;
func _on_animation_changed():
	if sprite_frames.has_animation(main.animation):
		visible = on;
		animation = main.animation;
	else:
		visible = false;
