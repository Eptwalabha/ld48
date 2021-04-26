class_name MenuShop extends UIMenu

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
onready var selection = $MarginContainer/CenterContainer/Control/Control/Selection

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
	basic.connect("pressed", self, "_on_btn_pressed", [basic, type, GameAutoload.TOOL_QUALITY.BASIC])
	nice.connect("pressed", self, "_on_btn_pressed", [nice, type, GameAutoload.TOOL_QUALITY.NICE])
	super.connect("pressed", self, "_on_btn_pressed", [super, type, GameAutoload.TOOL_QUALITY.SUPER])
	basic.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.BASIC])
	nice.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.NICE])
	super.connect("mouse_entered", self, "_on_btn_hover", [type, GameAutoload.TOOL_QUALITY.SUPER])

func open() -> void:
	display_conversation("hello_kid")
	current_selection = null
	selection.visible = false
	visible = true

func display_conversation(text: String) -> void:
	dialog_dialog_line.text = tr(text)
	dialog_dialog.visible = true
	dialog_item.visible = false

func update_selection(btn):
	selection.visible = current_selection != null
	var size = btn.rect_size
	selection.global_position = btn.rect_global_position + size / 2

func update_btn_visiblity():
	shovels_line.visible = true
	buckets_line.visible = GameAutoload.unlocked["shovel"]
	explosives_line.visible = GameAutoload.unlocked["explosive"]
	
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
	match item_type:
		"shovel":
			if !GameAutoload.unlocked["shovel"]:
				return target_quality == GameAutoload.TOOL_QUALITY.BASIC
			else:
				var current_quality = GameAutoload.player_tools[item_type]
				return current_quality + 1 >= target_quality
		"bucket":
			if !GameAutoload.unlocked["shovel"]:
				return false
			elif !GameAutoload.unlocked["bucket"]:
				return target_quality == GameAutoload.TOOL_QUALITY.BASIC
			else:
				var current_quality = GameAutoload.player_tools[item_type]
				return current_quality + 1 >= target_quality
		"explosive":
			return GameAutoload.unlocked["explosive"]
	return false

func can_afford(item_type: String, item_quality: int) -> bool:
	var player_money = GameAutoload.player_money
	return player_money >= item_price(item_type, item_quality)

func _on_btn_hover(item_type: String, item_quality: int) -> void:
	var name = "shop_item_name_%s_%s" % [item_type, item_quality]
	var description = "shop_item_description_%s_%s" % [item_type, item_quality]
	dialog_item_name.text = tr(name)
	dialog_item_description.text = tr(description)
	dialog_item_price.text = tr("shop_item_price") + str(item_price(item_type, item_quality))
	dialog_dialog.visible = false
	dialog_item.visible = true

func item_price(type, quality) -> int:
	return GameAutoload.item_price(type, quality)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_Close_pressed()

func _on_btn_pressed(btn, item_type: String, item_quality: int) -> void:
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
	update_selection(btn)

func _on_Buy_pressed():
	if current_selection == null:
		buy_btn.disabled = true
	else:
		var type = current_selection["type"]
		var quality = current_selection["quality"]
		if can_afford(type, quality):
			GameAutoload.buy_item(type, quality)
			update_btn_visiblity()
			display_conversation("thank_you")
			current_selection = null
		else:
			display_conversation("not_enough_money")
	selection.visible = current_selection != null

