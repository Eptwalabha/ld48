class_name BlockSelector extends Node2D

var type : int = TYPE.NONE
var cell_index: Vector2 = Vector2.ZERO

enum TYPE {
	NONE,
	VALID,
	INVALID
}

func update_cursor(position: Vector2, new_type: int) -> void:
	type = new_type
	match type:
		TYPE.VALID:
			$Sprite.frame = 1
		TYPE.INVALID:
			$Sprite.frame = 2
		_:
			type = TYPE.NONE
			$Sprite.frame = 3
