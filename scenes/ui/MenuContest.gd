class_name MenuContest extends UIMenu

signal enter_contest(id)

var ContestLineScene = preload("res://scenes/ui/MenuContestLine.tscn")
var current_selection = -1

onready var contests_list = $MarginContainer/CenterContainer/Control/Control/MarginContainer/ContestList
onready var confirm_btn = $MarginContainer/CenterContainer/Control/HBoxContainer/EnterContest

func _ready():
	visible = false
	confirm_btn.disabled = true
	update_contests_list()

func open() -> void:
	current_selection = -1
	update_selection(current_selection)
	visible = true

func update_contests_list() -> void:
	var contests = GameAutoload.contests
	for id in range(len(contests)):
		var contest = contests[id]
		var line = ContestLineScene.instance()
		line.initialize(id, contest)
		line.connect("click", self, "_on_line_click")
		contests_list.add_child(line)
		if contest["podium"] == -1:
			break

func update_selection(id: int) -> void:
	for line in contests_list.get_children():
		line.selection(line.id == id)

func _on_line_click(id: int, _data: Dictionary) -> void:
	if id != current_selection:
		current_selection = id
	else:
		current_selection = -1
	confirm_btn.disabled = current_selection == -1
	update_selection(current_selection)

func _on_EnterContest_pressed():
	if current_selection != -1:
		emit_signal("enter_contest", current_selection)
	else:
		confirm_btn.disabled = false
