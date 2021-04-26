class_name MenuShop extends Control

signal close_menu()

onready var dialog = $Dialog
onready var dialog_item = $Dialog/Item
onready var dialog_dialog = $Dialog/Dialog
onready var dialog_dialog_line: Label = $Dialog/Dialog/Line
onready var dialog_item_name: Label = $Dialog/Item/Name
onready var dialog_item_description: Label = $Dialog/Item/Description
onready var dialog_item_price: Label = $Dialog/Item/Price
onready var shovels_line = $MarginContainer/CenterContainer/Control/Control/MarginContainer/VBoxContainer/Shovels
onready var buckets_line = $MarginContainer/CenterContainer/Control/Control/MarginContainer/VBoxContainer/Buckets
onready var explosives_line = $MarginContainer/CenterContainer/Control/Control/MarginContainer/VBoxContainer/Explosives
onready var buy_btn = $MarginContainer/CenterContainer/Control/HBoxContainer/Buy

var current_selection = null

func _ready():
	visible = false
	connect_btn()
	update_btn_visiblity()

func connect_btn() -> void:
	connect_btn_line(shovels_line, "shovel")
	connect_btn_line(buckets_line, "bucket")
	connect_btn_line(explosives_line, "explosive")

func connect_btn_line(node: Node, type: String) -> void:
	var basic = node.get_node("HBoxContainer/BASIC")
	var nice = node.get_node("HBoxContainer/NICE")
	var super = node.get_node("HBoxContainer/SUPER")
	basic.connect("pressed", self, "_on_btn_pressed", [type, GameAutoload.TOOL_QUALITY.BASIC])
	nice.connect("pressed", self, "_on_btn_pressed", [type, GameAutoload.TOOL_QUALITY.NICE])
	super.connect("pressed", self, "_on_btn_pressed", [type, GameAutoload.TOOL_QUALITY.SUPER])
	basic.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.BASIC])
	nice.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.NICE])
	super.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.SUPER])

func open() -> void:
	display_conversation("hello_kid")
	visible = true

func display_conversation(text: String) -> void:
	dialog_dialog_line.text = tr(text)
	dialog_dialog.visible = true
	dialog_item.visible = false

func is_open() -> bool:
	return visible

func _on_Close_pressed():
	visible = false
	emit_signal("close_menu")

func update_btn_visiblity():
	shovels_line.visible = GameAutoload.is_shovel_unlocked
	buckets_line.visible = GameAutoload.is_bucket_unlocked
	explosives_line.visible = GameAutoload.is_explosive_unlocked
	
	if shovels_line.visible:
		update_btn_visibility_line(shovels_line, "shovel")
	if buckets_line.visible:
		update_btn_visibility_line(buckets_line, "bucket")
	
func update_btn_visibility_line(node: Node, type: String) -> void:
	var basic = node.get_node("HBoxContainer/BASIC")
	var nice = node.get_node("HBoxContainer/NICE")
	var super = node.get_node("HBoxContainer/SUPER")
	basic.disabled = !is_btn_visible(type, GameAutoload.TOOL_QUALITY.BASIC)
	nice.disabled = !is_btn_visible(type, GameAutoload.TOOL_QUALITY.NICE)
	super.disabled = !is_btn_visible(type, GameAutoload.TOOL_QUALITY.SUPER)
	
func is_btn_visible(item_type: String, target_quality: int) -> bool:
	if target_quality == GameAutoload.TOOL_QUALITY.BASIC:
		return true
	var current_quality = GameAutoload.player_tools[item_type]
	return (target_quality - current_quality) <= 1

func can_afford(item_type: String, target_quality: int) -> bool:
	var cost = GameAutoload.shop["items"][item_type][target_quality]["price"]
	var player_money = GameAutoload.player_money
	return cost < player_money

func _on_btn_hover(item_type: String, item_quality: int) -> void:
	var name = "shop_item_name_%s_%s" % [item_type, item_quality]
	var description = "shop_item_description_%s_%s" % [item_type, item_quality]
	var price = GameAutoload.shop["items"][item_type][item_quality]["price"]
	dialog_item_name.text = tr(name)
	dialog_item_description.text = tr(description)
	dialog_item_price.text = tr("shop_item_price") + str(price)
	dialog_dialog.visible = false
	dialog_item.visible = true

func _on_btn_pressed(item_type: String, item_quality: int) -> void:
	if current_selection == null:
		current_selection = {
			"type": item_type,
			"quality": item_quality
		}
	else:
		if current_selection["type"] == item_type and current_selection["quality"] == item_quality:
			current_selection = null
		else:
			current_selection = {
				"type": item_type,
				"quality": item_quality
			}
	buy_btn.disabled = current_selection == null

func _on_Buy_pressed():
	if current_selection == null:
		buy_btn.disabled = true

