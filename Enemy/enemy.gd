extends CharacterBody2D


signal ShootBullet(Bullet, Rotation, Position)

@onready var Bullet = preload("res://BulletPlayer/bullet_player.tscn").instantiate()

@onready var RayDetect = $AreaToDetectPlayer/AreaDetect/RayCast2DDetect
@onready var RayPlayerInRadius = $AreaToDetectPlayer/AreaDetect/RayCastDetectInRadius
@onready var GunSystem = $Gun
@onready var FireShoot = $Gun/FireShoot
@onready var RaySeeTarget = $Gun/RayCastSeeTarget
@onready var MarkerFront = $BodyToRot/MarkerFront
@onready var MarkerGun = $Gun/Marker2D
@onready var StructureTank = $BodyToRot/StructureTank
@onready var AnimDestroy = $AnimatedDestroy
@onready var ShootSound = $AudioShoot
@onready var Nav = $NavigationAgent2D
@onready var CollisionBody = $CollisionBody
@onready var BodyRot = $BodyToRot

var Player = null
var TimerShoot = Timer.new()
var TimerNav = Timer.new()
var AttackSpeed = 1.5
var Speed = 100
var Acceleration = 7
var TakeWayAt = 1#sec
var StopWhenPlayerInRadius = 1#Sec
var Lives = 1
var aim_speed = deg_to_rad(1) * 0.5
var Target = null
var TargetFriend = null
var TargetInRange = null
var StartToShoot = true
var CanShoot = false
var DefaultAim = false
var TargetSee = false
var Destroy = false
var GunSystemCanRot = true
var IsPlayerOutOfRange = false
var CanChase = true# <- Queen
var PlayerInRange = false
var TankMoving = false
var OneTimePlayerTargetReached = true
var OneTimeTargetAreaDetect = true
var OneShootCanChase = true
var OneTimeChaseNormally = true
var OneTimeChaseBehindWall = true


func _ready():
	FireShoot.visible = false
	AnimDestroy.visible = false
	TakeWayAt = 1
	randomize()
#	TakeWayAt = randi_range(5, 10)
	Nav.path_desired_distance = randi_range(50, 150)
	TimerShootSettings()
	TimerNavSettings()


func TimerShootSettings():
	TimerShoot.wait_time = AttackSpeed
	TimerShoot.connect("timeout", self._on_TimerShoot_timeout)
	add_child(TimerShoot)


func TimerNavSettings():
	TimerNav.wait_time = TakeWayAt
	TimerNav.one_shot = true
	TimerNav.connect("timeout", self._on_TimerNav_timeout)
	add_child(TimerNav)


@warning_ignore("unused_parameter")
func _process(delta):
	if !Destroy:
		if Target != null:
			RayDetect.look_at(Target.global_position)
			if CanShoot:
				AimToPlayer()
		ReallyCanShoot()
		if DefaultAim:
			RetookDefaultAim()
		TargetSeeIt()
		OneCanChase()
		if CanChase:
			DetectIfPlayerInAreaRange()
			TargetStillInAreaDetect()


func OneCanChase():
	if CanChase:
		if OneShootCanChase:
			OneShootCanChase = false
			TimerNav.start()


func _physics_process(_delta: float):
	var direction = Vector2()
	
	if CanChase and !Destroy:
		if Nav.is_target_reachable():
			direction = Nav.get_next_path_position() - global_position
			direction = direction.normalized()
			velocity = velocity.lerp(direction * Speed, Acceleration * _delta)
			if Nav.distance_to_target() > 1:
				MoveTraks(1)
				TankMoving = true
				move_and_slide()
				BodyRot.rotation = velocity.angle() - 80.1
				CollisionBody.rotation = velocity.angle() - 80.1
				if !CanShoot and !DefaultAim:
					GunSystem.rotation = velocity.angle()
			else:
				MoveTraks(2)
				TankMoving = false
				SetTargetToChase(global_position)


func SetTargetToChase(t: Vector2):
	Nav.target_position = t


func MoveTraks(n):
	match n:
		1:
			$BodyToRot/StructureTank/Track1.play("default")
			$BodyToRot/StructureTank/Track2.play("default")
		2:
			$BodyToRot/StructureTank/Track1.stop()
			$BodyToRot/StructureTank/Track2.stop()


