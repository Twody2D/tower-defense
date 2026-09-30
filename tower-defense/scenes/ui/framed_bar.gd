class_name FramedBar
extends TextureProgressBar
## A progress bar in the design frame: this node draws the frame
## (texture_under), the Fill child — the green fill inset by its offsets —
## shares its value. A stretched texture_progress would take the bar's whole
## size and only be moved by texture_progress_offset, hanging out of the
## frame at the bottom.


func _ready() -> void:
	var fill: TextureProgressBar = $Fill
	fill.value = value
	fill.share(self)
