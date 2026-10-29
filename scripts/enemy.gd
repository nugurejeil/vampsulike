class_name Enemy
extends Area2D
## 적. 플레이어를 향해 곧장 다가온다 (PRD P0-3). 종류별 값은 Balance.ENEMY_TYPES에 있다 (PRD P1-4, P1-5).

signal damaged(amount: int, at: Vector2)
signal died(at: Vector2)

const OUTLINE_COLOR := Color("#2a0d0b")
const ELITE_OUTLINE_COLOR := Color("#ffd166")
const FLASH_COLOR := Color("#ffffff")
const FLASH_TIME := 0.1  # 초, 맞으면 잠깐 하얗게 깜빡인다 (PRD P1-6)

var target: Node2D
var kind := "basic"
var hp := 0
var speed := 0.0
var radius := 0.0
var contact_damage := 0
var color := Color.WHITE
var flash := 0.0
# 플레이어와 살짝 겹친 거리에서 멈춘다. 중심까지 파고들면 플레이어 그림에 가려져
# 보이지 않는 적에게 맞고, 무기도 그 적을 쏘느라 공격이 안 보이게 된다.
var stop_distance := 0.0


## 씬에 넣기 전에 부른다.
func setup(type_name: String) -> void:
	var stats: Dictionary = Balance.ENEMY_TYPES[type_name]
	kind = type_name
	hp = stats.hp
	speed = stats.speed
	radius = stats.radius
	contact_damage = stats.damage
	color = stats.color
	stop_distance = Player.RADIUS + radius - 6.0


func _ready() -> void:
	add_to_group("enemies")
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape


func _physics_process(delta: float) -> void:
	if flash > 0.0:
		flash -= delta
		if flash <= 0.0:
			queue_redraw()
	if target == null:
		return
	var to_target := target.global_position - global_position
	if to_target.length() > stop_distance:
		global_position += to_target.normalized() * speed * delta


func take_damage(amount: int) -> void:
	if hp <= 0:
		return  # 같은 프레임에 이미 처치된 적
	hp -= amount
	damaged.emit(amount, global_position)
	if hp <= 0:
		# 같은 프레임에 무기가 다시 노리지 않도록 그룹에서 먼저 뺀다
		remove_from_group("enemies")
		died.emit(global_position)
		queue_free()
		return
	flash = FLASH_TIME
	queue_redraw()


func _draw() -> void:
	var elite := kind == "elite"
	draw_circle(Vector2.ZERO, radius + (4.0 if elite else 2.0), ELITE_OUTLINE_COLOR if elite else OUTLINE_COLOR)
	draw_circle(Vector2.ZERO, radius, FLASH_COLOR if flash > 0.0 else color)
