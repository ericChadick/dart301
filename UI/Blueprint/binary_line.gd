extends RichTextLabel

var lifetime := randf_range(.5, 1.0);
var str := "";
var byteChoice := [8, 16];
var rate := 0.0;
var rateTime := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bLen = byteChoice[randi_range(0, byteChoice.size()-1)];
	for i in bLen:
		str += str(int(randf() >= .5))
	text = str;
	rate = lifetime/bLen;
	rateTime = rate;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rateTime -= delta;
	if rateTime <= 0.0:
		str = str.left(-1);
		rateTime = rate;
		if str.length() == 0:
			queue_free();
	
	text = str;
	#push_outline_size(8)
