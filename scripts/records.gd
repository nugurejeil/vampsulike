class_name Records
## 최고 기록: 최장 생존 시간과 최다 처치 수를 이 컴퓨터에 저장한다 (PRD P2-2).

const PATH := "user://records.cfg"

static var best_time := 0.0  # 초
static var best_kills := 0
static var _loaded := false


static func load_once() -> void:
	if _loaded:
		return
	_loaded = true
	var config := ConfigFile.new()
	if config.load(PATH) == OK:
		best_time = config.get_value("best", "time", 0.0)
		best_kills = config.get_value("best", "kills", 0)


## 이번 판 결과를 반영하고, 기록을 깼으면 true를 돌려준다.
static func submit(survived: float, kills: int) -> bool:
	load_once()
	var improved := false
	if survived > best_time:
		best_time = survived
		improved = true
	if kills > best_kills:
		best_kills = kills
		improved = true
	if improved:
		var config := ConfigFile.new()
		config.set_value("best", "time", best_time)
		config.set_value("best", "kills", best_kills)
		config.save(PATH)
	return improved
