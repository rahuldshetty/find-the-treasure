extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$DeathScreen.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_died():
	$DeathScreen.visible = true
	var player_score = $Player/CanvasLayer/CostLabel.text
	$DeathScreen/DeathPanel/CurrentScore.text = "Current Score: " + player_score
	
	var max_score = int(player_score.split("$")[1])
	if FileAccess.file_exists("user://save_game.dat"):
		var score = int(load_content())
		if score > max_score:
			max_score = score
		else:
			save(str(max_score))
	else:
		save(str(max_score))
	
	$DeathScreen/DeathPanel/MaxScore.text = "Max Score: $" + str(max_score)

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func save(content):
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(content)

func load_content():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content
