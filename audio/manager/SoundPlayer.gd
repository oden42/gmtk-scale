extends AudioStreamPlayer
class_name SoundPlayer

@export var sound_resource:SoundResource

func play_sound() -> void:
	sound_resource.play(self)
