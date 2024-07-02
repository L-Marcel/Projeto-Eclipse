class_name RedGhost
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateChart;

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func flip(yes : bool):
	if yes:
		scale.y = -abs(scale.y);
		rotation_degrees = 180;
	else:
		scale.y = abs(scale.y);
		rotation_degrees = 0;

func move():
	var direction = Input.get_axis("red_left", "red_right");
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
	if Input.is_action_just_pressed("red_up") && is_on_floor():
		velocity.y = JUMP_VELOCITY;
		states.send_event("jump");
func crouch():
	if Input.is_action_pressed("red_down"):
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
	jump();
	crouch();
	var direction = move();
	if direction != 0:
		states.send_event("run");
func _on_run_state_processing(_delta):
	jump();
	crouch();
	var direction = move();
	if direction == 0:
		states.send_event("idle");
func _on_jump_state_processing(_delta):
	move();
	if velocity.y >= 0:
		states.send_event("fall");
func _on_fall_state_processing(_delta):
	move();
	if is_on_floor():
		states.send_event("idle");
func _on_crouch_state_processing(delta):
	var direction = Input.get_axis("red_left", "red_right");
	velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
	if direction != 0:
		flip(direction < 0);
	jump();
	if !is_on_floor():
		states.send_event("fall");
	elif !Input.is_action_pressed("red_down"):
		states.send_event("idle");
