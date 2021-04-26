extends Node

var DEBUG = true
var MAX_EXPLOSIVE = 5

enum BLOCK_TYPE {
	SAND = 6,
	DIRT = 7,
	STONE = 10,
}

enum TOOL_TYPE {
	SHOVEL,
	BUCKET,
	EXPLOSIVE
}

enum TOOL_QUALITY {
	BASIC,
	NICE,
	SUPER,
}

func item_price(item_type: String, item_quality: int) -> int:
	return shop["items"][item_type][item_quality]["price"]

func buy_item(type, quality) -> void:
	unlocked[type] = true
	player_money -= item_price(type, quality)
	player_tools[type] = quality

var unlocked = {
	"shovel": false or DEBUG,
	"bucket": false or DEBUG,
	"explosive": false or DEBUG,
}

var player_money = 10
var player_tools = {
	"shovel": TOOL_QUALITY.BASIC,
	"bucket": TOOL_QUALITY.BASIC,
	"explosive": 20
}

var shop = {
	"items": {
		"shovel": [
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


var contests = [
	{ "duration": 0.1,	"price": [200, 100, 50],	"results": [4, 10],		"podium": -1,	"best": 0 },
	{ "duration": 2.0,	"price": [500, 200, 100],	"results": [6, 15],		"podium": -1,	"best": 0 },
	{ "duration": 2.0,	"price": [500, 200, 100],	"results": [10, 20],	"podium": -1,	"best": 0 },
	{ "duration": 1.0,	"price": [800, 400, 200],	"results": [10, 20],	"podium": -1,	"best": 0 },
]

var current_contest = null if !DEBUG else contests[0]

func can_contest(id: int) -> bool:
	return unlocked["shovel"]

func set_current_contest(id: int) -> void:
	current_contest = contests[id]
