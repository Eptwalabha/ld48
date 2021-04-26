class_name Cursor extends Node2D

func update_blocks(blocks: Array) -> void:
	$TileMap.clear()
	for block in blocks:
		$TileMap.set_cellv(block, GameAutoload.BLOCK_TYPE.SAND)
		$TileMap.update_bitmask_area(block)
