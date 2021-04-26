extends Node

enum BLOCK_TYPE {
	SAND = 6,
	DIRT = 7,
	STONE = 10,
}

enum TOOL_TYPE {
	SPADE,
	BUCKET,
	EXPLOSIVE
}

enum TOOL_QUALITY {
	NONE,
	BASIC,
	NICE,
	SUPER,
}

var is_shovel_unlocked = true
var is_bucket_unlocked = true
var is_explosive_unlocked = true

var player_money = 0
var player_tools = {
	"shovel": TOOL_QUALITY.SUPER,
	"bucket": TOOL_QUALITY.NICE,
	"explosive": 100
}

var shop = {
	"items": {
		"spade": [
			{
				"price": 10,
				"quality": TOOL_QUALITY.BASIC,
				"name": "basic",
			},
			{
				"price": 100,
				"quality": TOOL_QUALITY.NICE,
				"name": "nice",
			},
			{
				"price": 300,
				"quality": TOOL_QUALITY.SUPER,
				"name": "super",
			}
		],
		"bucket": [
			{
				"price": 100,
				"quality": TOOL_QUALITY.BASIC,
				"name": "basic",
			},
			{
				"price": 300,
				"quality": TOOL_QUALITY.NICE,
				"name": "nice",
			},
			{
				"price": 500,
				"quality": TOOL_QUALITY.SUPER,
				"name": "super",
			}
		],
		"explosive": [
			{
				"amount": 1,
				"price": 5,
			},
			{
				"amount": 5,
				"price": 20,
			},
			{
				"amount": 20,
				"price": 70,
			},
		],
	}
}

