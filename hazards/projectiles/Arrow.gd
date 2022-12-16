extends Area2D

export var move: int = 1

var movement_vector: Vector2


func _ready():
	# Arrows are only allowed to move horizontally
	movement_vector = Vector2(move, 0)
	if movement_vector.x < 0:
		$Sprite.flip_h = true
	if GameManager.in_camera_bounds(global_position):
		$FireArrow.play()

func _physics_process(delta):
	position.x += movement_vector.x

func _on_Arrow_body_entered(body):
	if body.name == "Player":
		EventManager.emit_signal("damaged")
	queue_free()
