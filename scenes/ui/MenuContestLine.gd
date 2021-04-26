class_name MenuContestLine extends Control

signal click(id, data)

var id: int = 0
var data: Dictionary
var is_selected : bool = false

func initialize(nbr: int, the_data: Dictionary) -> void:
	id = nbr
	data = the_data
	$MarginContainer/VBoxContainer/ID.text = str(id)
	$MarginContainer/VBoxContainer/Name.text = tr("contest_name_%s" % id)
	$MarginContainer/VBoxContainer/Result.text = "-" if data["podium"] == -1 else "#" + str(data["podium"])
	selection(false)

func selection(selected: bool) -> void:
	is_selected = selected
	$ColorRect.color.a = 1.0 if is_selected else 0.0

func _on_MarginContainer_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("click", id, data)
