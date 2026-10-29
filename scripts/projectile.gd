class_name Projectile
extends Area2D
## 무기가 쏘는 투사체. 서로 다른 적을 pierce마리 맞히면 사라진다 (PRD P0-2, P1-1).
## 무기가 add_child 전에 아래 값을 채운다.

const LIFETIME := 2.0  # 초, 화면 밖으로 충분히 날아간 뒤 사라진다

var direction := Vector2.RIGHT
var speed := Balance.PROJECTILE_SPEED
var damage := 10
var pierce := 1
var radius := 5.0
var length := 0.0  # 0보다 크면 진행 방향으로 긴 창 모양으로 그린다
var color := Color.WHITE
var age := 0.0
var hit_ids: Array[int] = []  # 이미 맞힌 적, 관통 중 같은 적을 두 번 맞히지 않는다


func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	rotation = direction.angle()
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	age += delta
	if age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if pierce <= 0 or not area is Enemy:
		return
	var id := area.get_instance_id()
	if id in hit_ids:
		return
	hit_ids.append(id)
	(area as Enemy).take_damage(damage)
	pierce -= 1
	if pierce <= 0:
		queue_free()


func _draw() -> void:
	if length > 0.0:
		draw_line(Vector2(-length / 2.0, 0.0), Vector2(length / 2.0, 0.0), color, radius)
		draw_circle(Vector2(length / 2.0, 0.0), radius * 0.6, Color.WHITE)
	else:
		draw_circle(Vector2.ZERO, radius, color)
