extends CanvasLayer

@export var animation_player: AnimationPlayer
@export var audio: AudioStreamPlayer 
@export var anim: AnimatedSprite2D 

var cutscene = false

func start() -> void:
	animation_player.play("start_fade")
	await animation_player.animation_finished


func end() -> void:
	animation_player.play("end_fade")
	await animation_player.animation_finished


func start_cutscene() -> void:
	animation_player.play("end_fade")
	anim.play("start")
	await anim.animation_finished
	anim.visible = false
	
