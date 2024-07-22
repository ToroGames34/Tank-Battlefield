extends CharacterBody2D


signal ShootSig(Bullet, Rotation, Position)

@onready var Bullet = preload("res://BulletPlayer/bullet_player.tscn").instantiate()

@onready var GunSystem = $Gun
@onready var FireShoot = $Gun/FireShoot
@onready var ShootSound = $ShootSound
@onready var Marker = $Gun/Marker2D
@onready var AnimDestroy = $AnimatedDestroy
@onready var StructureTank = $Structure_Tank

var TimerAttackSpeed = Timer.new()
var aim_speed = deg_to_rad(1)
var AttackSpeed = 1
var VelocityPerPixel = 150 # Before 150
var RotationSpeed = 1.0 # Before 1.0
var RotationDirecction = 0
var RotTrack = 0
var Lives = 1
var CanShoot = true
var TorretMoving = false
var Destroy = false


func _ready():
	FireShoot.visible = false
	AnimDestroy.visible = false
	TimerAttackSpeedSettings()


func TimerAttackSpeedSettings():
	TimerAttackSpeed.wait_time = AttackSpeed
	TimerAttackSpeed.one_shot = true
	TimerAttackSpeed.connect("timeout", self._on_TimerAttackSpeed_timeout)
	add_child(TimerAttackSpeed)


func get_input():
	RotationDirecction = 0
	RotTrack = 0
	if Input.is_action_pressed("ui_left"):
		RotationDirecction = -1
		RotTrack = 1
	elif Input.is_action_pressed("ui_right"):
		RotationDirecction = 1
		RotTrack = 1
	velocity = transform.y * Input.get_axis("ui_up", "ui_down") * VelocityPerPixel
	if Input.get_axis("ui_up", "ui_down") > 0:
		RotationDirecction = RotationDirecction * -1
	if velocity.length() > 0 or RotTrack == 1:
		MoveTraks(1)
	else:
		MoveTraks(2)


func MoveTraks(n):
	match n:
		1:
			$Structure_Tank/Track1.play("default")
			$Structure_Tank/Track2.play("default")
		2:
			$Structure_Tank/Track1.stop()
			$Structure_Tank/Track2.stop()


@warning_ignore("unused_parameter")
func _process(delta):
	if !Destroy:
		AimSystem()


func _physics_process(delta):
	if !Destroy:
		get_input()
		rotation += RotationDirecction * RotationSpeed * delta
		move_and_slide()


func AimSystem():
	var MousePos = get_global_mouse_position()
	var angle_to_mouse = GunSystem.get_angle_to(MousePos)
	
	if abs(angle_to_mouse) > aim_speed:
		TorretMoving = true
		if angle_to_mouse > 0:
			GunSystem.rotation += aim_speed
		else:
			GunSystem.rotation -= aim_speed
	else:
		TorretMoving = false


func _input(event):
	if event.is_action_pressed("click"):
		if !TorretMoving:
			if CanShoot and !Destroy:
				Shoot()


func Shoot():
	CanShoot = false
	TimerAttackSpeed.start()
	ShootSound.play()
	FireShoot.visible = true
	FireShoot.play("default")
	Bullet = preload("res://BulletPlayer/bullet_player.tscn").instantiate()
	emit_signal("ShootSig", Bullet, GunSystem.global_rotation_degrees + 90, Marker.global_position)


func _on_fire_shoot_animation_finished():
	FireShoot.visible = false


func _on_TimerAttackSpeed_timeout():
	CanShoot = true


func Destroyed():
	Lives += -1
	if Lives <= 0:
		Destroy = true
		AnimDestroy.visible = true
		GunSystem.visible = false
		StructureTank.visible = false
		AnimDestroy.play("default")


func _on_animated_destroy_animation_finished():
	call_deferred("queue_free")

