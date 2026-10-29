extends Control
## 타이틀 화면 (PRD P2-3): 게임 이름, 시작, 조작 안내, 최고 기록, 볼륨 설정.

const GAME_SCENE := "res://scenes/main.tscn"

@onready var record_label: Label = $Center/Box/Record


func _ready() -> void:
	Settings.load_once()
	Records.load_once()
	$Center/Box/Start.pressed.connect(_start)
	if Records.best_time > 0.0:
		var seconds := floori(Records.best_time)
		record_label.text = "최고 기록  생존 %d:%02d · 처치 %d" % [floori(seconds / 60.0), seconds % 60, Records.best_kills]
	else:
		record_label.text = "아직 기록이 없어요"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("pad_accept"):
		get_viewport().set_input_as_handled()
		_start()


func _start() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
