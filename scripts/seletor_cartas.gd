extends Control

class_name SeletorCartas

@onready var panel: Panel = $Panel
@onready var container_cartas: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var label_titulo: Label = $Panel/LabelTitulo
@onready var btn_fechar: Button = $Panel/BtnFechar
@onready var resize_handle: Button = $Panel/ResizeHandle

var callback_selecionado: Callable

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var resizing: bool = false
var resize_start_pos: Vector2 = Vector2.ZERO
var resize_start_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	btn_fechar.pressed.connect(_on_fechar_pressed)
	
	label_titulo.mouse_filter = Control.MOUSE_FILTER_STOP
	label_titulo.gui_input.connect(_on_title_gui_input)
	
	if resize_handle:
		resize_handle.gui_input.connect(_on_resize_gui_input)
	
	hide()

func abrir(titulo: String, cartas: Array, callback: Callable) -> void:
	label_titulo.text = titulo
	callback_selecionado = callback
	atualizar_lista(cartas)
	show()

func _on_fechar_pressed() -> void:
	hide()

func _on_title_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = panel.get_global_mouse_position() - panel.global_position
			else:
				dragging = false
	
	if event is InputEventMouseMotion and dragging:
		panel.global_position = panel.get_global_mouse_position() - drag_offset

func _on_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				resizing = true
				resize_start_pos = panel.get_global_mouse_position()
				resize_start_size = panel.size
			else:
				resizing = false
	
	if event is InputEventMouseMotion and resizing:
		var new_size = resize_start_size + (panel.get_global_mouse_position() - resize_start_pos)
		if new_size.x >= 300 and new_size.y >= 200: # Minimum size
			panel.size = new_size

func atualizar_lista(cartas: Array) -> void:
	# Limpa lista atual
	for child in container_cartas.get_children():
		child.queue_free()
	
	if cartas.is_empty():
		var lbl = Label.new()
		lbl.text = "Nenhuma carta disponível."
		lbl.add_theme_font_size_override("font_size", 48)
		container_cartas.add_child(lbl)
		return

	for carta_item in cartas:
		var item = criar_item_carta(carta_item)
		container_cartas.add_child(item)

func criar_item_carta(carta_item: Dictionary) -> Control:
	var panel_item = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel_item.add_child(vbox)
	
	# Descrição da carta
	var lbl_descricao = Label.new()
	lbl_descricao.text = carta_item.descricao
	lbl_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_descricao.add_theme_font_size_override("font_size", 40)
	vbox.add_child(lbl_descricao)
	
	# Botão Selecionar
	var btn_selecionar = Button.new()
	btn_selecionar.text = "Selecionar"
	btn_selecionar.add_theme_font_size_override("font_size", 48)
	btn_selecionar.pressed.connect(func():
		if not callback_selecionado.is_null():
			callback_selecionado.call(carta_item)
		hide()
	)
	vbox.add_child(btn_selecionar)
	
	return panel_item
