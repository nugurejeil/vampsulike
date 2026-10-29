class_name Settings
## 볼륨 설정 (PRD P2-5). 0~1 값을 Music, SFX 오디오 버스에 적용하고 이 컴퓨터에 저장한다.
## 버스 구성은 default_bus_layout.tres에 있다.

const PATH := "user://settings.cfg"
const DEFAULT_VOLUME := 0.8

static var music_volume := DEFAULT_VOLUME
static var sfx_volume := DEFAULT_VOLUME
static var _loaded := false


static func load_once() -> void:
	if _loaded:
		return
	_loaded = true
	var config := ConfigFile.new()
	if config.load(PATH) == OK:
		music_volume = config.get_value("volume", "music", DEFAULT_VOLUME)
		sfx_volume = config.get_value("volume", "sfx", DEFAULT_VOLUME)
	_apply("Music", music_volume)
	_apply("SFX", sfx_volume)


static func set_music_volume(value: float) -> void:
	music_volume = value
	_apply("Music", value)
	_save()


static func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	_apply("SFX", value)
	_save()


static func _apply(bus_name: String, value: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value <= 0.0)


static func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("volume", "music", music_volume)
	config.set_value("volume", "sfx", sfx_volume)
	config.save(PATH)