func _on_area_detect_body_entered(body):
	if body.is_in_group("player"):
		Target = body
		PlayerInRange = true
	
	if body.is_in_group("enemy"):
		TargetFriend = body


func _on_area_detect_body_exited(body):
	if body.is_in_group("player"):
		Target = null
		TimerShoot.stop()
		StartToShoot = true
		DefaultAim = true
		PlayerInRange = false
	if body.is_in_group("enemy"):
		TargetFriend = null


func _on_TimerShoot_timeout():
	if Target != null and CanShoot:
		if TargetSee:
			if !Destroy:
				FireShoot.visible = true
				FireShoot.play("default")
				Bullet = preload("res://BulletPlayer/bullet_player.tscn").instantiate()
				emit_signal("ShootBullet", Bullet, GunSystem.global_rotation_degrees + 90, MarkerGun.global_position)
				ShootSound.play()


func _on_fire_shoot_animation_finished():
	FireShoot.visible = false


func AimToPlayer():
	var TargetPos = Target.global_position
	var angle_to_Target = GunSystem.get_angle_to(TargetPos)
	
	if abs(angle_to_Target) > aim_speed:
		if angle_to_Target > 0:
			GunSystem.rotation += aim_speed
		else:
			GunSystem.rotation -= aim_speed
	else:
		if Target != null and CanShoot:
			if StartToShoot:
				StartToShoot = false
				TimerShoot.start()


func ReallyCanShoot():
	if RayDetect.is_colliding():
		var RayColl = RayDetect.get_collider()
		if RayColl != null:
			if RayColl.is_in_group("player"):
				CanShoot = true
				DefaultAim = false
			else:
				CanShoot = false
				DefaultAim = true


func RetookDefaultAim():
	var TargetPos = MarkerFront.global_position
	var angle_to_Target = GunSystem.get_angle_to(TargetPos)
	
	if abs(angle_to_Target) > aim_speed:
		if angle_to_Target > 0:
			GunSystem.rotation += aim_speed
		else:
			GunSystem.rotation -= aim_speed
	else:
		DefaultAim = false


func TargetSeeIt():
	if RaySeeTarget.is_colliding():
		var RayCol = RaySeeTarget.get_collider()
		if RayCol != null:
			if RayCol.is_in_group("player"):
				TargetSee = true
			else:
				TargetSee = false
	else:
		TargetSee = false


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


func _on_TimerNav_timeout():
	GetPosPlayer()


func GetPosPlayer():
	if CanChase:
		if Player != null:
			SetTargetToChase(Player.position)
			OneTimePlayerTargetReached = true
			OneTimeTargetAreaDetect = true
			OneTimeChaseNormally = true
			OneTimeChaseBehindWall = true


func _on_area_in_range_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("enemy"):
#		SetTargetToChase(global_position)
		if CanShoot:
			SetTargetToChase(global_position)
	if body.is_in_group("player"):
		TargetInRange = body


func _on_navigation_agent_2d_target_reached():
	IsPlayerBehindWall()
	ChacePlayerNormallized()


func IsPlayerBehindWall():
	if PlayerInRange and !CanShoot:
		if OneTimeChaseBehindWall:
			OneTimeChaseBehindWall = false
			TimerNav.start()


func ChacePlayerNormallized():
	if !PlayerInRange:
		if OneTimeChaseNormally:
			OneTimeChaseNormally = false
			TimerNav.start()


func _on_area_in_range_body_exited(body):
	if body.is_in_group("player"):
		TargetInRange = null


func DetectIfPlayerInAreaRange():
	if TargetInRange != null:
		RayPlayerInRadius.look_at(TargetInRange.global_position)
	PlayerInRadius()


func PlayerInRadius():
	if RayPlayerInRadius.is_colliding():
		var RayCol = RayPlayerInRadius.get_collider()
		if RayCol != null:
			if RayCol.is_in_group("player"):
				await get_tree().create_timer(StopWhenPlayerInRadius).timeout
				SetTargetToChase(global_position)


func TargetStillInAreaDetect():
	if PlayerInRange and !CanShoot and !TankMoving:
		if OneTimeTargetAreaDetect:
			OneTimeTargetAreaDetect = false
			TimerNav.start()

