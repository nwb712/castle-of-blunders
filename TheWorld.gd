extends Node2D

onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.reset()
