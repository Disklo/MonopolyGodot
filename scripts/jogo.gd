# Script principal que gerencia o fluxo do jogo.
extends Node

class_name Jogo

# Referências aos nós da cena, configuráveis no editor
@export var tabuleiro: Tabuleiro
@export var jogadores: Array[Jogador]

# Variáveis para controlar o estado do jogo
var turno_atual: int = 0
var jogador_atual: Jogador

# A função _ready é chamada quando o nó entra na árvore da cena.
func _ready() -> void:
	iniciar_jogo()

# Prepara o estado inicial do jogo.
func iniciar_jogo() -> void:
	if jogadores.is_empty() or tabuleiro == null:
			print("ERRO: Jogadores ou tabuleiro não configurados na cena Jogo.")
			return

	turno_atual = 0
	jogador_atual = jogadores[turno_atual]
	print("O jogo começou! É a vez de %s." % jogador_atual.nome)

# Passa para o próximo turno.
func proximo_turno() -> void:
	turno_atual = (turno_atual + 1) % jogadores.size()
	jogador_atual = jogadores[turno_atual]
	print("\n--- Próximo turno! É a vez de %s. ---" % jogador_atual.nome)

# Simula a rolagem de dois dados de 6 lados.
func rolar_dados() -> int:
	var dado1 = randi_range(1, 6)
	var dado2 = randi_range(1, 6)
	var total = dado1 + dado2
	print("%s rolou os dados: %d + %d = %d" % [jogador_atual.nome, dado1, dado2,
total])
	return total

# Essa função deve ser conectada a um botão de "Rolar Dados" na UI
func _on_rolar_dados_apertado() -> void:
	if jogador_atual == null:
			print("Jogo não iniciado corretamente.")
			return

	# 1. Rola os dados
	var passos = rolar_dados()

	# 2. Move o jogador
	jogador_atual.mover(passos)

	# 3. Obtém o espaço em que o jogador parou
	var espaco_atual = tabuleiro.obter_espaco(jogador_atual.posicao)

	# 4. Executa a ação daquele espaço
	if espaco_atual != null:
			espaco_atual.ao_parar(jogador_atual)

	# 5. Passa para o próximo turno
	# (Espera as animações terminarem antes do turno ser passado)
	proximo_turno()
