class_name DamageNumber
extends Node2D
## 데미지 숫자 (PRD P1-6): 맞은 자리에서 위로 떠오르며 사라진다.

const FONT := preload("res://assets/fonts/noto_sans_kr_medium.tres")
const DURATION := 0.6  # 초
const RISE := 28.0  # px
const FONT_SIZE := 18
const COLOR := Color("#fff4c2")
const OUTLINE_COLOR := Color("#1a1a1a")

var amount := 0
var progress := 0.0  # 0에서 시작해 DURATION 동안 1이 된다


func _ready() -> void:
	# 같은 자리에서 여러 번 맞아도 숫자가 겹치지 않게 조금씩 흩뜨린다
	position += Vector2(randf_range(-8, 8), randf_range(-14, -6))
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION)
	tween.tween_callback(queue_free)


func _set_progress(value: float) -> void:
	progress = value
	queue_redraw()


func _draw() -> void:
	var text := str(amount)
	var offset := Vector2(-FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x / 2.0, -RISE * progress)
	var alpha := 1.0 - progress * progress
	draw_string_outline(FONT, offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, 4, Color(OUTLINE_COLOR, alpha))
	draw_string(FONT, offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color(COLOR, alpha))
