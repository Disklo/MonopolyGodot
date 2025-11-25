# Define uma propriedade, que é um tipo de Espaço comprável.
extends Espaco

class_name Propriedade

# Variáveis da propriedade, configuráveis no editor
@export var preco: int = 100
@export var aluguel_base: int = 10
@export var comprado: bool = false
@export var tipo_imovel: String = ""
@export var cor_grupo: String = ""
@export var custo_casa: int = 50
@export var alugueis: Array[int] = [10, 50, 150, 450, 625, 750]
@export var num_casas: int = 0 # 5 para hotel
@export var hipotecada: bool = false

# O jogador que é o dono dessa propriedade. Fica nulo se não tiver dono.
var dono: Jogador = null

@onready var preco_label: RichTextLabel = $PrecoLabel
@onready var aluguel_label: RichTextLabel = $AluguelLabel
@onready var uma_casa: Sprite2D = $"1casa"
@onready var duas_casas: Sprite2D = $"2casas"
@onready var tres_casas: Sprite2D = $"3casas"
@onready var quatro_casas: Sprite2D = $"4casas"
@onready var hotel: Sprite2D = $"1hotel"
@onready var cor_comprada: ColorRect = $CorEspaco
@onready var lotevenda: RichTextLabel = $NomeLabel2
@onready var indicador_dono: Panel = $IndicadorDono
var botao_construir: Button = null

# Cores clássicas do Monopoly
const CORES_GRUPO = {
	"marrom": Color("8B4513"),
	"azul_claro": Color("87CEEB"),
	"rosa": Color("FF69B4"),
	"laranja": Color("FFA500"),
	"vermelho": Color("FF0000"),
	"amarelo": Color("FFFF00"),
	"verde": Color("008000"),
	"azul_escuro": Color("00008B")
}

func _ready() -> void:
	super._ready()
	preco_label.text = "Preço: R$" + _format_preco(preco)
	aluguel_label.text = "Aluguel: R$" + str(aluguel_base)
	
	atualizar_cor()
	
	if comprado:
		lote_comprado()
	
	mostrar_propriedade(tipo_imovel)
	
	botao_construir = get_node_or_null("BotaoConstruir")
	if botao_construir:
		botao_construir.pressed.connect(_on_botao_construir_pressed)

func toggle_botao_construir() -> void:
	if botao_construir == null:
		return
		
	botao_construir.visible = !botao_construir.visible
	if botao_construir.visible:
		atualizar_estado_botao_construir()

func atualizar_estado_botao_construir() -> void:
	if botao_construir == null:
		return
		
	var pode_construir = true
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	for espaco in tabuleiro.espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo and espaco != self:
			if espaco.num_casas < num_casas:
				pode_construir = false
				break
	
	if not pode_construir:
		botao_construir.modulate.a = 0.5
	else:
		botao_construir.modulate.a = 1.0

func _on_botao_construir_pressed() -> void:
	var pode_construir = true
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	for espaco in tabuleiro.espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo and espaco != self:
			if espaco.num_casas < num_casas:
				pode_construir = false
				break
	
	if not pode_construir:
		var jogo = get_tree().get_root().get_node("Jogo")
		if jogo.has_method("exibir_popup_mensagem"):
			jogo.exibir_popup_mensagem("Você deve construir uniformemente. Todas as propriedades do grupo devem ter o mesmo nível antes de avançar.")
		return

	construir_casa()
	atualizar_estado_botao_construir()

func atualizar_cor() -> void:
	# Define a cor do fundo baseada no grupo
	if cor_grupo in CORES_GRUPO:
		cor_comprada.color = CORES_GRUPO[cor_grupo]
	else:
		cor_comprada.color = Color.GRAY # Fallback
	
	cor_comprada.visible = true

# Formata um número para ter o ponto como separador de milhar.
func _format_preco(numero: int) -> String:
	var s = str(numero)
	var resultado = ""
	var cont = 0
	for i in range(s.length() - 1, -1, -1):
		resultado = s[i] + resultado
		cont += 1
		if cont % 3 == 0 and i != 0:
			resultado = "." + resultado
	return resultado

# Sobrescreve a função da classe Espaco
func ao_parar(jogador: Jogador) -> void:
	# Chama a função original para imprimir a mensagem (opcional)
	super.ao_parar(jogador)

	if dono == null:
		# Se não tem dono, o jogador pode comprar
		print("Propriedade sem dono. %s pode comprar por %d." % [jogador.nome, preco])
		# Chama o popup no Jogo
		var jogo = get_tree().get_root().get_node("Jogo")
		if jogo.has_method("exibir_popup_compra"):
			jogo.exibir_popup_compra(self)
		else:
			# Fallback se algo der errado
			comprar(jogador)

	elif dono == jogador:
		# Se o jogador já é o dono, não acontece nada
		print("Você parou na sua própria propriedade.")

	else:
		# Se tem dono e é outro jogador, cobra aluguel
		print("Propriedade de %s. %s paga aluguel." % [dono.nome, jogador.nome])
		cobrar_aluguel(jogador)


