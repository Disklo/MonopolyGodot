extends CanvasLayer

class_name LeilaoUI

@onready var label_titulo: Label = $Content/PanelContainer/VBoxContainer/LabelTitulo
@onready var label_lance: Label = $Content/PanelContainer/VBoxContainer/LabelLance
@onready var label_vencedor: Label = $Content/PanelContainer/VBoxContainer/LabelVencedor
@onready var container_botoes: HBoxContainer = $Content/PanelContainer/VBoxContainer/ContainerBotoes

var jogo: Jogo
var propriedade: Propriedade
var lance_atual: int = 0
var vencedor_atual: Jogador = null
var jogadores_participantes: Array[Jogador] = []

func setup(j: Jogo) -> void:
	jogo = j
	hide()

func iniciar_leilao(prop: Propriedade, jogadores: Array[Jogador]) -> void:
	propriedade = prop
	jogadores_participantes = jogadores.duplicate()
	lance_atual = 10 # Lance inicial mínimo
	vencedor_atual = null
	
	label_titulo.text = "Leilão de " + propriedade.nome
	atualizar_ui()
	show()
	
	# Cria botões para cada jogador dar lance
	atualizar_botoes()

func atualizar_ui() -> void:
	label_lance.text = "Lance Atual: R$ %d" % lance_atual
	if vencedor_atual:
		label_vencedor.text = "Vencedor Atual: " + vencedor_atual.nome
	else:
		label_vencedor.text = "Sem lances"

func atualizar_botoes() -> void:
	for child in container_botoes.get_children():
		child.queue_free()
	
	for jogador in jogadores_participantes:
		if jogador.falido: continue
		
		var btn = Button.new()
		btn.text = "%s (+R$10)" % jogador.nome
		btn.disabled = jogador.dinheiro < (lance_atual + 10)
		btn.pressed.connect(func(): dar_lance(jogador))
		container_botoes.add_child(btn)
	
	# Botão para encerrar leilão (se houver vencedor)
	var btn_encerrar = Button.new()
	btn_encerrar.text = "Encerrar Leilão"
	btn_encerrar.disabled = vencedor_atual == null
	btn_encerrar.pressed.connect(encerrar_leilao)
	container_botoes.add_child(btn_encerrar)

func dar_lance(jogador: Jogador) -> void:
	lance_atual += 10
	vencedor_atual = jogador
	atualizar_ui()
	atualizar_botoes() # Atualiza estado dos botões (quem pode pagar)

func encerrar_leilao() -> void:
	if vencedor_atual:
		print("Leilão encerrado! %s venceu por R$ %d" % [vencedor_atual.nome, lance_atual])
		vencedor_atual.pagar(lance_atual)
		propriedade.dono = vencedor_atual
		vencedor_atual.propriedades.append(propriedade)
		propriedade.comprado = true
		propriedade.lote_comprado()
		propriedade.atualizar_indicador_dono()
		
		hide()
		jogo.exibir_popup_mensagem("%s venceu o leilão de %s por R$ %d!" % [vencedor_atual.nome, propriedade.nome, lance_atual], func():
			jogo.proximo_jogador()
		)
	else:
		# Ninguém deu lance? (Raro, mas possível)
		hide()
		jogo.proximo_jogador()
