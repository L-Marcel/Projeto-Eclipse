class_name Player
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateChart;
@export var hurtbox : Hurtbox;
@export var fire_point : FirePoint;
@export var flash : Flash;
@export var health : Health;
@export var gun_fire_sound : AudioStreamPlayer;
@export var step_sound_player : AudioStreamPlayer;
@export var step_sounds : Array[AudioStream] = [];
var step_frame : int = 0;
@export var sprite_frames : SpriteFrames;
@export var player_one : bool = true :
	set(value):
		player_one = value;
		if player_one:
			key_left = "red_left";
			key_right = "red_right";
			key_jump = "red_up";
			key_down = "red_down";
			key_fire = "red_fire";
			key_interact = "red_interact";
		else:
			key_left = "green_left";
			key_right = "green_right";
			key_jump = "green_up";
			key_down = "green_down";
			key_fire = "green_fire";
			key_interact = "green_interact";

var bullet : PackedScene = preload("res://components/objects/Bullet.tscn");
var furtive : bool = false;

const SPEED = 300.0;
const JUMP_VELOCITY = -400.0;

var flipped : bool = false :
	set(value):
		if flipped != value && flash:
			flash.on = false;
		flipped = value;
var fire_delay : float = 0.25;
var can_fire : bool = true :
	set(value):
		can_fire = value;
		if !can_fire:
			await get_tree().create_timer(fire_delay).timeout;
			can_fire = true;
var key_left : String = "red_left";
var key_right : String = "red_right";
var key_jump : String = "red_up";
var key_down : String = "red_down";
var key_fire : String = "red_fire";
var key_interact : String = "red_interact";

func _ready():
	Mobs.registry(self);
	sprite.sprite_frames = sprite_frames;
	hurtbox.shape = hurtbox.shape.duplicate();

func fire(precision : float = randf_range(0.0, 1.0)):
	if Input.is_action_pressed(key_fire) && can_fire:
		flash.on = true;
		var bullet_instance = bullet.instantiate() as Bullet;
		bullet_instance.configure_as_ally(self);
		var angle_diff = randf_range(-10, 10) * (1.0 - precision);
		if scale.y == -abs(scale.y):
			bullet_instance.global_position = fire_point.global_position;
			bullet_instance.rotation_degrees = 180 + angle_diff;
		else:
			bullet_instance.rotation_degrees = angle_diff;
			bullet_instance.global_position = fire_point.global_position;
		bullet_instance.linear_velocity = Vector2.from_angle(bullet_instance.rotation) * 800;
		gun_fire_sound.play();
		get_parent().add_child(bullet_instance);
		can_fire = false;

func flip(yes : bool):
	if yes:
		scale.y = -abs(scale.y);
		rotation_degrees = 180;
		flipped = true;
	else:
		scale.y = abs(scale.y);
		rotation_degrees = 0;
		flipped = false;

func step():
	if sprite.animation == "run" && step_sounds.size() > 0 && step_frame != sprite.frame && (sprite.frame == 2 || sprite.frame == 5):
		step_sound_player.stream = step_sounds[randi() % step_sounds.size()];
		step_sound_player.play();
		step_frame = sprite.frame;
func move():
	var direction = Input.get_axis(key_left, key_right);
	if direction:
		velocity.x = direction * SPEED;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED);
	if direction != 0:
		flip(direction < 0);
	return direction;
func apply_gravity(delta : float):
	if !is_on_floor():
		velocity += get_gravity() * delta;
func jump():
	if Input.is_action_just_pressed(key_jump) && is_on_floor():
		velocity.y = JUMP_VELOCITY;
		states.send_event("jump");
func crouch():
	if Input.is_action_pressed(key_down):
		states.send_event("crouch");
func death():
	if health.is_dead():
		states.send_event("death");

func _physics_process(delta):
	apply_gravity(delta);
	move_and_slide();

func _on_idle_state_entered():
	sprite.play("idle");
func _on_run_state_entered():
	sprite.play("run");
func _on_jump_state_entered():
	sprite.play("jump");
func _on_fall_state_entered():
	sprite.play("fall");
func _on_crouch_state_entered():
	sprite.play("crouch");
func _on_death_state_entered():
	set_collision_layer_value(1, false);
	sprite.play("death");

func _on_idle_state_processing(_delta):
	death();
	fire(0.75);
	jump();
	crouch();
	var direction = move();
	if direction != 0:
		states.send_event("run");
func _on_run_state_processing(_delta):
	death();
	step();
	fire(0.5);
	jump();
	crouch();
	var direction = move();
	if direction == 0:
		states.send_event("idle");
func _on_jump_state_processing(_delta):
	death();
	fire(0.25);
	move();
	if !Input.is_action_pressed(key_jump):
		velocity.y = 0;
	if velocity.y >= 0:
		states.send_event("fall");
func _on_fall_state_processing(_delta):
	death();
	fire(0.25);
	move();
	if is_on_floor():
		states.send_event("idle");
func _on_crouch_state_processing(delta):
	death();
	fire(1.0);
	var direction = Input.get_axis(key_left, key_right);
	velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
	if direction != 0:
		flip(direction < 0);
	jump();
	if !is_on_floor():
		states.send_event("fall");
	elif !Input.is_action_pressed(key_down):
		states.send_event("idle");

func _on_run_state_exited():
	step_frame = -1;