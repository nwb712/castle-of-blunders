extends Area2D


const TILE_SIZE = 8

export var rope_length: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	update_rope_sprite()
	update_rope_shape()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass


func update_rope_sprite():
	$Sprite.region_rect.size.y = rope_length * TILE_SIZE


func update_rope_shape():
	var collision_shape = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.extents.x = TILE_SIZE / 4
	shape.extents.y = int((rope_length * TILE_SIZE) / 2)
	collision_shape.position.y = shape.extents.y
	collision_shape.shape = shape


func _on_Rope_body_entered(body):
	if body.name == "Player":
		EventManager.emit_signal("rope_entered")
	pass # Replace with function body.


func _on_Rope_body_exited(body):
	if body.name == "Player":
		EventManager.emit_signal("rope_exited")
	pass # Replace with function body.
