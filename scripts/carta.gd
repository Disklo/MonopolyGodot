extends Panel

class_name Carta

# Referência ao labels da carta
@onready var titulo_carta: Label = $PanelBorda/MarginContainer/VBoxContainer/TituloCarta
@onready var descricao_carta: Label = $PanelBorda/MarginContainer/VBoxContainer/DescricaoCarta
@onready var regra_carta: Label = $PanelBorda/MarginContainer/VBoxContainer/RegraCarta

signal carta_fechada

# Função para preencher a carta com os dados da carta do dicionário
func configurar_carta(dados_carta: Dictionary, tipo_baralho: String = "Sorte") -> void:
	titulo_carta.text = tipo_baralho
	descricao_carta.text = dados_carta.get("descricao","")
	
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
