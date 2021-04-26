extends Node

var DEBUG = true

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

var is_shovel_unlocked = false
var is_bucket_unlocked = false
var is_explosive_unlocked = false

var player_money = 0
var player_tools = {
	"shovel": TOOL_QUALITY.BASIC,
	"bucket": TOOL_QUALITY.BASIC,
	"explosive": 0
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

