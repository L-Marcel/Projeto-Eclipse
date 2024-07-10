class_name ClipHud
extends HBoxContainer

@export var player_one : bool = true;
var clip : Clip;
var bullet_icon : PackedScene = Scenes.get_resource("BulletIcon");
var empty_icon : PackedScene = Scenes.get_resource("EmptyBulletIcon");

func _ready():
	if player_one:
		clip = Players.red_clip;
	else:
		clip = Players.green_clip;
	clip.changed.connect(update);
	update();

func update():
	var amount : int = clip.get_amount();
	for child in get_children():
		child.queue_free();
	for i in range(amount):
		var icon : TextureRect = bullet_icon.instantiate();
		add_child(icon);
	for i in range(clip.max_ammonition - amount):
		var icon : TextureRect = empty_icon.instantiate();
		add_child(icon);
