extends Area2D


@onready var AnimBullet = $AnimatedSprite2D
@onready var CollisionShape = $CollisionShape2D

var velocity = Vector2()
var VelocityPerPixel = 1200
var Impact = false
var CrossfireEnemys = false


func _ready():
	AnimBullet.play("default")


func _process(delta):
	if !Impact:
		position += transform.y * (VelocityPerPixel * -1) * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("queue_free")


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		ToDoAnimWhenImpact()
		if !CrossfireEnemys:
			body.Destroyed()
	elif body.is_in_group("player"):
		ToDoAnimWhenImpact()
#		body.Destroyed()
	elif body.is_in_group("floor"):
		ToDoAnimWhenImpact()
		#To do when floor get hit


func ToDoAnimWhenImpact():
	Impact = true
	CollisionShape.set_deferred("disabled", true)
	AnimBullet.position.y = 10
	AnimBullet.rotation_degrees = 180
	AnimBullet.play("impact")


func _on_animated_sprite_2d_animation_finished():
	call_deferred("queue_free")


func _on_area_entered(area):
	if area.is_in_group("bullet"):
		pass
#		ToDoAnimWhenImpact()
