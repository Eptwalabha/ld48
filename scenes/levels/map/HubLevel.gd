extends Level

onready var context_label: Label = $CanvasLayer/ContextLabel
var current_trigger : String = ""

enum HUB_STATE {
	PLAYING,
	MENU,
	CUTSCENE
}

var current_state: int = HUB_STATE.PLAYING

func _ready() -> void:
	context_label.hide()
	set_camera_limit(-10000, 190, 20, 1500)
	for node in get_children():
		if node is MapTrigger:
			node.connect("body_entered", self, "_on_MapTrigger_entered")
			node.connect("body_exited", self, "_on_MapTrigger_exited")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("action") and current_state == HUB_STATE.PLAYING:
		match current_trigger:
			"shop": on_shop_interact()
			"contest": on_contest_interact()
			_: pass

func show_interact(show: bool) -> void:
	context_label.visible = show

func _on_MapTrigger_entered(trigger: MapTrigger, _body):
	if trigger.active:
		show_interact(true)
		current_trigger = trigger.trigger_name

func _on_MapTrigger_exited(_trigger: MapTrigger, _body):
	show_interact(false)
	current_trigger = ""

func on_shop_interact() -> void:
	show_interact(false)
	current_state = HUB_STATE.MENU
	set_player_control(false)
	camera_target = $Shop/CameraFocus
	$CanvasLayer/MenuShop.open()
	open_menu($CanvasLayer/MenuShop)

func on_contest_interact() -> void:
	show_interact(false)
	current_state = HUB_STATE.MENU
	set_player_control(false)
	camera_target = $Contest/CameraFocus
	$CanvasLayer/MenuContest.open()
	open_menu($CanvasLayer/MenuContest)

func _on_MenuShop_close_menu():
	show_interact(true)
	current_state = HUB_STATE.PLAYING
	close_menu()

func _on_MenuContest_close_menu():
	show_interact(true)
	current_state = HUB_STATE.PLAYING
	close_menu()

func _on_MenuContest_enter_contest(id):
	if GameAutoload.can_contest(id):
		$CanvasLayer/MenuContest.close()
		GameAutoload.set_current_contest(id)
		fade(false)
		yield(self, "fadeout_end")
		var _osef = get_tree().change_scene("res://scenes/levels/map/ContestLevel.tscn")


func _on_MenuShop_update_player_equipment():
	$Player.initialize_tools()
