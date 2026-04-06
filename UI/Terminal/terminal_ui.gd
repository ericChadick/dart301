extends CanvasLayer

@onready var ui: MarginContainer = $UI
@onready var title: RichTextLabel = $UI/MarginContainer/VBoxContainer/Title
@onready var line: RichTextLabel = $UI/MarginContainer/VBoxContainer/Line
@onready var description: RichTextLabel = $UI/MarginContainer/VBoxContainer/Description
@onready var back: RichTextLabel = $UI/MarginContainer/VBoxContainer/Description/Back

@onready var start_timer: Timer = $StartTimer
@onready var delay_timer: Timer = $DelayTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var terminalTitle : String;
@export var terminalText : String;
@export var typeSpdTitle := 1.0;
@export var typeSpd := .2;
var typingBody := false;

var flashEnd := "[font=res://UI/Fonts/BPletterSquares.ttf][font_size=30]I";
var flashTimer := 0.0;
var flashOn := false;

var ending := false;

@export var init := false;
@export var ended := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;
	#ui.visible = false;
	#resetTerminalUI();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if init:
		resetTerminalUI();
		
	if ended:
		Global.terminalView = false;
		get_tree().paused = false;
		visible = false;
		ended = false;
		
	flashTimer += delta*3.0;
	
	if start_timer.time_left <= 0.0:
		title.visible_ratio += delta*typeSpdTitle;
		if title.visible_ratio >= 1.0:
			if !typingBody and delay_timer.is_stopped():
				delay_timer.start();
				typingBody = true;
	
	if typingBody and delay_timer.time_left <= 0.0:
		description.visible_ratio += delta*typeSpd;
		if description.visible_ratio >= 1.0:#!ending and 
			animation_player.play("exit");
			#ending = true;
		if flashTimer > 1.0 and description.visible_ratio >= 1.0:
			back.visible = !back.visible;
			flashTimer = 0.0;
		
		
func resetTerminalUI():
	visible = true;
	title.text = terminalTitle;
	description.text = terminalText;
	
	description.text = description.text.to_upper()
	back.text = description.text + flashEnd;
	back.visible = false;
	
	init = false;
	ending = false;
	animation_player.play("intro");
	start_timer.start();
	title.visible_ratio = 0.0;
	description.visible_ratio = 0.0;
	start_timer.start();
	back.visible = false;
	typingBody = false;
	flashTimer = 0.0;
