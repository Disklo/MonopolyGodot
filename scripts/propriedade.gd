# Define uma propriedade, que é um tipo de Espaço comprável.
extends Espaco

class_name Propriedade

# Variáveis da propriedade, configuráveis no editor
@export var preco: int = 100
@export var aluguel_base: int = 10
@export var comprado: bool = false
@export var tipo_imovel: String = ""

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
@onready var cor_a_venda: ColorRect = $CorVenda
@onready var lotevenda: RichTextLabel = $NomeLabel2

func _ready() -> void:
	super._ready()
	preco_label.text = "Preço: R$" + _format_preco(preco)
	aluguel_label.text = "Aluguel: R$" + str(aluguel_base)
	#mostrar_aluguel()
	if comprado == true:
		lote_comprado()
	mostrar_propriedade(tipo_imovel)

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
		# Aqui entrará a lógica para mostrar o menu de compra na UI
		print("Propriedade sem dono. %s pode comprar por %d." % [jogador.nome, preco])
		# Lógica de compra (simplificada por enquanto)
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
	if jogador.dinheiro >= preco:
		print("%s comprou %s" % [jogador.nome, nome])
		jogador.pagar(preco)
		dono = jogador
		# jogador.comprar_propriedade(self)
	else:
		print("%s não tem dinheiro para comprar %s" % [jogador.nome, nome])


# Lógica para cobrar aluguel do jogador que parou aqui
func cobrar_aluguel(jogador: Jogador) -> void:
	jogador.pagar(aluguel_base)
	dono.receber(aluguel_base)

# Retira a visibilidade do preço e coloca a visibilidade no aluguel.
func lote_comprado() -> void:
	lotevenda.visible = false
	preco_label.visible = false
	aluguel_label.visible = true
	cor_a_venda.visible = false
	cor_comprada.visible = true

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
