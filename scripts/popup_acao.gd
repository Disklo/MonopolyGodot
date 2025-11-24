extends CanvasLayer

class_name PopupAcao

@onready var message_label: Label = $Content/PanelContainer/VBoxContainer/MessageLabel
@onready var button_container: VBoxContainer = $Content/PanelContainer/VBoxContainer/ButtonContainer

var current_row: HBoxContainer

func _ready() -> void:
	hide_popup()

func set_text(text: String) -> void:
	message_label.text = text

func add_button(text: String, callback: Callable) -> void:
	# Se não houver linha atual ou a linha atual já tiver 5 botões, cria uma nova
	if current_row == null or current_row.get_child_count() >= 5:
		current_row = HBoxContainer.new()
		current_row.alignment = BoxContainer.ALIGNMENT_CENTER
		current_row.add_theme_constant_override("separation", 40)
		button_container.add_child(current_row)

	var btn = Button.new()
	btn.text = text
	# Carrega a fonte dinamicamente
	var font = load("res://assets/fonts/VCR_OSD_MONO_1.001.ttf")
	if font:
		btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 40)
	btn.custom_minimum_size = Vector2(150, 60)
	btn.pressed.connect(func():
		print("PopupAcao: Botão pressionado: ", text)
		callback.call()
		hide_popup()
	)
	current_row.add_child(btn)

func clear_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()
	current_row = null

func show_popup() -> void:
	visible = true
	# Garante que o popup fique no topo

func hide_popup() -> void:
	visible = false
