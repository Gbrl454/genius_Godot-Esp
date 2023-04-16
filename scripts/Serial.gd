extends Node

const serial_res = preload("res://bin/gdserial.gdns")
var serial_port = serial_res.new()

var is_port_open = false
var msg = ""

signal ledVermelho
signal ledAzul
signal ledAmarelo
signal ledVerde
signal btnStart

func _ready():
	is_port_open = serial_port.open_port("COM4", 115200)
	print(is_port_open)


func _process(_delta):
	if is_port_open:
		var message = serial_port.read_text()
		if message.length() > 0:
			for i in message:
				if i == "\n":
					_text_interpreter(msg)
					msg = ""
				else:
					msg += i

func _text_interpreter(txt):
	# print(txt)
	match txt:
		"ledVermelho":
			emit_signal("ledVermelho")
		"ledAzul":
			emit_signal("ledAzul")
		"ledAmarelo":
			emit_signal("ledAmarelo")
		"ledVerde":
			emit_signal("ledVerde")
		"btnStart":
			emit_signal("btnStart")

func write(txt):
	txt += "\n"
	serial_port.write_text(txt)
