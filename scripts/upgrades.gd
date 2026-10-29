class_name Upgrades
## 레벨업 강화: 무기 4종(PRD P1-1, P1-2)과 패시브 4종(PRD P1-3). 모두 최대 5레벨이다.

const MAX_LEVEL := 5
const WEAPONS := ["bolt", "orb", "aura", "lance"]

# levels[n]은 n레벨에서 n+1레벨이 될 때의 설명이다. 패시브는 레벨마다 같다
const INFO := {
	"bolt": {"title": "마력탄", "levels": [
		"가장 가까운 적에게 마력탄을 쏜다", "한 번에 2발", "데미지 10 → 15", "한 번에 3발", "발사 간격 25% 감소"]},
	"orb": {"title": "회전 구슬", "levels": [
		"구슬 2개가 주위를 돌며 닿은 적을 때린다", "구슬 3개", "데미지 8 → 12", "구슬 4개", "구슬 5개, 더 넓게 돈다"]},
	"aura": {"title": "가시 오라", "levels": [
		"주변 적 모두에게 0.5초마다 데미지", "범위 증가", "데미지 5 → 8", "범위 증가", "데미지 8 → 12, 더 자주"]},
	"lance": {"title": "관통 창", "levels": [
		"이동 방향으로 적 3마리를 꿰뚫는 창", "5마리까지 꿰뚫는다", "데미지 15 → 20", "발사 간격 감소", "한 번에 2개"]},
	"move_speed": {"title": "가벼운 발", "levels": ["이동 속도 10% 증가"]},
	"max_hp": {"title": "튼튼한 몸", "levels": ["최대 체력 +20, 늘어난 만큼 회복"]},
	"pickup": {"title": "자석", "levels": ["보석 흡수 범위 30% 증가"]},
	"cooldown": {"title": "빠른 손", "levels": ["모든 무기 공격 속도 10% 증가"]},
}


## 아직 최대 레벨이 아닌 강화 중에서 count개를 무작위로 고른다.
static func pick(levels: Dictionary, count: int) -> Array:
	var options := []
	for id: String in INFO:
		var current: int = levels.get(id, 0)
		if current >= MAX_LEVEL:
			continue
		var descriptions: Array = INFO[id].levels
		var tag := "Lv %d → %d" % [current, current + 1]
		if current == 0:
			tag = "새 무기" if id in WEAPONS else "새 패시브"
		options.append({
			"id": id,
			"tag": tag,
			"title": INFO[id].title,
			"description": descriptions[mini(current, descriptions.size() - 1)],
		})
	options.shuffle()
	return options.slice(0, count)


static func create_weapon(id: String) -> Weapon:
	match id:
		"bolt":
			return BoltWeapon.new()
		"orb":
			return OrbWeapon.new()
		"aura":
			return AuraWeapon.new()
		"lance":
			return LanceWeapon.new()
	push_error("알 수 없는 무기: %s" % id)
	return null


static func apply_passive(id: String, player: Player) -> void:
	match id:
		"move_speed":
			player.speed *= Balance.UPGRADE_MOVE_SPEED
		"max_hp":
			player.increase_max_hp(Balance.UPGRADE_MAX_HP)
		"pickup":
			player.pickup_range *= Balance.UPGRADE_PICKUP_RANGE
		"cooldown":
			player.cooldown_scale *= Balance.UPGRADE_COOLDOWN
