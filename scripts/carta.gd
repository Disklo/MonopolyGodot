extends CanvasLayer

class_name Carta

# Referência ao panel e labels da carta
@onready var panel: Panel = $Panel
@onready var titulo_carta: Label = $Panel/PanelBorda/MarginContainer/VBoxContainer/TituloCarta
@onready var descricao_carta: Label = $Panel/PanelBorda/MarginContainer/VBoxContainer/DescricaoCarta
@onready var botao_fechar: Button = $Panel/PanelBorda/ButtonFecharCarta

signal carta_fechada

# Função para preencher a carta com os dados da carta do dicionário
func configurar_carta(dados_carta: Dictionary, tipo_baralho: String = "Sorte", texto_botao: String = "Continuar") -> void:
	titulo_carta.text = tipo_baralho
	descricao_carta.text = dados_carta.get("descricao", "")
	# Define o texto do botão
	botao_fechar.text = texto_botao
	
# Função para mostrar a carta (torná-la visível)
func mostrarCarta() -> void:
	visible = true
	# Pausa o jogo enquanto a carta está sendo exibida
	get_tree().paused = true
	
# Função para fechar a carta
func fecharCarta() -> void:
	visible = false
	get_tree().paused = false
	carta_fechada.emit()
