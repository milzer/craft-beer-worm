class_name Collectible
extends Area2D

signal collected(points: int, alcohol: int, grow: int)

@export var points: int
@export var alcohol: int
@export var grow: int
@export var lifetime: float = 5.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var time := 0.0

func _ready() -> void:
    assert(collision_shape.shape, 'missing collision shape')
    assert(sprite.texture, 'missing sprite texture')
    scale = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
    if body is Hipster:
        collected.emit(points, alcohol, grow)
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
        collected.emit(-1, 0, 0)
    elif lifetime <= 1.0:
        scale = Vector2.ONE * lifetime
