extends Node

enum BLOCK_TYPE {
	SAND = 6,
	DIRT = 7,
}

enum TOOL_TYPE {
	SPADE,
	BUCKET,
	EXPLOSIVE
}

enum SPADE_TYPE {
	BASIC,
	NICE,
	SUPER
}

enum BUCKET_TYPE {
	BASIC,
	NICE,
	SANTA_CLAUSE
}

var player_money = 0
var player_tools = {
	"spade": [],
	"bucket": [],
	"explosive": []
}

var shop = {
	"items": {
		"spade": {
			SPADE_TYPE.BASIC: {
				"price": 10,
				"name": "basic",
			},
			SPADE_TYPE.NICE: {
				"price": 100,
				"name": "nice",
			},
			SPADE_TYPE.SUPER: {
				"price": 300,
				"name": "super",
			}
		},
		"bucket": {
			BUCKET_TYPE.BASIC: {
				"price": 100,
				"name": "basic",
			},
			BUCKET_TYPE.NICE: {
				"price": 300,
				"name": "nice",
			},
			BUCKET_TYPE.SUPER: {
				"price": 500,
				"name": "super",
			}
		},
		"explosive": {
			1: {
				"amount": 1,
				"price": 5,
			},
			2: {
				"amount": 5,
				"price": 20,
			},
			3: {
				"amount": 20,
				"price": 70,
			},
		},
	}
}
