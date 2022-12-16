extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.total_coins += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Coin_body_entered(body):
	if body.name == "Player":
		GameManager.coins += 1
		$AnimatedSprite.hide()
		$AudioStreamPlayer.play()


func _on_AudioStreamPlayer_finished():
	queue_free()
