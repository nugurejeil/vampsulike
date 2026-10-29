class_name LanceWeapon
extends Weapon
## 관통 창 (PRD P1-1): 이동 방향으로 여러 적을 꿰뚫는 창을 던진다.

const SPREAD := 0.2  # 라디안, 여러 개를 던질 때 사이 각도
const RADIUS := 7.0
const LENGTH := 28.0
const COLOR := Color("#9ff3ff")

var cooldown := 0.0


func _physics_process(delta: float) -> void:
	cooldown -= delta
	if cooldown > 0.0:
		return
	var stats: Dictionary = Balance.LANCE_LEVELS[level - 1]
	cooldown = stats.interval * player.cooldown_scale
	var count: int = stats.count
	for i in count:
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()
		projectile.position = player.global_position
		projectile.direction = player.facing.rotated((i - (count - 1) / 2.0) * SPREAD)
		projectile.speed = Balance.LANCE_SPEED
		projectile.damage = stats.damage
		projectile.pierce = stats.pierce
		projectile.radius = RADIUS
		projectile.length = LENGTH
		projectile.color = COLOR
		projectile_parent.add_child(projectile)
	Sound.play("attack")
