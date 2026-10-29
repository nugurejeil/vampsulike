class_name OrbWeapon
extends Weapon
## 회전 구슬 (PRD P1-1): 구슬이 플레이어 주위를 돌며 닿은 적을 때린다.

const ORB_SIZE := 9.0
const COLOR := Color("#b48cff")
const OUTLINE_COLOR := Color("#2e1a4f")
const MAX_TRACKED := 500  # 기억해 둔 적이 이보다 많으면 비운다

var angle := 0.0
var clock := 0.0
var orbs: Array[Area2D] = []
var last_hit := {}  # 적 instance id → 마지막으로 맞은 시각. 구슬 여러 개가 겹쳐도 적마다 간격을 둔다


func _ready() -> void:
	_build_orbs()


func set_level(value: int) -> void:
	super.set_level(value)
	if is_inside_tree():
		_build_orbs()


func _physics_process(delta: float) -> void:
	clock += delta
	angle = wrapf(angle + Balance.ORB_SPEED / player.cooldown_scale * delta, 0.0, TAU)
	_place_orbs()
	var damage: int = _stats().damage
	for orb in orbs:
		for area in orb.get_overlapping_areas():
			if not area is Enemy:
				continue
			var id := area.get_instance_id()
			if clock - last_hit.get(id, -INF) >= Balance.ORB_HIT_INTERVAL:
				last_hit[id] = clock
				(area as Enemy).take_damage(damage)
	if last_hit.size() > MAX_TRACKED:
		last_hit.clear()
	queue_redraw()


func _stats() -> Dictionary:
	return Balance.ORB_LEVELS[level - 1]


func _build_orbs() -> void:
	for orb in orbs:
		orb.queue_free()
	orbs.clear()
	for i in _stats().count:
		var orb := Area2D.new()
		orb.collision_layer = 0
		orb.collision_mask = 2
		orb.monitorable = false
		var shape := CollisionShape2D.new()
		shape.shape = CircleShape2D.new()
		(shape.shape as CircleShape2D).radius = ORB_SIZE
		orb.add_child(shape)
		add_child(orb)
		orbs.append(orb)
	_place_orbs()


func _place_orbs() -> void:
	var radius: float = _stats().radius
	for i in orbs.size():
		orbs[i].position = Vector2.RIGHT.rotated(angle + TAU * i / orbs.size()) * radius


func _draw() -> void:
	for orb in orbs:
		draw_circle(orb.position, ORB_SIZE + 2.0, OUTLINE_COLOR)
		draw_circle(orb.position, ORB_SIZE, COLOR)
