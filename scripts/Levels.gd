extends Resource

func get_levels():
	return levels

export (Dictionary) var pages = {
	1 : {
		"levels" : [1,6],
		"background" : "res://art/UI/Backgrounds/mine2.png",
		"positions" : [],
	}
}


export (Dictionary) var levels = {
	1:{
		"unlocked" : true,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"empty_spaces" : [
			Vector2(0,0),
			Vector2(0,1),
			Vector2(0,2),
			Vector2(0,3),
			Vector2(0,4),
			Vector2(0,5),
			Vector2(0,6),
			Vector2(0,7),
			Vector2(7,0),
			Vector2(7,1),
			Vector2(7,2),
			Vector2(7,3),
			Vector2(7,4),
			Vector2(7,5),
			Vector2(7,6),
			Vector2(7,7),
			Vector2(1,0),
			Vector2(2,0),
			Vector2(3,0),
			Vector2(4,0),
			Vector2(5,0),
			Vector2(6,0),
			Vector2(1,7),
			Vector2(2,7),
			Vector2(3,7),
			Vector2(4,7),
			Vector2(5,7),
			Vector2(6,7),
		],
		"concrete_spaces" :[],
		"ice_spaces" :[Vector2(2,4)],
		"lock_spaces" : [Vector2(4,3)],
		"slime_spaces" : [Vector2(3,3)],
		"piece_value" : 20,
		"max_score" : 1500,
		"counter_value" : 15,
		"is_move" : true,
		"is_sinker_in_scene": false, 
		"max_sinkers": 0,
		"No_piece_types" : 4,
		"goals" : {
			1 : {
				"type" : "IRON",
				"value" : 15,
			},
			2 :  {
				"type" : "COAL",
				"value" : 10,
			},
			3 : {
				"type" : "",
				"value" : 0,
			},
		},
	},
	
	2:{
		"unlocked" : false,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"concrete_spaces" :[],
		"empty_spaces" : [],
		"ice_spaces" :[Vector2(4,3), Vector2(4,4), Vector2(3,3), Vector2(3,4)],
		"lock_spaces" : [],
		"slime_spaces" : [Vector2(0,0), Vector2(0,7),Vector2(7,0), Vector2(7,7)],
		"piece_value" : 20,
		"max_score" : 500,
		"counter_value" : 60,
		"is_move" : false,
		"is_sinker_in_scene": false, 
		"max_sinkers": 0,
		"No_piece_types" : 5,
		"goals" : {
			1 : {
				"type" : "ICE",
				"value" : 4,
			},
			2 :  {
				"type" : "COAL",
				"value" : 5,
			},
			3 : {
				"type" : "",
				"value" : 0,
			},
		},
	},
	
	3:{
		"unlocked" : false,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"concrete_spaces" :[],
		"empty_spaces" : [],
		"ice_spaces" :[
			Vector2(2,2), 
			Vector2(2,1), 
			Vector2(3,2), 
			Vector2(3,1), 
			Vector2(4,2), 
			Vector2(4,1),
			Vector2(5,2), 
			Vector2(5,1),
			],
		"lock_spaces" : [],
		"slime_spaces" : [Vector2(0,5), Vector2(0,6),Vector2(7,5), Vector2(7,6)],
		"piece_value" : 20,
		"max_score" : 3000,
		"counter_value" : 25,
		"is_move" : true,
		"is_sinker_in_scene": true, 
		"max_sinkers": 2,
		"No_piece_types" : 5,
		"goals" : {
			1 : {
				"type" : "PINK",
				"value" : 2,
			},
			2 :  {
				"type" : "",
				"value" : 0,
			},
			3 : {
				"type" : "",
				"value" : 0,
			},
		},
	},
	
	4:{
		"unlocked" : false,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"concrete_spaces" :[],
		"empty_spaces" : [Vector2(4,3), Vector2(4,4), Vector2(3,3), Vector2(3,4)],
		"ice_spaces" :[],
		"lock_spaces" : [Vector2(5,3), Vector2(5,4), Vector2(2,3), Vector2(2,4)],
		"slime_spaces" : [Vector2(0,5),Vector2(7,5)],
		"piece_value" : 20,
		"max_score" : 1500,
		"counter_value" : 50,
		"is_move" : true,
		"is_sinker_in_scene": false, 
		"max_sinkers": 0,
		"No_piece_types" : 5,
		"goals" : {
			1 : {
				"type" : "LOCK",
				"value" : 4,
			},
			2 :  {
				"type" : "COAL",
				"value" : 10,
			},
			3 : {
				"type" : "MOSS",
				"value" : 4,
			},
		},
	},
	
	5:{
		"unlocked" : false,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"concrete_spaces" :[],
		"empty_spaces" : [],
		"ice_spaces" :[],
		"lock_spaces" : [Vector2(4,3), Vector2(4,4)],
		"slime_spaces" : [Vector2(0,0), Vector2(0,1)],
		"piece_value" : 20,
		"max_score" : 750,
		"counter_value" : 40,
		"is_move" : false,
		"is_sinker_in_scene": false, 
		"max_sinkers": 0,
		"No_piece_types" : 5,
		"goals" : {
			1 : {
				"type" : "QUARTZ",
				"value" : 10,
			},
			2 :  {
				"type" : "IRON",
				"value" : 10,
			},
			3 : {
				"type" : "",
				"value" : 0,
			},
		},
	},
	
	6:{
		"unlocked" : false,
		"high_score" : 0,
		"date" : "",
		"stars_unlocked" : 0,
		"concrete_spaces" :[],
		"empty_spaces" : [],
		"ice_spaces" :[Vector2(2,2), Vector2(2,1), Vector2(3,2), Vector2(3,1)],
		"lock_spaces" : [Vector2(4,3), Vector2(3,3),Vector2(5,3)],
		"slime_spaces" : [Vector2(0,5), Vector2(0,6),Vector2(7,5), Vector2(7,6)],
		"piece_value" : 20,
		"max_score" : 2500,
		"counter_value" : 20,
		"is_move" : true,
		"is_sinker_in_scene": true, 
		"max_sinkers": 2,
		"No_piece_types" : 4,
		"goals" : {
			1 : {
				"type" : "PINK",
				"value" : 4,
			},
			2 :  {
				"type" : "COAL",
				"value" : 20,
			},
			3 : {
				"type" : "",
				"value" : 0,
			},
		},
	},
} 
