class_name UITool extends Control

signal tool_clicked(tool_type)

onready var shovel_btn = $MarginContainer/HBoxContainer/Shovel
onready var bucket_btn = $MarginContainer/HBoxContainer/Bucket
onready var explosive_btn = $MarginContainer/HBoxContainer/Explosive
onready var explosive_counter = $MarginContainer/HBoxContainer/Explosive/Label

var current_tool: int = -1

func set_button(shovel: bool, bucket: bool, explosive: bool) -> void:
	shovel_btn.visible = shovel
	bucket_btn.visible = bucket
	var nbr_grenade = GameAutoload.player_tools["explosive"]
	explosive_btn.visible = explosive and nbr_grenade > 0
	explosive_counter.text = str(nbr_grenade)

func set_bucket_fullness(is_full: bool) -> void:
	var a = bucket_btn.modulate.a
	if is_full:
		bucket_btn.modulate = Color.orangered
	else:
		bucket_btn.modulate = Color.white
	bucket_btn.modulate.a = a

func set_current(current: int) -> void:
	current_tool = current
	highlight_btn(shovel_btn, current == GameAutoload.TOOL_TYPE.SHOVEL)
	highlight_btn(bucket_btn, current == GameAutoload.TOOL_TYPE.BUCKET)
	highlight_btn(explosive_btn, current == GameAutoload.TOOL_TYPE.EXPLOSIVE)

func update_grenade_count() -> void:
	var nbr_grenade = GameAutoload.player_tools["explosive"]
	explosive_btn.visible = nbr_grenade > 0
	explosive_counter.text = str(nbr_grenade)

func highlight_btn(btn: Control, highlight: bool) -> void:
	btn.get_node("Logo").rect_scale = Vector2(0.9, 0.9) if highlight else Vector2(0.7, 0.7)
	btn.modulate.a = 1.0 if highlight else .3

func _on_Shovel_pressed():
	emit_signal("tool_clicked", GameAutoload.TOOL_TYPE.SHOVEL)

func _on_Bucket_pressed():
	emit_signal("tool_clicked", GameAutoload.TOOL_TYPE.BUCKET)

func _on_Explosive_pressed():
	emit_signal("tool_clicked", GameAutoload.TOOL_TYPE.EXPLOSIVE)
