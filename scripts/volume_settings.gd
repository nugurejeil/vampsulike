extends GridContainer
## 음악·효과음 볼륨 슬라이더 (PRD P2-5). 일시정지 메뉴와 타이틀 화면에서 같이 쓴다.

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider


func _ready() -> void:
	Settings.load_once()
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	music_slider.value_changed.connect(Settings.set_music_volume)
	sfx_slider.value_changed.connect(Settings.set_sfx_volume)
	# 놓을 때 효과음을 한 번 내서 크기를 들어 볼 수 있게 한다
	sfx_slider.drag_ended.connect(func(_changed: bool) -> void: Sound.play("kill"))
