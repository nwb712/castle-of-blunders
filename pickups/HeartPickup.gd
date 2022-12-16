extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HeartPickup_body_entered(body):
	if body.name == "Player" and GameManager.life < 3:
		EventManager.emit_signal("healed")
		$Sprite.hide()
		$AudioStreamPlayer.play()


func _on_AudioStreamPlayer_finished():
	queue_free()
