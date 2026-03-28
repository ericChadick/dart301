extends RichTextLabel

var lifetime := 2.0;
var cost := 0;
var str := "";
var rate := 0.0;
var rateTime := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("FDSFSDDSFFSDF");
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rateTime -= delta;
	if rateTime <= 0.0:
		str = str.left(-1);
		rateTime = rate;
		if str.length() == 0:
			queue_free();
	
	text = "+" + str(cost) + "\n" + str;


func setText():
	str = String.num_int64(cost, 2);
	text = "+" + str(cost) + "\n" + str;
	
	rate = lifetime/str.length();
	rateTime = rate;
