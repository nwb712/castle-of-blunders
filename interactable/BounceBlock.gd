extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collider

var impulse = Vector2(0, -250)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BounceBlock_body_entered(body):
	if body is KinematicBody2D:
		$AnimatedSprite.play("bounce")
		collider = body


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation  == "bounce" and collider and collider is KinematicBody2D:
		collider.movement_vector += impulse
		# collider.move_and_slide(impulse)
		collider = null
		$AnimatedSprite.play("default")
		$AudioStreamPlayer.play()
