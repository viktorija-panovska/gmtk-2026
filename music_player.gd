extends AudioStreamPlayer
func _ready():
	print("Stream path: ", stream.resource_path if stream else "NULL STREAM")
	print("File exists: ", FileAccess.file_exists("res://sounds/music.ogg")) # adjust path
	play()

func _on_finished():
	play()
