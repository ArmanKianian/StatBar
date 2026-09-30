@tool
extends EditorPlugin

const STAT_BAR_SCRIPT := preload("res://addons/stat_bar/stat_bar.gd")


func _enter_tree() -> void:
	add_custom_type("StatBar", "Control", STAT_BAR_SCRIPT, null)


func _exit_tree() -> void:
	remove_custom_type("StatBar")
