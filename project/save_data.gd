class_name SaveData
## The class that loads and saves the game

const SAVE_FILE_PATH = "user://savegame.json"


var high_score: int = 0


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json_data = JSON.parse_string(save_file.get_as_text())
	if "high_score" in json_data:
		high_score = json_data["high_score"]
	save_file.close()


func save() -> void:
	var data = {}
	data["high_score"] = high_score
	
	var json_data = JSON.stringify(data)
	var save_file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	save_file.store_string(json_data)
	save_file.close()


func register_new_score(score: int) -> void:
	if score <= high_score:
		return
	#print_debug("New high score!")
	high_score = score
	save()
