extends Node2D

@export var collectibles: Dictionary = {
    # TODO: can this be set up in the editor?
    preload ('res://scenes/collectibles/bottle.tscn'): 7,
    preload ('res://scenes/collectibles/can.tscn'): 7,
    preload ('res://scenes/collectibles/burger.tscn'): 2,
    preload ('res://scenes/collectibles/scissors.tscn'): 1,
}

@onready var hipster_scene: PackedScene = preload('res://scenes/hipster.tscn')
@onready var collectible_timer: Timer = $CollectibleTimer
@onready var status_label: Label = $StatusLabel

var hipster: Hipster

func _ready() -> void:
    start_game()

func start_game() -> void:
    if hipster != null:
        hipster.queue_free()
        hipster = null

    hipster = hipster_scene.instantiate()
    hipster.connect('died', Callable(self, '_on_hipster_died'))
    hipster.connect('points_update', Callable(self, '_on_hipster_points_update'))
    add_child(hipster)

    spawn_collectible(collectibles.keys()[0])
    collectible_timer.start();

func spawn_collectible(scene: PackedScene=null) -> void:
    if scene == null:
        scene = randomize_collectible()

    var collectible: Collectible = scene.instantiate()
    collectible.global_position.x = randf_range(32, get_viewport_rect().size.x - 32)
    collectible.global_position.y = randf_range(32, get_viewport_rect().size.y - 32)
    add_child(collectible)
    collectible.connect('collected', Callable(self, '_on_collectible_collected'))

func randomize_collectible() -> PackedScene:
    var total_weight = 0
    for weight in collectibles.values():
        total_weight += weight

    var random_value = randi() % total_weight

    var cumulative_weight = 0
    for scene in collectibles.keys():
        cumulative_weight += collectibles[scene]
        if random_value < cumulative_weight:
            return scene

    return collectibles.keys()[0]

func _on_timer_timeout() -> void:
    spawn_collectible()

func _on_collectible_collected(points: int, alcohol: int, grow: int) -> void:
    hipster.collected(points, alcohol, grow)

func _on_hipster_died() -> void:
    get_tree().reload_current_scene()

func _on_hipster_points_update(points: int) -> void:
    status_label.text = 'Points: %d' % points
