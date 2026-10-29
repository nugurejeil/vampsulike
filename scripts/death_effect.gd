class_name DeathEffect
extends Node2D
## 적 처치 효과 (TODO 추가-4): 적이 있던 자리에서 몸이 줄어들고 고리가 퍼지며 사라진다.

const DURATION := 0.3  # 초
const RING_COLOR := Color("#ffe8b0")

var radius := 14.0  # 처치된 적의 크기와 색
var color := Color.WHITE
var progress := 0.0  # 0에서 시작해 DURATION 동안 1이 된다


func _ready() -> void:
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION)
	tween.tween_callback(queue_free)


func _set_progress(value: float) -> void:
	progress = value
	queue_redraw()


func _draw() -> void:
	var fade := 1.0 - progress
	draw_circle(Vector2.ZERO, radius * fade, Color(color, fade))
	draw_arc(Vector2.ZERO, lerpf(radius * 0.85, radius * 2.4, progress), 0.0, TAU, 32, Color(RING_COLOR, fade), 1.0 + 4.0 * fade)
