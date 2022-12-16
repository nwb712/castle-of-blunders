extends StaticBody2D

var button
onready var shape = get_node("CollisionShape2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_node("Button"):
		button = get_node("Button")
		button.connect("pressed", self, "on_Button_pressed")
	else:
		print("No button attached; opening gate.")
		open_gate()


func on_Button_pressed():
	open_gate()


func open_gate():
	$AnimatedSprite.play()
	


func close_gate():
	$AnimatedSprite.show()
	$AnimatedSprite.play("default", true)
	$CollisionShape2D.disabled = false


func _on_AnimatedSprite_animation_finished():
	$CollisionShape2D.disabled = true
	$AnimatedSprite.hide()
