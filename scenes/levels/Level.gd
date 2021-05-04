class_name Level extends Node2D

# warning-ignore:unused_signal
signal fadein_end
# warning-ignore:unused_signal
signal fadeout_end

export(bool) var can_use_tools = false
onready var camera := $Camera2D
onready var player := $Player as Player
onready var camera_target := $Player
onready var start = $Start
#onready var quit_menu = $CanvasLayer/UIQuitGame
onready var quit_dialog = $CanvasLayer/QuitDialog

var menus: Array = []

func _ready():
#	quit_menu.hide()
	quit_dialog.close()
	$CanvasLayer/ColorRect.color.a = 1.0
	camera.current = true
	player.global_position = $Start.global_position
	fade(true)

func set_player_control(control: bool) -> void:
	player.can_move = control

func set_camera_limit(top: int, bottom: int, left: int, right: int) -> void:
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom

func _process(delta: float) -> void:
	update_camera()
	if player.can_move:
		player.process(delta)

	if len(menus) == 0:
		if Input.is_action_just_pressed("ui_cancel"):
			if len(menus) == 0:
				if GameAutoload.DEBUG:
					get_tree().quit()
				else:
					open_menu(quit_dialog)
#			else:
#				menus[len(menus) - 1].cancel_pressed()
	else:
		update_menu(delta)

func update_menu(delta: float) -> void:
	var nbr_menus = len(menus)
	if nbr_menus == 0:
		return
	menus[nbr_menus - 1].process(delta)

func update_camera() -> void:
	camera.position = camera_target.global_position

func fade(fadein: bool) -> void:
	$CanvasLayer/AnimationPlayer.play("fade-in" if fadein else "fade-out")

func _on_UIQuitGame_quit_game():
	get_tree().quit()

func close_menu() -> void:
	if len(menus) == 0:
		return
	var menu = menus.pop_back()
	menu.close()
	if len(menus) == 0:
		set_player_control(true)
		camera_target = $Player

func open_menu(menu) -> void:
	menu.open()
	menus.push_back(menu)
	set_player_control(false)

func _on_UIQuitGame_close_window():
	close_menu()


func _on_QuitDialog_quit_game():
	get_tree().quit()

func _on_QuitDialog_dialog_closed(_id):
	close_menu()
