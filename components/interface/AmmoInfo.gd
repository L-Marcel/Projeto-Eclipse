class_name AmmoInfo
extends Label

func _ready():
	Players.ammo_changed.connect(update);

func update():
	text = "%dx" % [Players.get_ammo()];
