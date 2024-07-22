extends CharacterBody2D


@onready var Nav = $NavigationAgent2D

@export var Player = Node2D
var Speed = 100
var Acceleration = 7
var ToChase = Vector2()


func _ready():
	ToChase = global_position


func _physics_process(_delta: float):
	var direction = Vector2()
	
	Nav.target_position = ToChase
	if Nav.is_target_reachable():
		direction = Nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * Speed, Acceleration * _delta)
		if Nav.distance_to_target() > 1:
			move_and_slide()
		rotation = velocity.angle()
	else:
		ToDoWhenTragetUnreache()


func _input(event):
	if event.is_action_released("ui_l"):
		pass
	if event.is_action_pressed("click"):
		ToChase = get_global_mouse_position()


func _on_navigation_agent_2d_target_reached():
	pass


func ToDoWhenTragetUnreache():
	pass
