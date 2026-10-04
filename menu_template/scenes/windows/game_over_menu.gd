@tool
extends OverlaidWindow

## Path to a main menu scene.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var main_menu_scene_path: String
@export_node_path(&"ConfirmationOverlaidWindow") var main_menu_confirmation_node_path: NodePath
@export_node_path(&"ConfirmationOverlaidWindow") var exit_confirmation_node_path: NodePath

@onready var main_menu_confirmation: ConfirmationOverlaidWindow = get_node(main_menu_confirmation_node_path)
@onready var exit_confirmation: ConfirmationOverlaidWindow = get_node(exit_confirmation_node_path)

@onready var main_menu_button = %MainMenuButton
@onready var exit_button = %ExitButton

var open_window: Node


func get_main_menu_scene_path() -> String:
	if main_menu_scene_path.is_empty():
		return AppConfig.main_menu_scene_path
	return main_menu_scene_path


func close_window() -> void:
	if open_window != null:
		if open_window.has_method("close"):
			open_window.close()
		else:
			open_window.hide()
		open_window = null


func _load_scene(scene_path: String) -> void:
	_scene_tree.paused = false
	SceneLoader.load_scene(scene_path)


func _show_window(window: Control) -> void:
	window.show()
	open_window = window
	await window.hidden
	open_window = null


func _handle_cancel_input() -> void:
	if open_window != null:
		close_window()
	else:
		super._handle_cancel_input()


func _refresh_exit_button() -> void:
	exit_button.visible = !OS.has_feature("web")


func _refresh_main_menu_button() -> void:
	main_menu_button.visible = !get_main_menu_scene_path().is_empty()


func _ready() -> void:
	_refresh_exit_button()

	_refresh_main_menu_button()

	main_menu_confirmation.confirmed.connect(_on_main_menu_confirmation_confirmed)
	exit_confirmation.confirmed.connect(_on_exit_confirmation_confirmed)


func _on_restart_button_pressed() -> void:
	SceneLoader.reload_current_scene()
	close()


func _on_main_menu_button_pressed() -> void:
	_show_window(main_menu_confirmation)


func _on_exit_button_pressed() -> void:
	_show_window(exit_confirmation)


func _on_main_menu_confirmation_confirmed():
	_load_scene(get_main_menu_scene_path())


func _on_exit_confirmation_confirmed():
	get_tree().quit()
