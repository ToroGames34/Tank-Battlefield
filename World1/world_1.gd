extends Node2D


@onready var Enemy = preload("res://Enemy/enemy.tscn")
@onready var PlayerT = preload("res://Player/player.tscn")

@onready var BulletPlayerContainer = $BulletPlayerContainer
@onready var BulletEnemyContainer = $BulletEnemyContainer
@onready var PointsOfRespawnEnemy = $RespawnPointsEnemy
@onready var EnemyContainer = $EnemyContainer
@onready var ActuallyPlayer = $Player

var TimerCheckPoint = Timer.new()
var CheckForSpawnPoint = 1
var InitialEnemys = 4 # Max 4
var GameCanRun = false
var SpawnPoint1 = true
var SpawnPoint2 = true
var SpawnPoint3 = true
var SpawnPoint4 = true
var OneTimeSpawnEnemy = true
var TryUntilEnemySpawn = false


func _ready():
	TimerCheckPointSettings()
	SetInitialEnemys()


func TimerCheckPointSettings():
	TimerCheckPoint.wait_time = CheckForSpawnPoint
	TimerCheckPoint.connect("timeout", self._TimerCheckPoint_timeout)
	add_child(TimerCheckPoint)


func SetInitialEnemys():
	for i in range(InitialEnemys):
		SpawnEnemys()
		await get_tree().create_timer(0.1).timeout
		if i == InitialEnemys - 1:
			GameCanRun = true


@warning_ignore("unused_parameter")
func _process(delta):
	if GameCanRun:
		CheckNumOfEnemysAndRespawn()


func CheckNumOfEnemysAndRespawn():
	if EnemyContainer.get_child_count() < 4:
		if OneTimeSpawnEnemy:
			OneTimeSpawnEnemy = false
			SpawnEnemys()


func ChooseSpawnPoint():
	var WhichPoss = -1
	var PointSpawn = PointsOfRespawnEnemy.get_child_count();
	randomize();
	var PointChoosed = randi_range(0, PointSpawn - 1);
	
	if PointChoosed == 0:
		if SpawnPoint1:
			WhichPoss = 0
	elif PointChoosed == 1:
		if SpawnPoint2:
			WhichPoss = 1
	elif PointChoosed == 2:
		if SpawnPoint3:
			WhichPoss = 2
	elif PointChoosed == 3:
		if SpawnPoint4:
			WhichPoss = 3
	
	if WhichPoss != -1:
		TryUntilEnemySpawn = false
		return WhichPoss
	else:
		TryUntilEnemySpawn = true


func SpawnEnemys():
	var PosToEnemy = Vector2()
	var WhichPos = -1
	
	WhichPos = ChooseSpawnPoint()
	
	if WhichPos != -1 and !TryUntilEnemySpawn:
		PosToEnemy = PointsOfRespawnEnemy.get_child(WhichPos).position
		SpawnEnemy(PosToEnemy)
		OneTimeSpawnEnemy = true
		TimerCheckPoint.stop()
	else:
		TimerCheckPoint.start()


func SpawnEnemy(Pos: Vector2):
	Enemy = preload("res://Enemy/enemy.tscn").instantiate()
	Enemy.position = Pos
	Enemy.Player = ActuallyPlayer
	Enemy.CanChase = true
	Enemy.connect("ShootBullet", self._on_enemy_shoot_bullet)
	EnemyContainer.call_deferred("add_child", Enemy)


func _TimerCheckPoint_timeout():
	SpawnEnemys()


func _on_player_shoot_sig(Bullet, Rotation, Position):
	var BulletToSent = Bullet
	BulletToSent.global_rotation_degrees = Rotation
	BulletToSent.position = Position
	BulletPlayerContainer.call_deferred("add_child", BulletToSent)


func _on_enemy_shoot_bullet(Bullet, Rotation, Position):
	var BulletToSentE = Bullet
	BulletToSentE.global_rotation_degrees = Rotation
	BulletToSentE.position = Position
	BulletToSentE.CrossfireEnemys = true
	BulletEnemyContainer.call_deferred("add_child", BulletToSentE)


@warning_ignore("unused_parameter")
func _on_area_2d_point_1_body_entered(body):
	SpawnPoint1 = false


@warning_ignore("unused_parameter")
func _on_area_2d_point_1_body_exited(body):
	SpawnPoint1 = true


@warning_ignore("unused_parameter")
func _on_area_2d_point_2_body_entered(body):
	SpawnPoint2 = false


@warning_ignore("unused_parameter")
func _on_area_2d_point_2_body_exited(body):
	SpawnPoint2 = true


@warning_ignore("unused_parameter")
func _on_area_2d_point_3_body_entered(body):
	SpawnPoint3 = false


@warning_ignore("unused_parameter")
func _on_area_2d_point_3_body_exited(body):
	SpawnPoint3 = true


@warning_ignore("unused_parameter")
func _on_area_2d_point_4_body_entered(body):
	SpawnPoint4 = false


@warning_ignore("unused_parameter")
func _on_area_2d_point_4_body_exited(body):
	SpawnPoint4 = true

