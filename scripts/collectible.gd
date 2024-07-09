class_name Collectible
extends Area2D

signal collected(points: int, alcohol: int, grow: int)

@export var points: int
@export var alcohol: int
@export var grow: int
@export var lifetime: float = 5.0
@export var sounds: Array[AudioStream]

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var time := 0.0

func _ready() -> void:
    assert(collision_shape.shape, 'missing collision shape')
    assert(sprite.texture, 'missing sprite texture')
    scale = Vector2.ZERO
    if len(sounds) > 0:
        audio_player.stream = sounds.pick_random()

func _on_body_entered(body: Node2D) -> void:
    if body is Hipster:
        collected.emit(points, alcohol, grow)

        if audio_player.stream != null:
            animation_player.play('pickup')
        else:
            queue_free()

func _process(delta: float) -> void:
    time += delta
    rotation = sin(time * 2.0) * deg_to_rad(10.0)

    lifetime -= delta

    if time < 1.0:
        scale = Vector2.ONE * time
    elif scale != Vector2.ONE:
        scale = Vector2.ONE

    if lifetime < 0.0:
        queue_free()
        collected.emit( - 1, 0, 0)
    elif lifetime <= 1.0:
        scale = Vector2.ONE * lifetime

func _on_audio_stream_player_2d_finished() -> void:
    queue_free()
