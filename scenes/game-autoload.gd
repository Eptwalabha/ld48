extends Node

var DEBUG = false
var MAX_EXPLOSIVE = 6

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
	{ "duration": 0.5,	"price": [50, 30, 10],	"results": [4, 8],		"podium": -1,	"best": 0 },
	{ "duration": 1.0,	"price": [80, 50, 20],	"results": [10, 14],		"podium": -1,	"best": 0 },
	{ "duration": 1.0,	"price": [120, 70, 30],	"results": [14, 20],	"podium": -1,	"best": 0 },
	{ "duration": 1.0,	"price": [200, 80, 40],	"results": [20, 35],	"podium": -1,	"best": 0 },
	{ "duration": 1.5,	"price": [300, 100, 50],	"results": [35, 50],	"podium": -1,	"best": 0 },
	{ "duration": 2,	"price": [500, 200, 100],	"results": [50, 70],	"podium": -1,	"best": 0 },
]

var current_contest = null if !DEBUG else contests[0]
var current_id = -1 if !DEBUG else 0
var last_results = null

func can_contest(_id: int) -> bool:
	return unlocked["shovel"]

func set_current_contest(id: int) -> void:
	current_contest = contests[id]
	current_id = id

func save_result() -> void:
	if last_results == null:
		return
	var depth = last_results["depth"]
	var podium = last_results["podium"]
	if podium < 3:
		player_money += current_contest["price"][podium]
		var old_podium = contests[current_id]["podium"]
		if old_podium == -1:
			contests[current_id]["podium"] = podium
		else:
			contests[current_id]["podium"] = min(podium, old_podium)
	contests[current_id]["best"] = max(depth, contests[current_id]["best"])