# Lógica para um jogador comprar a propriedade
func comprar(jogador: Jogador) -> void:
	print("Propriedade: Tentando comprar ", nome, " por ", jogador.nome)
	if jogador.dinheiro >= preco:
		print("%s comprou %s" % [jogador.nome, nome])
		jogador.pagar(preco)
		dono = jogador
		jogador.comprar_propriedade(self)
		lote_comprado()
		comprado = true
		atualizar_indicador_dono()
	else:
		print("%s não tem dinheiro para comprar %s" % [jogador.nome, nome])

func atualizar_indicador_dono() -> void:
	if dono != null:
		indicador_dono.visible = true
		var style = StyleBoxFlat.new()
		style.bg_color = dono.peao.modulate # Usa a cor do peão do jogador
		style.set_corner_radius_all(15) # Faz um círculo (metade do tamanho 30)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color.BLACK
		indicador_dono.add_theme_stylebox_override("panel", style)

# Função para cobrar aluguel
func cobrar_aluguel(jogador: Jogador) -> void:
	# Verifica se o dono existe e não é o próprio jogador.
	if dono != null and dono != jogador:
		if hipotecada:
			print("Propriedade hipotecada. Nenhum aluguel cobrado.")
			var jogo = get_tree().get_root().get_node("Jogo")
			if jogo.has_method("exibir_popup_mensagem"):
				jogo.exibir_popup_mensagem("Você caiu em %s, mas ela está hipotecada. Não pague aluguel." % nome, func():
					jogo.proximo_jogador()
				)
			return

		var aluguel_a_cobrar = aluguel_base
		
		
		if num_casas > 0 and num_casas < alugueis.size():
			aluguel_a_cobrar = alugueis[num_casas]
		
		elif num_casas == 0 and dono.tem_monopolio(cor_grupo, get_tree().get_root().get_node("Jogo/Tabuleiro")):
			aluguel_a_cobrar *= 2
		
		print("%s caiu na propriedade de %s. Aluguel: R$%d" % [jogador.nome, dono.nome, aluguel_a_cobrar])
		
		# Chama o popup no Jogo
		var jogo = get_tree().get_root().get_node("Jogo")
		if jogo.has_method("exibir_popup_mensagem"):
			jogo.exibir_popup_mensagem("Você caiu em %s (Propriedade de %s).\nPague R$ %d de aluguel." % [nome, dono.nome, aluguel_a_cobrar], func():
				# Verifica falência antes de tentar pagar
				if jogo.has_method("verificar_falencia_obrigatoria"):
					if jogo.verificar_falencia_obrigatoria(jogador, aluguel_a_cobrar):
						return # Faliu, não faz mais nada
				
				if not jogador.pagar(aluguel_a_cobrar):
					# Fallback caso a verificação falhe ou não exista (mas deveria ter pego no if acima)
					print("ERRO CRÍTICO: Jogador não faliu mas não conseguiu pagar.")
					jogo.declarar_falencia(jogador, dono)
				else:
					dono.receber(aluguel_a_cobrar)
					jogo.proximo_jogador()
			)
		else:
			if not jogador.pagar(aluguel_a_cobrar):
				print("Falência (sem UI)")
			else:
				dono.receber(aluguel_a_cobrar)

# Retira a visibilidade do preço e coloca a visibilidade no aluguel.
func lote_comprado() -> void:
	lotevenda.visible = false
	preco_label.visible = false
	aluguel_label.visible = true

func mostrar_aluguel() -> void:
	preco_label.visible = false
	aluguel_label.visible = true

func mostrar_propriedade(propriedade_a_mostrar: String) -> void:
	uma_casa.visible = false
	duas_casas.visible = false
	tres_casas.visible = false
	quatro_casas.visible = false
	hotel.visible = false

	match propriedade_a_mostrar:
		"uma_casa":
			uma_casa.visible = true
		"duas_casas":
			duas_casas.visible = true
		"tres_casas":
			tres_casas.visible = true
		"quatro_casas":
			quatro_casas.visible = true
		"hotel":
			hotel.visible = true

