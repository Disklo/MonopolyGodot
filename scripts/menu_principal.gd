extends Control

#Função que vai chamar a cena Jogo quando o botão "Iniciar Jogo" for pressionado
func _on_botao_iniciar_jogo_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/selecao_jogadores.tscn")

#Quando o botão de Opções for pressionado, essa função será chamada
func _on_botao_opcoes_pressed() -> void:
	var popup = Window.new()
	popup.title = "Opções"
	popup.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	popup.size = Vector2(300, 200)
	popup.transient = true
	popup.exclusive = true
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	popup.add_child(vbox)
	
	var check_debug = CheckButton.new()
	check_debug.text = "Modo Debug"
	check_debug.button_pressed = ConfiguracaoJogo.modo_debug
	check_debug.toggled.connect(func(toggled):
		ConfiguracaoJogo.modo_debug = toggled
		print("Modo Debug: ", toggled)
	)
	vbox.add_child(check_debug)
	
	var btn_fechar = Button.new()
	btn_fechar.text = "Fechar"
	btn_fechar.pressed.connect(func():
		popup.queue_free()
	)
	vbox.add_child(btn_fechar)
	
	add_child(popup)
	popup.close_requested.connect(func(): popup.queue_free())
	popup.popup_centered()


#função para sair do jogo
func _on_botao_sair_pressed() -> void:
	get_tree().quit()
