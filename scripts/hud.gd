extends CanvasLayer
## 화면 위에 고정되는 정보와 메뉴 (PRD P0-6, P0-7, P0-8, P1-8).
## 게임이 멈춘 동안에도 클릭과 키를 받아야 하므로 process_mode는 ALWAYS다.

signal upgrade_chosen(id: String)
signal restart_requested
signal pause_requested
signal resume_requested
signal quit_requested

const BANNER_TIME := 2.0  # 초

var card_ids: Array[String] = []
var highlighted := -1  # 게임패드로 고르고 있는 카드, -1이면 없음 (PRD P2-4)
var card_style: StyleBox
var card_highlight_style: StyleBox

@onready var xp_bar: ProgressBar = $XpBar
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/Label
@onready var level_label: Label = $LevelLabel
@onready var timer_label: Label = $TimerLabel
@onready var kill_label: Label = $KillLabel
@onready var banner: Label = $Banner
@onready var level_up: Control = $LevelUp
@onready var cards: Array[Button] = [
	$LevelUp/Center/Box/Cards/Card1, $LevelUp/Center/Box/Cards/Card2, $LevelUp/Center/Box/Cards/Card3]
@onready var pause_menu: Control = $PauseMenu
@onready var result: Control = $Result
@onready var result_title: Label = $Result/Center/Box/Title
@onready var result_stats: Label = $Result/Center/Box/Stats
@onready var result_record: Label = $Result/Center/Box/Record


func _ready() -> void:
	for i in cards.size():
		cards[i].pressed.connect(_on_card_pressed.bind(i))
	card_style = cards[0].get_theme_stylebox("normal")
	card_highlight_style = cards[0].get_theme_stylebox("hover")
	$PauseMenu/Center/Box/Resume.pressed.connect(resume_requested.emit)
	$PauseMenu/Center/Box/Restart.pressed.connect(restart_requested.emit)
	$PauseMenu/Center/Box/Quit.pressed.connect(quit_requested.emit)


func show_health(hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_label.text = "체력 %d / %d" % [hp, max_hp]


func show_xp(xp: int, needed: int, level: int) -> void:
	xp_bar.max_value = needed
	xp_bar.value = xp
	level_label.text = "Lv %d" % level


func show_time(remaining: float) -> void:
	timer_label.text = _format_time(ceili(remaining))


func show_kills(kills: int) -> void:
	kill_label.text = "처치 %d" % kills


func show_banner(text: String) -> void:
	banner.text = text
	banner.modulate.a = 1.0
	banner.show()
	var tween := create_tween()
	tween.tween_interval(BANNER_TIME * 0.75)
	tween.tween_property(banner, "modulate:a", 0.0, BANNER_TIME * 0.25)
	tween.tween_callback(banner.hide)


## options는 Upgrades.pick의 결과다. 고를 것이 3개보다 적으면 남는 카드는 숨긴다.
func show_level_up(options: Array) -> void:
	card_ids.clear()
	for i in cards.size():
		var card := cards[i]
		card.visible = i < options.size()
		if not card.visible:
			continue
		var option: Dictionary = options[i]
		card_ids.append(option.id)
		(card.get_node("Box/Tag") as Label).text = option.tag
		(card.get_node("Box/Title") as Label).text = option.title
		(card.get_node("Box/Desc") as Label).text = option.description
	# 게임패드가 연결돼 있으면 첫 카드를 미리 가리켜 둔다
	_highlight(0 if not Input.get_connected_joypads().is_empty() else -1)
	level_up.show()


func show_pause_menu() -> void:
	pause_menu.show()


func hide_pause_menu() -> void:
	pause_menu.hide()


func show_result(won: bool, survived: float, kills: int, level: int, new_record: bool) -> void:
	pause_menu.hide()
	result_title.text = "승리!" if won else "패배"
	result_stats.text = "생존 시간 %s\n처치 %d\n도달 레벨 %d" % [_format_time(floori(survived)), kills, level]
	result_record.text = "%s최고 기록  생존 %s · 처치 %d" % [
		"새 기록!  " if new_record else "", _format_time(floori(Records.best_time)), Records.best_kills]
	result.show()


func _unhandled_input(event: InputEvent) -> void:
	if result.visible:
		# 결과 화면에서만 Space·Enter(게임패드 A)로 다시 시작한다 (PRD #3, P2-4)
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("pad_accept"):
			get_viewport().set_input_as_handled()
			restart_requested.emit()
	elif level_up.visible:
		# 강화는 마우스나 게임패드로만 고른다. pad_* 액션에는 키보드가 묶여 있지 않다 (PRD #8, P2-4)
		var step := 0
		if event.is_action_pressed("pad_left"):
			step = -1
		elif event.is_action_pressed("pad_right"):
			step = 1
		if step != 0:
			get_viewport().set_input_as_handled()
			_highlight(0 if highlighted < 0 else wrapi(highlighted + step, 0, card_ids.size()))
		elif event.is_action_pressed("pad_accept"):
			get_viewport().set_input_as_handled()
			if highlighted < 0:
				_highlight(0)
			else:
				_on_card_pressed(highlighted)
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("pad_pause"):
		# Esc(게임패드 Start)로 일시정지하고 다시 누르면 재개한다 (PRD P1-8)
		get_viewport().set_input_as_handled()
		if pause_menu.visible:
			resume_requested.emit()
		else:
			pause_requested.emit()


func _highlight(index: int) -> void:
	highlighted = index
	for i in cards.size():
		cards[i].add_theme_stylebox_override("normal", card_highlight_style if i == index else card_style)


func _on_card_pressed(index: int) -> void:
	level_up.hide()
	upgrade_chosen.emit(card_ids[index])


func _format_time(seconds: int) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), seconds % 60]
