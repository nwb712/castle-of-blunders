extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.connect("damaged", self, "_on_damaged")
	EventManager.connect("healed", self, "_on_healed")
	pass # Replace with function body.


func _on_damaged():
	$HBoxContainer.get_child(GameManager.life).hide()

func _on_healed():
	for i in GameManager.life:
		$HBoxContainer.get_child(i).show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


