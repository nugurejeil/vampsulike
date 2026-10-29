extends Node2D
## 끝없이 이어지는 평원 (PRD #6). 카메라 주변 칸만 매 프레임 그린다.

const TILE := 64.0
const GRASS_A := Color("#56813f")
const GRASS_B := Color("#517a3b")
const TUFT_COLOR := Color("#3f6430")

@export var target: Node2D


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var center := target.global_position if target else Vector2.ZERO
	var half := get_viewport_rect().size / 2.0 + Vector2(TILE, TILE)
	var first := ((center - half) / TILE).floor()
	var last := ((center + half) / TILE).ceil()
	for x in range(int(first.x), int(last.x)):
		for y in range(int(first.y), int(last.y)):
			var pos := Vector2(x, y) * TILE
			draw_rect(Rect2(pos, Vector2(TILE, TILE)), GRASS_A if (x + y) % 2 == 0 else GRASS_B)
			# 칸마다 늘 같은 자리에 풀 무더기를 그려서 움직임이 눈에 보이게 한다
			var h := hash(Vector2i(x, y))
			if h % 3 == 0:
				var offset := Vector2(8 + h % 48, 8 + (h >> 8) % 48)
				draw_circle(pos + offset, 3.0, TUFT_COLOR)
				draw_circle(pos + offset + Vector2(5, 2), 2.0, TUFT_COLOR)
