class_name Player
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateChart;
@export var collision : CollisionShape2D;
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

var bullet : PackedScene = preload("res://objects/Bullet.tscn");
var furtive : bool = false;

const SPEED = 300.0;
const JUMP_VELOCITY = -400.0;

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
	collision.shape = collision.shape.duplicate();

var fire_on_run_heights : Array[int] = [-3, -5, -2, -4, -5, -2];
var fire_on_crouch_heights : Array[int] = [-2, -1, 2];

func fire(height : float = -2):
	if Input.is_action_pressed(key_fire) && can_fire:
		var bullet_instance = bullet.instantiate();
		bullet_instance.configure_as_ally(self);
		if scale.y == -abs(scale.y) && rotation_degrees == -180:
			bullet_instance.global_position = global_position + Vector2(-12, height);
			bullet_instance.linear_velocity = -bullet_instance.linear_velocity;
			bullet_instance.scale.y = -abs(bullet_instance.scale.y);
			bullet_instance.rotation_degrees = 180;
		else:
			bullet_instance.global_position = global_position + Vector2(12, height);
		get_parent().add_child(bullet_instance);
		can_fire = false;

func flip(yes : bool):
	if yes:
		scale.y = -abs(scale.y);
		rotation_degrees = 180;
	else:
		scale.y = abs(scale.y);
		rotation_degrees = 0;

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

func _on_idle_state_processing(_delta):
	fire(-2 if sprite.frame <= 2 else -1);
	jump();
	crouch();
	var direction = move();
	if direction != 0:
		states.send_event("run");
func _on_run_state_processing(_delta):
	fire(fire_on_run_heights[sprite.frame if sprite.animation == "run" else 0]);
	jump();
	crouch();
	var direction = move();
	if direction == 0:
		states.send_event("idle");
func _on_jump_state_processing(_delta):
	fire();
	move();
	if velocity.y >= 0:
		states.send_event("fall");
func _on_fall_state_processing(_delta):
	fire();
	move();
	if is_on_floor():
		states.send_event("idle");
func _on_crouch_state_processing(delta):
	fire(fire_on_crouch_heights[sprite.frame if sprite.animation == "crouch" else 0]);
	var direction = Input.get_axis(key_left, key_right);
	velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
	if direction != 0:
		flip(direction < 0);
	jump();
	if !is_on_floor():
		states.send_event("fall");
	elif !Input.is_action_pressed(key_down):
		states.send_event("idle");