func construir_casa() -> void:
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	
	if dono == null:
		return

	if not dono.tem_monopolio(cor_grupo, tabuleiro):
		print("Você precisa ter o monopólio para construir aqui.")
		var jogo = get_tree().get_root().get_node("Jogo")
		if jogo.has_method("exibir_popup_mensagem"):
			jogo.exibir_popup_mensagem("Você só pode construir um imóvel caso possua um monopólio de um grupo de cor.")
		return
		
	if dono.dinheiro < custo_casa:
		print("Dinheiro insuficiente para construir.")
		var jogo = get_tree().get_root().get_node("Jogo")
		if jogo.has_method("exibir_popup_mensagem"):
			jogo.exibir_popup_mensagem("Você não tem dinheiro suficiente para construir nesta propriedade.")
		return

	if num_casas < 5:
		var jogo = get_tree().get_root().get_node("Jogo")
		if num_casas < 4:
			if jogo.total_casas_banco <= 0:
				print("Banco sem casas disponíveis.")
				jogo.exibir_popup_mensagem("O banco não tem mais casas disponíveis.")
				return
		else:
			if jogo.total_hoteis_banco <= 0:
				print("Banco sem hotéis disponíveis.")
				jogo.exibir_popup_mensagem("O banco não tem mais hotéis disponíveis.")
				return

		for espaco in tabuleiro.espacos:
			if espaco is Propriedade and espaco.cor_grupo == cor_grupo and espaco != self:
				if espaco.num_casas < num_casas:
					print("Deve construir uniformemente.")
					jogo.exibir_popup_mensagem("Você deve construir uniformemente. Todas as propriedades do grupo devem ter o mesmo nível antes de avançar.")
					return

		dono.pagar(custo_casa)
		num_casas += 1
		
		if num_casas <= 4:
			jogo.total_casas_banco -= 1
		else:
			jogo.total_casas_banco += 4
			jogo.total_hoteis_banco -= 1
			
		print("Construção realizada em %s. Total: %d" % [nome, num_casas])
		
		match num_casas:
			1: tipo_imovel = "uma_casa"
			2: tipo_imovel = "duas_casas"
			3: tipo_imovel = "tres_casas"
			4: tipo_imovel = "quatro_casas"
			5: tipo_imovel = "hotel"
			
		mostrar_propriedade(tipo_imovel)
		aluguel_label.text = "Aluguel: R$" + str(alugueis[num_casas])
	else:
		print("Máximo de construções atingido.")

func vender_casa() -> void:
	if num_casas == 0:
		print("Não há casas para vender.")
		return
		
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	var jogo = get_tree().get_root().get_node("Jogo")
	
	for espaco in tabuleiro.espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo and espaco != self:
			if espaco.num_casas > num_casas:
				print("Deve vender uniformemente. Venda das propriedades com mais casas primeiro.")
				jogo.exibir_popup_mensagem("Você deve vender uniformemente. Venda as construções das propriedades com mais casas primeiro.")
				return

	var valor_venda = custo_casa / 2
	dono.receber(valor_venda)
	
	if num_casas == 5:
		if jogo.total_casas_banco < 4:
			print("Banco não tem 4 casas para devolver. Deve vender tudo de uma vez?")
			jogo.exibir_popup_mensagem("Banco sem casas para converter o hotel.")
			return
			
		jogo.total_hoteis_banco += 1
		jogo.total_casas_banco -= 4
		num_casas = 4
	else:
		num_casas -= 1
		jogo.total_casas_banco += 1
		
	print("Venda realizada em %s. Total: %d" % [nome, num_casas])
	
	match num_casas:
		0: tipo_imovel = ""
		1: tipo_imovel = "uma_casa"
		2: tipo_imovel = "duas_casas"
		3: tipo_imovel = "tres_casas"
		4: tipo_imovel = "quatro_casas"
		
	mostrar_propriedade(tipo_imovel)
	if num_casas > 0:
		aluguel_label.text = "Aluguel: R$" + str(alugueis[num_casas])
	else:
		aluguel_label.text = "Aluguel: R$" + str(aluguel_base)

func pode_hipotecar() -> bool:
	if dono == null:
		return false
	if hipotecada:
		return false
	if num_casas > 0:
		return false
	# Verifica se alguma propriedade do grupo tem casas
	var tabuleiro = get_tree().get_root().get_node("Jogo/Tabuleiro")
	for espaco in tabuleiro.espacos:
		if espaco is Propriedade and espaco.cor_grupo == cor_grupo:
			if espaco.num_casas > 0:
				return false
	return true

func hipotecar() -> void:
	if not pode_hipotecar():
		print("Não é possível hipotecar esta propriedade.")
		return
	
	hipotecada = true
	dono.receber(int(preco / 2.0))
	print("%s hipotecou %s e recebeu R$ %d" % [dono.nome, nome, int(preco / 2.0)])
	atualizar_visual_hipoteca()

func pode_deshipotecar() -> bool:
	if not hipotecada:
		return false
	if dono.dinheiro < calcular_valor_deshipoteca():
		return false
	return true

func calcular_valor_deshipoteca() -> int:
	return int((preco / 2.0) * 1.1)

func deshipotecar() -> void:
	if not pode_deshipotecar():
		print("Não é possível des-hipotecar.")
		return
		
	var custo = calcular_valor_deshipoteca()
	dono.pagar(custo)
	hipotecada = false
	print("%s des-hipotecou %s pagando R$ %d" % [dono.nome, nome, custo])
	atualizar_visual_hipoteca()

func atualizar_visual_hipoteca() -> void:
	if hipotecada:
		self.modulate = Color(0.5, 0.5, 0.5)
	else:
		self.modulate = Color(1, 1, 1)
