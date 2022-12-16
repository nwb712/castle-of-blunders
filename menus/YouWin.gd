extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	var coins = GameManager.coins
	var total_coins = GameManager.total_coins
	
	var rect_val = int(total_coins / 14)
	var rect_width = int(coins / rect_val)
	$CoinRect.rect_size[0] = rect_width


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://TheWorld.tscn")
