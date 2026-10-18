extends CharacterBody2D


@export var anim: AnimatedSprite2D
@export var map: Node2D

const CELL_SIZE = 32
const MOVE_TO_CELL = 0.2

var can_move = true
var is_moving = false




func _ready() -> void:
	animation()

func _unhandled_input(event: InputEvent) -> void:
	if not can_move or is_moving:
		return
	
	var direction: Vector2i = Vector2.ZERO
	
	if event.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	if event.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT
	if event.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	if event.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
	
	if direction == Vector2i.ZERO:
		return
	
	animation(direction)
	move(direction)
	

func _process(_delta: float) -> void:
	if not can_move:
		return
		
	if not is_moving and not press_key():
		animation()

func press_key() -> bool:
	return(
		Input.is_action_pressed("ui_left")
		or Input.is_action_pressed("ui_right")
		or Input.is_action_pressed("ui_up")
		or Input.is_action_pressed("ui_down")
	)

func move(direction:Vector2i) -> void:
	var movement: Vector2 = Vector2(direction) * CELL_SIZE
	var target_position: Vector2 = global_position + movement
	
	if not map.can_move(target_position):
		return
	
	is_moving = true
	
	
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(
		self,
		"global_position",
		target_position,
		MOVE_TO_CELL
	)
	
	await tween.finished
	
	is_moving = false
	
	map.use_step()
	
	if not can_move:
		return
	
	animation()

func animation(direction:Vector2i = Vector2i.ZERO) -> void:
	match direction:
		Vector2i.ZERO:
			anim.play("idle")
		Vector2i.LEFT:
			anim.play("move_left")
		Vector2i.RIGHT:
			anim.play("move_right")
		Vector2i.UP:
			anim.play("move_up")
		Vector2i.DOWN:
			anim.play("move_down")
