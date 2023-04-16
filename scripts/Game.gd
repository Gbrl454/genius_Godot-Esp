extends CanvasLayer

enum GameState{NEW_ROUND, ANSWER, ERROR, NOT_GAME}

const MAX_COLORS = 4

var save = load("res://scripts/resource/save_game.tres")
var state = GameState.NOT_GAME
var sequence := 3
var round_game := 0
var color_raffle := []
var id_answer := 0

onready var genius_color: Control = $Genius/Colors
onready var audio: AudioStreamPlayer = $Audio
onready var sounds := [
	preload("res://assets/sound/do.ogg"),
	preload("res://assets/sound/re.ogg"),
	preload("res://assets/sound/mi.ogg"),
	preload("res://assets/sound/fa.ogg"),
	preload("res://assets/sound/erro.ogg"),
]

func _ready():
	randomize()
	for g_color in genius_color.get_children():
		g_color.hide()
	for i in $Genius/Buttons.get_child_count():
		var _btnC = $Genius/Buttons.get_child(i).connect("pressed", self, "_on_button_pressed", [i])
	var _btnS = $Genius/BtnStart.connect("pressed", self, "_on_start_pressed")
	_new_round(false)

	var _ledVrm = Serial.connect("ledVermelho", self, "_on_button_pressed", [0])
	var _ledAzl = Serial.connect("ledAzul", self, "_on_button_pressed", [1])
	var _ledAma = Serial.connect("ledAmarelo", self, "_on_button_pressed", [2])
	var _ledVrd = Serial.connect("ledVerde", self, "_on_button_pressed", [3])
	var _btnStr = Serial.connect("btnStart", self, "_on_start_pressed")

func _new_round(isGame: bool) -> void:
	id_answer = 0
	if isGame:
		_sequence(sequence + round_game)

	$LabelRound.text = "Rodada: " + str(round_game + 1)
	$LabelSequence.text = "Sequência: " + str(sequence + round_game)

	if save.rounds > (round_game + 1):
		$LabelRoundRecord.text = "Rodada: " + str(save.rounds)
		$LabelSequenceRecord.text = "Sequência: " + str(save.sequence)
	else:
		$LabelRoundRecord.text = "Rodada: " + str(round_game + 1)
		$LabelSequenceRecord.text = "Sequência: " + str(sequence + round_game)

func _on_start_pressed() -> void:
	if state == GameState.NOT_GAME:
		state = GameState.NEW_ROUND
		$Genius/Start.hide()
		$Genius/BtnStart.disabled = true
		color_raffle = []
		round_game = 0
		id_answer = 0
		_sequence(sequence + round_game)

func _sequence(qtd: int) -> void:
	for i in range(qtd):
		yield (get_tree().create_timer(0.5), "timeout")

		if i >= color_raffle.size():
			var rand = randi() % MAX_COLORS
			color_raffle.append(rand)

		_pisca_led(color_raffle[i], true)
	state = GameState.ANSWER

func _on_button_pressed(id_button):
	if state != GameState.ANSWER:
		return

	if (id_answer < color_raffle.size()):
		if color_raffle[id_answer] == id_button:
			_pisca_led(id_button, false)

		id_answer += 1
		if id_answer == color_raffle.size():
			round_game += 1
			yield (get_tree().create_timer(0.5), "timeout")
			_new_round(true)
	else:
		state = GameState.ERROR
		_game_over()

func _play_sound(id_sound: int) -> void:
	audio.stream = sounds[id_sound]
	audio.play()

func _game_over() -> void:
	_save_game()

	_play_sound(4)

	Serial.write("END")

	for _i in range(4):
		for j in MAX_COLORS:
			genius_color.get_child(j).show()
		yield (get_tree().create_timer(0.3), "timeout")
		for j in MAX_COLORS:
			genius_color.get_child(j).hide()


	for i in range(MAX_COLORS * MAX_COLORS):
		yield (get_tree().create_timer(0.05), "timeout")
		genius_color.get_child(i % MAX_COLORS).show()
		yield (get_tree().create_timer(0.05), "timeout")
		genius_color.get_child(i % MAX_COLORS).hide()

	round_game = 0
	state = GameState.NEW_ROUND
	color_raffle = []
	$Genius/Start.show()
	_new_round(false)
	$Genius/BtnStart.disabled = false
	state = GameState.NOT_GAME

func _save_game() -> void:
	if save.rounds < (round_game + 1):
		save.rounds = round_game + 1
		save.sequence = sequence + round_game
		var _res = ResourceSaver.save("res://scripts/resource/save_game.tres", save)

func _pisca_led(id_led: int, show: bool) -> void:
	_play_sound(id_led)

	if show:
		# print("LED", id_led)
		var m: String = "LED " + String(id_led)
		Serial.write(m)

		genius_color.get_child(id_led).show()
		yield (get_tree().create_timer(0.5), "timeout")
		genius_color.get_child(id_led).hide()

