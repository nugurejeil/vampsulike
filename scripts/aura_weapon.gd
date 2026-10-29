class_name AuraWeapon
extends Weapon
## 가시 오라 (PRD P1-1): 범위 안의 적 모두에게 일정 간격으로 데미지를 준다.

const FILL_COLOR := Color(0.55, 0.85, 1.0, 0.14)
const EDGE_COLOR := Color(0.55, 0.85, 1.0, 0.55)
const PULSE_TIME := 0.15  # 초, 때릴 때 잠깐 밝아진다

var area := Area2D.new()
var shape := CircleShape2D.new()
var tick := 0.0
var pulse := 0.0


func _ready() -> void:
	z_index = -1  # 플레이어 그림 아래, 바닥(z_index -10) 위에 깐다
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitorable = false
	var collision := CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	_apply_level()


func set_level(value: int) -> void:
	super.set_level(value)
	_apply_level()


func _physics_process(delta: float) -> void:
	if pulse > 0.0:
		pulse = maxf(pulse - delta, 0.0)
		queue_redraw()
	tick -= delta
	if tick > 0.0:
		return
	var stats := _stats()
	tick = stats.interval * player.cooldown_scale
	for target in area.get_overlapping_areas():
		if target is Enemy:
			(target as Enemy).take_damage(stats.damage)
			pulse = PULSE_TIME


func _stats() -> Dictionary:
	return Balance.AURA_LEVELS[level - 1]


func _apply_level() -> void:
	shape.radius = _stats().radius
	queue_redraw()


func _draw() -> void:
	var fill := FILL_COLOR
	fill.a += pulse / PULSE_TIME * 0.15
	draw_circle(Vector2.ZERO, shape.radius, fill)
	draw_arc(Vector2.ZERO, shape.radius, 0.0, TAU, 64, EDGE_COLOR, 2.0)
