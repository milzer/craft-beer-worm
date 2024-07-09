class_name Hipster
extends CharacterBody2D

signal died
signal points_update(score: int)

var input_direction := Vector2.ZERO
var real_direction := Vector2.ZERO
var turn_speed := deg_to_rad(720.0)
var rotation_direction := 0
var speed := 300.0

var alcohol := 0
var points := 0

@onready var beard: Beard = $Beard
@onready var head: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
    global_position = get_viewport_rect().size / 2
    real_direction = Vector2.RIGHT
    input_direction = Vector2.RIGHT
    beard.connect('self_collision', Callable(self, '_on_beard_self_collision'))
    points_update.emit(0)

func _process(_delta: float) -> void:
    var current_input := Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down')
    if not current_input.is_zero_approx():
        input_direction = current_input.normalized()

    var angle_to_input := real_direction.angle_to(input_direction)
    var abs_angle_to_input: float = abs(angle_to_input)

    if abs_angle_to_input < deg_to_rad(1.0):
        rotation_direction = 0
        real_direction = input_direction
    elif abs_angle_to_input < deg_to_rad(135.0):
        rotation_direction = sign(angle_to_input)

func _physics_process(delta: float) -> void:
    var alcohol_turn_speed := turn_speed - deg_to_rad(alcohol * 10.0)

    real_direction = real_direction.rotated(rotation_direction * alcohol_turn_speed * delta).normalized()
    head.rotation = real_direction.angle() + deg_to_rad(90.0)
    collision_shape.rotation = head.rotation
    velocity = real_direction * (speed + alcohol * 10.0)
    move_and_slide()

    if (
        position.x > get_viewport_rect().size.x
        or position.x < 0
        or position.y > get_viewport_rect().size.y
        or position.y < 0
    ):
        queue_free()
        died.emit()

func _on_beard_self_collision() -> void:
    queue_free()
    died.emit()

func collected(pts: int, alc: int, grow_amount: int) -> void:
    points = max(0, points + pts)
    alcohol = max(0, alcohol + alc)
    beard.update(grow_amount * 10)

    points_update.emit(points)
