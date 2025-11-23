extends Control

class_name NegociacaoUI

@onready var option_jogadores: OptionButton = $Panel/OptionJogadores
@onready var container_minhas_props: VBoxContainer = $Panel/ScrollMinhas/VBoxContainer
@onready var container_outras_props: VBoxContainer = $Panel/ScrollOutras/VBoxContainer
@onready var input_meu_dinheiro: SpinBox = $Panel/InputMeuDinheiro
@onready var input_outro_dinheiro: SpinBox = $Panel/InputOutroDinheiro
@onready var btn_propor: Button = $Panel/BtnPropor
@onready var btn_cancelar: Button = $Panel/BtnCancelar

var jogo: Jogo
var jogador_atual: Jogador
var jogador_alvo: Jogador

var minhas_props_selecionadas: Array[Propriedade] = []
var outras_props_selecionadas: Array[Propriedade] = []

@onready var panel: Panel = $Panel
@onready var label_titulo: Label = $Panel/LabelTitulo
@onready var resize_handle: Button = $Panel/ResizeHandle

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var resizing: bool = false
var resize_start_pos: Vector2 = Vector2.ZERO
var resize_start_size: Vector2 = Vector2.ZERO

func setup(j: Jogo) -> void:
	jogo = j
	hide()
	btn_cancelar.pressed.connect(hide)
	btn_propor.pressed.connect(propor_troca)
	option_jogadores.item_selected.connect(_on_jogador_selecionado)
	
	input_meu_dinheiro.get_line_edit().add_theme_font_size_override("font_size", 60)
	input_outro_dinheiro.get_line_edit().add_theme_font_size_override("font_size", 60)
	
	# Setup Dragging (Title Bar)
	label_titulo.mouse_filter = Control.MOUSE_FILTER_STOP
	label_titulo.gui_input.connect(_on_title_gui_input)
	
	if resize_handle:
		resize_handle.gui_input.connect(_on_resize_gui_input)

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
		if new_size.x >= 600 and new_size.y >= 400: # Minimum size
			panel.size = new_size

func abrir(jogador: Jogador) -> void:
	jogador_atual = jogador
	
	# Popula lista de jogadores (exceto atual)
	option_jogadores.clear()
	var index = 0
	for j in jogo.jogadores:
		if j != jogador_atual and not j.falido:
			option_jogadores.add_item(j.nome, j.index)
			if index == 0:
				jogador_alvo = j
			index += 1
	
	if option_jogadores.item_count == 0:
		print("Ninguém para negociar.")
		return
		
	_on_jogador_selecionado(0)
	show()

func _on_jogador_selecionado(index: int) -> void:
	var id_alvo = option_jogadores.get_item_id(index)
	# Encontra jogador pelo ID (index)
	for j in jogo.jogadores:
		if j.index == id_alvo:
			jogador_alvo = j
			break
	
	atualizar_listas()

func atualizar_listas() -> void:
	# Limpa
	for child in container_minhas_props.get_children(): child.queue_free()
	for child in container_outras_props.get_children(): child.queue_free()
	minhas_props_selecionadas.clear()
	outras_props_selecionadas.clear()
	
	# Minhas propriedades
	for prop in jogador_atual.propriedades:
		var check = CheckBox.new()
		check.text = prop.nome + (" (Hipotecada)" if prop.hipotecada else "")
		check.add_theme_font_size_override("font_size", 40)
		check.toggled.connect(func(toggled):
			if toggled: minhas_props_selecionadas.append(prop)
			else: minhas_props_selecionadas.erase(prop)
		)
		container_minhas_props.add_child(check)
		
	# Propriedades do alvo
	for prop in jogador_alvo.propriedades:
		var check = CheckBox.new()
		check.text = prop.nome + (" (Hipotecada)" if prop.hipotecada else "")
		check.add_theme_font_size_override("font_size", 40)
		check.toggled.connect(func(toggled):
			if toggled: outras_props_selecionadas.append(prop)
			else: outras_props_selecionadas.erase(prop)
		)
		container_outras_props.add_child(check)

func propor_troca() -> void:
	var oferta_dinheiro = int(input_meu_dinheiro.value)
	var pedido_dinheiro = int(input_outro_dinheiro.value)
	
	if oferta_dinheiro > jogador_atual.dinheiro:
		print("Você não tem dinheiro suficiente.")
		return
		
	if pedido_dinheiro > jogador_alvo.dinheiro:
		print("O outro jogador não tem dinheiro suficiente.")
		return
	
	hide()
	
	# Exibe popup para o alvo aceitar
	var texto = "%s propõe uma troca:\n" % jogador_atual.nome
	texto += "Oferece: R$ %d" % oferta_dinheiro
	if not minhas_props_selecionadas.is_empty():
		texto += " + "
		for p in minhas_props_selecionadas: texto += p.nome + ", "
	
	texto += "\nEm troca de: R$ %d" % pedido_dinheiro
	if not outras_props_selecionadas.is_empty():
		texto += " + "
		for p in outras_props_selecionadas: texto += p.nome + ", "
		
	jogo.exibir_popup_confirmacao(texto + "\n\nAceitar troca?", func():
		executar_troca(oferta_dinheiro, pedido_dinheiro)
	, func():
		print("Troca recusada.")
	, "Aceitar", "Recusar")

func executar_troca(oferta_dinheiro: int, pedido_dinheiro: int) -> void:
	print("Troca aceita!")
	
	# Dinheiro
	jogador_atual.pagar(oferta_dinheiro)
	jogador_alvo.receber(oferta_dinheiro)
	
	jogador_alvo.pagar(pedido_dinheiro)
	jogador_atual.receber(pedido_dinheiro)
	
	# Propriedades
	for prop in minhas_props_selecionadas:
		prop.dono = jogador_alvo
		jogador_atual.propriedades.erase(prop)
		jogador_alvo.propriedades.append(prop)
		prop.atualizar_indicador_dono()
		if prop.hipotecada:
			# Regra: novo dono paga 10%
			var taxa = int((prop.preco / 2.0) * 0.1)
			jogador_alvo.pagar(taxa)
			
	for prop in outras_props_selecionadas:
		prop.dono = jogador_atual
		jogador_alvo.propriedades.erase(prop)
		jogador_atual.propriedades.append(prop)
		prop.atualizar_indicador_dono()
		if prop.hipotecada:
			var taxa = int((prop.preco / 2.0) * 0.1)
			jogador_atual.pagar(taxa)
			
	jogo.atualizar_ui_construcao()
