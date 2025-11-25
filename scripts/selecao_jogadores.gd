extends Control

func _on_btn_0_humanos_pressed() -> void:
	iniciar_jogo(0)

func _on_btn_1_humano_pressed() -> void:
	iniciar_jogo(1)

func _on_btn_2_humanos_pressed() -> void:
	iniciar_jogo(2)

func _on_btn_3_humanos_pressed() -> void:
	iniciar_jogo(3)

func _on_btn_4_humanos_pressed() -> void:
	iniciar_jogo(4)

func iniciar_jogo(num_humanos: int) -> void:
	ConfiguracaoJogo.numero_jogadores_humanos = num_humanos
	print("Iniciando jogo com %d humanos" % num_humanos)
	get_tree().change_scene_to_file("res://scenes/jogo.tscn")

func _on_btn_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
