extends Control

#Função que vai chamar a cena Jogo quando o botão "Iniciar Jogo" for pressionado
func _on_botao_iniciar_jogo_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/jogo.tscn")

#Quando o botão de Opções for pressionado, essa função será chamada
func _on_botao_opcoes_pressed() -> void:
	pass # Replace with function body.

#função para sair do jogo
func _on_botao_sair_pressed() -> void:
	get_tree().quit()
