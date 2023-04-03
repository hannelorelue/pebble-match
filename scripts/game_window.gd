extends Node2D

onready var grid = $grid

var level := 1
var no_piece_types: int = 4

# Obstacle Variables
var concrete_spaces: PoolVector2Array
var empty_spaces: PoolVector2Array
var ice_spaces: PoolVector2Array
var lock_spaces: PoolVector2Array
var slime_spaces: PoolVector2Array

# Scoring Variables
var piece_value := 0
var max_score := 0

# Counter
var counter_value := 0
var is_move := true

var is_sinker_in_scene := true
var max_sinkers := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	grid.init(level, concrete_spaces, 
	empty_spaces, ice_spaces, lock_spaces, slime_spaces,
	max_score, counter_value, is_move, piece_value, is_sinker_in_scene, max_sinkers, no_piece_types)


func set_level_info(Level: int, Empty_Spaces: PoolVector2Array, Concrete_Spaces: PoolVector2Array, 
Ice_Spaces: PoolVector2Array, Lock_Spaces: PoolVector2Array, Slime_Spaces: PoolVector2Array,
Max_Score: int, Counter_Value: int, Is_Move: bool, Piece_Value: int, Is_sinker_in_scene: bool, Max_sinkers: int, No_piece_types):
	level = Level
	concrete_spaces = Concrete_Spaces
	empty_spaces = Empty_Spaces
	ice_spaces = Ice_Spaces
	lock_spaces = Lock_Spaces
	slime_spaces = Slime_Spaces
	piece_value = Piece_Value
	max_score = Max_Score
	counter_value = Counter_Value
	is_move = Is_Move
	is_sinker_in_scene = Is_sinker_in_scene
	max_sinkers = Max_sinkers
	no_piece_types = No_piece_types
