class_name Weapon
extends Node2D
## 모든 무기의 공통 부분 (PRD P1-1, P1-2). 플레이어의 자식이라 함께 움직이고,
## 날아가는 투사체는 플레이어를 따라가지 않도록 projectile_parent에 둔다.

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")

var player: Player
var projectile_parent: Node2D
var level := 1


func set_level(value: int) -> void:
	level = value


func nearest_enemies(count: int) -> Array[Node2D]:
	var enemies: Array[Node2D] = []
	enemies.assign(get_tree().get_nodes_in_group("enemies"))
	var origin := player.global_position
	enemies.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))
	return enemies.slice(0, count)
