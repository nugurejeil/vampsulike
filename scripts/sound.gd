class_name Sound
extends Node
## 효과음 재생 (PRD P1-7). 어디서나 Sound.play("kill")처럼 부른다.
## 처음 부를 때 루트에 재생용 노드를 하나 만들고, 다시 시작해도 그대로 쓴다.
## 소리 파일은 tools/make_sounds.py로 만든다.

const SOUNDS := {
	"attack": preload("res://assets/sounds/attack.wav"),
	"kill": preload("res://assets/sounds/kill.wav"),
	"hurt": preload("res://assets/sounds/hurt.wav"),
	"levelup": preload("res://assets/sounds/levelup.wav"),
}
const VOICES := 8  # 동시에 날 수 있는 효과음 수
const MIN_GAP := 0.05  # 초, 같은 소리가 한꺼번에 몰리면 시끄러워서 간격을 둔다
const VOLUME_DB := -8.0

static var _instance: Sound

var players: Array[AudioStreamPlayer] = []
var last_played := {}


static func play(sound_name: String) -> void:
	if not is_instance_valid(_instance):
		_instance = Sound.new()
		(Engine.get_main_loop() as SceneTree).root.add_child(_instance)
	_instance._play(sound_name)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # 레벨업 화면처럼 멈춘 동안에도 소리가 난다
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.volume_db = VOLUME_DB
		player.bus = &"SFX"
		add_child(player)
		players.append(player)


func _play(sound_name: String) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_played.get(sound_name, -INF) < MIN_GAP:
		return
	last_played[sound_name] = now
	for player in players:
		if not player.playing:
			player.stream = SOUNDS[sound_name]
			player.play()
			return
