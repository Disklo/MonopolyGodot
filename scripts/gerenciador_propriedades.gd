extends Control

class_name GerenciadorPropriedades

@onready var panel: Panel = $Panel
@onready var container_propriedades: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var label_titulo: Label = $Panel/LabelTitulo
@onready var btn_fechar: Button = $Panel/BtnFechar
@onready var resize_handle: Button = $Panel/ResizeHandle

var jogador: Jogador
var jogo: Jogo

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

func setup(j: Jogo) -> void:
	jogo = j

func abrir(j: Jogador) -> void:
	jogador = j
	label_titulo.text = "Propriedades de " + jogador.nome
	atualizar_lista()
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

func atualizar_lista() -> void:
	# Limpa lista atual
	for child in container_propriedades.get_children():
		child.queue_free()
	
	if jogador.propriedades.is_empty():
		var lbl = Label.new()
		lbl.text = "Nenhuma propriedade."
		lbl.add_theme_font_size_override("font_size", 48)
		container_propriedades.add_child(lbl)
		return

	for prop in jogador.propriedades:
		var item = criar_item_propriedade(prop)
		container_propriedades.add_child(item)

func criar_item_propriedade(prop: Propriedade) -> Control:
	var panel_item = PanelContainer.new()
	var hbox = HBoxContainer.new()
	panel_item.add_child(hbox)
	
	# Nome e Cor
	var color_rect = ColorRect.new()
	color_rect.custom_minimum_size = Vector2(60, 60)
	if prop.cor_grupo in Propriedade.CORES_GRUPO:
		color_rect.color = Propriedade.CORES_GRUPO[prop.cor_grupo]
	else:
		color_rect.color = Color.GRAY
	hbox.add_child(color_rect)
	
	var lbl_nome = Label.new()
	lbl_nome.text = prop.nome
	lbl_nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_nome.add_theme_font_size_override("font_size", 48)
	hbox.add_child(lbl_nome)
	
	# Status
	var lbl_status = Label.new()
	lbl_status.add_theme_font_size_override("font_size", 48)
	if prop.hipotecada:
		lbl_status.text = "[HIPOTECADA]"
		lbl_status.modulate = Color.RED
	else:
		lbl_status.text = "Aluguel: R$" + str(prop.alugueis[prop.num_casas] if prop.num_casas < prop.alugueis.size() else prop.aluguel_base)
	hbox.add_child(lbl_status)
	
	# Botão Hipotecar/Des-hipotecar
	var btn_hipoteca = Button.new()
	btn_hipoteca.add_theme_font_size_override("font_size", 48)
	if prop.hipotecada:
		btn_hipoteca.text = "Des-hipotecar (R$%d)" % prop.calcular_valor_deshipoteca()
		btn_hipoteca.disabled = not prop.pode_deshipotecar()
		btn_hipoteca.pressed.connect(func():
			prop.deshipotecar()
			atualizar_lista()
			jogo.atualizar_ui_construcao() # Atualiza UI global se precisar
		)
	else:
		btn_hipoteca.text = "Hipotecar (+R$%d)" % (prop.preco / 2)
		btn_hipoteca.disabled = not prop.pode_hipotecar()
		btn_hipoteca.pressed.connect(func():
			prop.hipotecar()
			atualizar_lista()
			jogo.atualizar_ui_construcao()
		)
	hbox.add_child(btn_hipoteca)
	
	# Botão Construir
	var btn_construir = Button.new()
	btn_construir.add_theme_font_size_override("font_size", 48)
	btn_construir.text = "Construir (-R$%d)" % prop.custo_casa
	# Habilita o botão para permitir que o jogador clique e receba o feedback (popup) de erro
	# Apenas desabilita se já estiver no máximo
	btn_construir.disabled = prop.num_casas >= 5
	btn_construir.pressed.connect(func():
		prop.construir_casa()
		atualizar_lista()
		jogo.atualizar_ui_construcao()
	)
	hbox.add_child(btn_construir)
	
	# Botão Vender Casa
	var btn_vender = Button.new()
	btn_vender.add_theme_font_size_override("font_size", 48)
	btn_vender.text = "Vender Casa (+R$%d)" % (prop.custo_casa / 2)
	btn_vender.disabled = prop.num_casas == 0
	btn_vender.pressed.connect(func():
		prop.vender_casa()
		atualizar_lista()
		jogo.atualizar_ui_construcao()
	)
	hbox.add_child(btn_vender)
	
	return panel_item
