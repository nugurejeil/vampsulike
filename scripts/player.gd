class_name Player
extends CharacterBody2D
## 플레이어. 입력은 이동뿐이다 (PRD #3, #5). 무기는 자식으로 붙어 함께 움직인다.

signal health_changed(hp: int, max_hp: int)
signal died

const RADIUS := 16.0  # 충돌 원 반지름. 그림은 Sprite가 그린다
const BLINK_PERIOD := 0.12  # 초, 무적 동안 깜빡이는 주기 (PRD P1-6)
const SHAKE_TIME := 0.2  # 초, 맞으면 화면이 흔들린다 (PRD P1-6)
const SHAKE_STRENGTH := 6.0  # px

var max_hp := Balance.PLAYER_MAX_HP
var hp := max_hp
var speed := Balance.PLAYER_SPEED
var pickup_range := Balance.PICKUP_RANGE
var cooldown_scale := 1.0  # 모든 무기의 공격 간격에 곱한다 (패시브 "빠른 손")
var facing := Vector2.RIGHT  # 마지막으로 움직인 방향, 관통 창이 이쪽으로 날아간다
var invulnerable := 0.0  # 남은 무적 시간 (PRD P0-4)
var shake := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var camera: Camera2D = $Camera2D


func _physics_process(delta: float) -> void:
	# get_vector는 길이를 1로 맞춰 주므로 대각선도 같은 속도가 된다
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		facing = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	# 시트의 그림은 오른쪽을 본다. 위아래로만 움직일 때는 보던 방향을 유지한다
	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0
	sprite.play(&"walk" if direction != Vector2.ZERO else &"idle")

	invulnerable = maxf(invulnerable - delta, 0.0)
	if invulnerable == 0.0 and hp > 0:
		# 여러 적이 닿아 있으면 가장 아픈 한 번만 맞는다
		var damage := 0
		for area in hurtbox.get_overlapping_areas():
			if area is Enemy:
				damage = maxi(damage, (area as Enemy).contact_damage)
		if damage > 0:
			_take_damage(damage)

	# 그림만 깜빡인다. 같은 자식인 무기는 깜빡이지 않는다
	sprite.modulate.a = 0.35 if invulnerable > 0.0 and fmod(invulnerable, BLINK_PERIOD) > BLINK_PERIOD / 2.0 else 1.0
	shake = maxf(shake - delta, 0.0)
	camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * SHAKE_STRENGTH * shake / SHAKE_TIME


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)


func increase_max_hp(amount: int) -> void:
	max_hp += amount
	hp += amount
	health_changed.emit(hp, max_hp)


func _take_damage(amount: int) -> void:
	hp = maxi(hp - amount, 0)
	invulnerable = Balance.INVULNERABLE_TIME
	shake = SHAKE_TIME
	Sound.play("hurt")
	health_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
