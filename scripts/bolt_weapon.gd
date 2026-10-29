class_name BoltWeapon
extends Weapon
## 마력탄, 기본 무기: 가장 가까운 적부터 한 발씩 쏜다 (PRD P0-2).

const COLOR := Color("#ffe066")

var cooldown := 0.0


func _physics_process(delta: float) -> void:
	cooldown -= delta
	if cooldown > 0.0:
		return
	var stats: Dictionary = Balance.BOLT_LEVELS[level - 1]
	var targets := nearest_enemies(stats.count)
	if targets.is_empty():
		return  # 쏠 적이 없으면 장전된 채로 기다린다
	cooldown = stats.interval * player.cooldown_scale
	for target in targets:
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()
		projectile.position = player.global_position
		projectile.direction = player.global_position.direction_to(target.global_position)
		projectile.damage = stats.damage
		projectile.color = COLOR
		projectile_parent.add_child(projectile)
	Sound.play("attack")
