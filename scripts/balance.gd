class_name Balance
## PRD #7 밸런스 값. 플레이해 보며 조정할 때는 이 파일만 고친다.
## PRD #7에 없는 P1 값(무기 레벨, 적 종류)은 처음 정한 값이라 테스트하며 조정한다.

const RUN_TIME := 180.0  # 초, 3:00 버티면 승리 (PRD #2)

const PLAYER_MAX_HP := 100
const PLAYER_SPEED := 200.0  # px/초
const INVULNERABLE_TIME := 0.5  # 초, 피격 후 무적

const PROJECTILE_SPEED := 400.0  # px/초

const SPAWN_RATE_START := 1.0  # 0:00에 초당 마리 수
const SPAWN_RATE_END := 10.0  # 3:00에 초당 마리 수
const MAX_ENEMIES := 150  # 동시에 있을 수 있는 적 (엘리트는 예외)

const XP_PER_ENEMY := 1
const XP_BASE := 5  # 레벨업 필요 경험치 = XP_BASE + 현재 레벨 × XP_PER_LEVEL
const XP_PER_LEVEL := 5
const PICKUP_RANGE := 60.0  # px, 이 안의 보석은 플레이어에게 끌려온다

const HEAL_DROP_CHANCE := 0.02  # 적 1마리가 회복 아이템을 떨어뜨릴 확률 (PRD P2-1)
const HEAL_AMOUNT := 20

# 적 종류 (PRD P1-4, P1-5). basic은 PRD #7 값 그대로다
const ENEMY_TYPES := {
	"basic": {"hp": 10, "speed": 120.0, "radius": 14.0, "damage": 10, "color": Color("#c9443c")},
	"fast": {"hp": 5, "speed": 230.0, "radius": 10.0, "damage": 8, "color": Color("#e8913a")},
	"tank": {"hp": 40, "speed": 80.0, "radius": 20.0, "damage": 15, "color": Color("#7d4fb3")},
	"elite": {"hp": 400, "speed": 70.0, "radius": 32.0, "damage": 25, "color": Color("#8b1e2d")},
}
const FAST_FROM := 40.0  # 초, 이때부터 빠른 적이 섞인다
const FAST_WEIGHT := 0.35  # 기본 적 1에 대한 등장 비율
const TANK_FROM := 80.0
const TANK_WEIGHT := 0.2
const ELITE_AT := 150.0  # 2:30, 종료 30초 전 (PRD P1-5)

# 무기 레벨별 능력치 (PRD P1-1, P1-2). 배열의 n번째가 레벨 n+1이다
const BOLT_LEVELS := [  # 마력탄(기본 무기 1레벨은 PRD #7 값)
	{"interval": 1.0, "damage": 10, "count": 1},
	{"interval": 1.0, "damage": 10, "count": 2},
	{"interval": 1.0, "damage": 15, "count": 2},
	{"interval": 1.0, "damage": 15, "count": 3},
	{"interval": 0.75, "damage": 15, "count": 3},
]
const ORB_LEVELS := [  # 회전 구슬
	{"count": 2, "damage": 8, "radius": 70.0},
	{"count": 3, "damage": 8, "radius": 70.0},
	{"count": 3, "damage": 12, "radius": 70.0},
	{"count": 4, "damage": 12, "radius": 70.0},
	{"count": 5, "damage": 12, "radius": 90.0},
]
const ORB_SPEED := 3.0  # 라디안/초
const ORB_HIT_INTERVAL := 0.4  # 초, 같은 적을 다시 때리기까지
const AURA_LEVELS := [  # 가시 오라
	{"radius": 70.0, "damage": 5, "interval": 0.5},
	{"radius": 85.0, "damage": 5, "interval": 0.5},
	{"radius": 85.0, "damage": 8, "interval": 0.5},
	{"radius": 100.0, "damage": 8, "interval": 0.5},
	{"radius": 100.0, "damage": 12, "interval": 0.4},
]
const LANCE_LEVELS := [  # 관통 창
	{"interval": 1.5, "damage": 15, "pierce": 3, "count": 1},
	{"interval": 1.5, "damage": 15, "pierce": 5, "count": 1},
	{"interval": 1.5, "damage": 20, "pierce": 5, "count": 1},
	{"interval": 1.1, "damage": 20, "pierce": 5, "count": 1},
	{"interval": 1.1, "damage": 20, "pierce": 5, "count": 2},
]
const LANCE_SPEED := 500.0  # px/초

# 패시브 강화 (PRD P1-3). 레벨마다 한 번씩 적용된다
const UPGRADE_MOVE_SPEED := 1.1  # 이동 속도에 곱한다
const UPGRADE_MAX_HP := 20
const UPGRADE_PICKUP_RANGE := 1.3  # 흡수 범위에 곱한다
const UPGRADE_COOLDOWN := 0.9  # 모든 무기의 공격 간격에 곱한다
