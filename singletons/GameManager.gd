extends Node


var coins = 0
var life = 3

var invulnerable = false

var total_coins = 0

var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals
	EventManager.connect("damaged", self, "_on_damaged")
	EventManager.connect("healed", self, "_on_healed")
	EventManager.connect("room_change", self, "_on_room_change")
	EventManager.connect("game_won", self, "_on_game_won")

func _process(delta):
	pass


func in_camera_bounds(pos: Vector2):
	if camera:
		return camera.is_on_screen(pos)
	else:
		return false


# Reset vars to initial values
func reset():
	coins = 0
	life = 3
	
	invulnerable = false


func _on_damaged():
	if life > 0 and not invulnerable:
		life -= 1
	if life == 0:
		get_tree().change_scene("res://menus/YouDied.tscn")


func _on_healed():
	if life < 3:
		life += 1


func _on_game_won():
	get_tree().change_scene("res://menus/YouWin.tscn")


func _on_room_change():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
