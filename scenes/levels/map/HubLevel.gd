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
	set_camera_limit(-600, 190, 20, 1500)
	for node in get_children():
		if node is MapTrigger:
			node.connect("body_entered", self, "_on_MapTrigger_entered")
			node.connect("body_exited", self, "_on_MapTrigger_exited")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("action"):
		match current_trigger:
			"shop": on_shop_interact()
			"competition": on_competition_interact()
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
	can_control_player = false
	camera_target = $Shop/CameraFocus
	$CanvasLayer/MenuShop.open()

func on_competition_interact() -> void:
	show_interact(false)
	current_state = HUB_STATE.MENU
	can_control_player = false
	camera_target = $Competition/CameraFocus

func _on_MenuShop_close_menu():
	show_interact(true)
	current_state = HUB_STATE.PLAYING
	can_control_player = true
	camera_target = $Player
