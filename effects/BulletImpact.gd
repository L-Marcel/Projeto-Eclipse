class_name BulletImpact
extends Node2D

@export var particles : CPUParticles2D;
@export var light : PointLight2D;
@export var impact_sound : AudioStreamPlayer;
var sticks : PackedScene = preload("res://effects/BulletImpactStick.tscn");

func _ready():
	impact_sound.play();
	child_exiting_tree.connect(check_queue_free)
	particles.finished.connect(clear);
	particles.emitting = true;
	for i in randi_range(2, 4):
		var stick_instance = sticks.instantiate();
		stick_instance.configure(randf_range(-45, 45), rotation);
		add_child(stick_instance);

func clear():
	particles.queue_free();
	light.queue_free();
	impact_sound.queue_free();
func check_queue_free(_by : Node2D):
	if get_child_count() <= 0:
		queue_free();
