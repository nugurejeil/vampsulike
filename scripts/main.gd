extends Node2D
## 한 판의 흐름: 적 스폰, 경험치와 레벨업, 일시정지, 3분 타이머와 승패
## (PRD #2, P0-3~P0-8, P1-4, P1-5, P1-8).

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const SPAWN_MARGIN := 64.0  # 화면 모서리보다 이만큼 더 멀리서 나타난다
const LEVEL_UP_CHOICES := 3

var elapsed := 0.0
var spawn_budget := 0.0  # 쌓인 스폰 몫, 1이 넘을 때마다 한 마리
var kills := 0
var level := 1
var xp := 0
var pending_level_ups := 0  # 한 번에 여러 레벨이 오르면 차례로 고른다
var finished := false
var elite_spawned := false
var upgrade_levels := {}  # 강화 id → 현재 레벨
var weapons := {}  # 무기 id → Weapon

@onready var player: Player = $Player
@onready var enemies: Node2D = $Enemies
@onready var gems: Node2D = $Gems
@onready var projectiles: Node2D = $Projectiles
@onready var effects: Node2D = $Effects
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	player.health_changed.connect(hud.show_health)
	player.died.connect(_finish.bind(false))
	hud.upgrade_chosen.connect(_on_upgrade_chosen)
	hud.restart_requested.connect(_restart)
	hud.pause_requested.connect(_on_pause_requested)
	hud.resume_requested.connect(_on_resume_requested)
	hud.quit_requested.connect(get_tree().quit)
	Settings.load_once()
	_add_weapon("bolt")
	hud.show_health(player.hp, player.max_hp)
	hud.show_xp(xp, _xp_to_next_level(), level)
	hud.show_time(Balance.RUN_TIME)
	hud.show_kills(kills)


func _physics_process(delta: float) -> void:
	elapsed = minf(elapsed + delta, Balance.RUN_TIME)
	hud.show_time(Balance.RUN_TIME - elapsed)
	if elapsed >= Balance.RUN_TIME:
		_finish(true)
		return

	if not elite_spawned and elapsed >= Balance.ELITE_AT:
		elite_spawned = true
		_spawn_enemy("elite")  # 엘리트는 적 수 상한과 상관없이 나온다
		hud.show_banner("엘리트 등장!")

	var progress := elapsed / Balance.RUN_TIME
	spawn_budget += lerpf(Balance.SPAWN_RATE_START, Balance.SPAWN_RATE_END, progress) * delta
	while spawn_budget >= 1.0:
		spawn_budget -= 1.0
		if enemies.get_child_count() < Balance.MAX_ENEMIES:
			_spawn_enemy(_pick_enemy_kind())


func _pick_enemy_kind() -> String:
	var fast := Balance.FAST_WEIGHT if elapsed >= Balance.FAST_FROM else 0.0
	var tank := Balance.TANK_WEIGHT if elapsed >= Balance.TANK_FROM else 0.0
	var roll := randf() * (1.0 + fast + tank)
	if roll < fast:
		return "fast"
	if roll < fast + tank:
		return "tank"
	return "basic"


func _spawn_enemy(kind: String) -> void:
	# 화면 대각선 절반보다 먼 원 위에서 나타나므로 늘 화면 밖이다
	var radius := get_viewport_rect().size.length() / 2.0 + SPAWN_MARGIN
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(kind)
	enemy.position = player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * radius
	enemy.target = player
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.died.connect(_on_enemy_died.bind(enemy.radius, enemy.color))
	enemies.add_child(enemy)


func _on_enemy_damaged(amount: int, at: Vector2) -> void:
	var number := DamageNumber.new()
	number.amount = amount
	number.position = at
	effects.add_child(number)


func _on_enemy_died(at: Vector2, radius: float, color: Color) -> void:
	kills += 1
	hud.show_kills(kills)
	Sound.play("kill")
	# 효과와 보석은 Enemies 밖에 둔다. 안에 두면 적 수 상한에 섞인다
	var effect := DeathEffect.new()
	effect.position = at
	effect.radius = radius
	effect.color = color
	effects.add_child(effect)
	var gem := Gem.new()
	gem.position = at
	gem.player = player
	gem.collected.connect(_on_gem_collected)
	gems.add_child(gem)
	if randf() < Balance.HEAL_DROP_CHANCE:
		var heal := Gem.new()
		heal.heals = true
		heal.position = at + Vector2(12, 0)  # 보석과 겹치지 않게 살짝 옆에
		heal.player = player
		heal.collected.connect(player.heal.bind(Balance.HEAL_AMOUNT))
		gems.add_child(heal)


func _on_gem_collected() -> void:
	xp += Balance.XP_PER_ENEMY
	while xp >= _xp_to_next_level():
		xp -= _xp_to_next_level()
		level += 1
		pending_level_ups += 1
	hud.show_xp(xp, _xp_to_next_level(), level)
	if pending_level_ups > 0 and not get_tree().paused:
		_offer_level_up()


func _xp_to_next_level() -> int:
	return Balance.XP_BASE + level * Balance.XP_PER_LEVEL


func _offer_level_up() -> void:
	var options := Upgrades.pick(upgrade_levels, LEVEL_UP_CHOICES)
	if options.is_empty():
		pending_level_ups = 0  # 모든 강화가 최대 레벨이면 고를 것이 없다
		return
	get_tree().paused = true
	Sound.play("levelup")
	hud.show_level_up(options)


func _on_upgrade_chosen(id: String) -> void:
	var new_level: int = upgrade_levels.get(id, 0) + 1
	if id in Upgrades.WEAPONS:
		if new_level == 1:
			_add_weapon(id)
		else:
			upgrade_levels[id] = new_level
			(weapons[id] as Weapon).set_level(new_level)
	else:
		upgrade_levels[id] = new_level
		Upgrades.apply_passive(id, player)
	pending_level_ups -= 1
	if pending_level_ups > 0:
		_offer_level_up()
	else:
		get_tree().paused = false


func _add_weapon(id: String) -> void:
	var weapon := Upgrades.create_weapon(id)
	weapon.player = player
	weapon.projectile_parent = projectiles
	player.add_child(weapon)
	weapons[id] = weapon
	upgrade_levels[id] = 1


func _on_pause_requested() -> void:
	if finished or get_tree().paused:
		return
	get_tree().paused = true
	hud.show_pause_menu()


func _on_resume_requested() -> void:
	hud.hide_pause_menu()
	get_tree().paused = false


func _finish(won: bool) -> void:
	if finished:
		return
	finished = true
	get_tree().paused = true
	var new_record := Records.submit(elapsed, kills)
	hud.show_result(won, elapsed, kills, level, new_record)


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
