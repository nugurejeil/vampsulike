class_name Gem
extends Node2D
## 바닥에 떨어진 아이템: 경험치 보석(PRD P0-6) 또는 회복 아이템(PRD P2-1).
## 흡수 범위에 들어오면 플레이어에게 끌려가 흡수된다.

signal collected

const SIZE := 7.0
const PULL_SPEED := 450.0  # px/초, 플레이어 이동 속도보다 빨라야 따라잡는다
const XP_COLOR := Color("#5ec8ff")
const XP_OUTLINE_COLOR := Color("#14405a")
const HEAL_COLOR := Color("#ff5d73")
const HEAL_OUTLINE_COLOR := Color("#ffffff")

var player: Player
var heals := false  # true면 회복 아이템
var pulled := false  # 한 번 끌려가기 시작하면 범위를 벗어나도 계속 따라간다


func _physics_process(delta: float) -> void:
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	if not pulled and distance <= player.pickup_range:
		pulled = true
	if not pulled:
		return
	if distance <= Player.RADIUS:
		collected.emit()
		queue_free()
		return
	global_position += to_player / distance * PULL_SPEED * delta


func _draw() -> void:
	if heals:
		# 흰 테두리의 빨간 십자
		draw_rect(Rect2(-4, -10, 8, 20), HEAL_OUTLINE_COLOR)
		draw_rect(Rect2(-10, -4, 20, 8), HEAL_OUTLINE_COLOR)
		draw_rect(Rect2(-2, -8, 4, 16), HEAL_COLOR)
		draw_rect(Rect2(-8, -2, 16, 4), HEAL_COLOR)
		return
	var outline := PackedVector2Array([
		Vector2(0, -SIZE - 2), Vector2(SIZE + 2, 0), Vector2(0, SIZE + 2), Vector2(-SIZE - 2, 0)])
	var body := PackedVector2Array([Vector2(0, -SIZE), Vector2(SIZE, 0), Vector2(0, SIZE), Vector2(-SIZE, 0)])
	draw_colored_polygon(outline, XP_OUTLINE_COLOR)
	draw_colored_polygon(body, XP_COLOR)
