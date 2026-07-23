class_name Utilities extends Node

static func seconds_to_time(seconds: int) -> String:
	return "%02d:%02d" % [seconds / 60, seconds % 60]