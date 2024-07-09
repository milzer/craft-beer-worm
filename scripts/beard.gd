class_name Beard
extends Line2D

signal self_collision

var parent: Node2D
var beard_length := 30

@export var segment_length := 8.0

func orientation(p: Vector2, q: Vector2, r: Vector2) -> int:
    """
    Function to check the orientation of the ordered triplet (p, q, r)
    The function returns the following values:
    0 -> p, q, r are collinear
    1 -> Clockwise
    2 -> Counterclockwise
    """

    var val := (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
    if val > 0:
        return 1
    elif val < 0:
        return 2
    else:
        return 0

func on_segment(p: Vector2, q: Vector2, r: Vector2):
    """
    Check if point q lies on segment pr.
    """
    return (
        q.x <= max(p.x, r.x)
        and q.x >= min(p.x, r.x)
        and q.y <= max(p.y, r.y)
        and q.y >= min(p.y, r.y)
    )

func do_intersect(p1, q1, p2, q2):
    """
    Check if two segments (p1, q1) and (p2, q2) intersect
    """
    var o1 := orientation(p1, q1, p2)
    var o2 := orientation(p1, q1, q2)
    var o3 := orientation(p2, q2, p1)
    var o4 := orientation(p2, q2, q1)

    if o1 != o2 and o3 != o4:
        return true

    if o1 == 0 and on_segment(p1, p2, q1):
        return true
    if o2 == 0 and on_segment(p1, q2, q1):
        return true
    if o3 == 0 and on_segment(p2, p1, q2):
        return true
    if o4 == 0 and on_segment(p2, q1, q2):
        return true

    return false

func _ready() -> void:
    top_level = true
    z_index = -1

    parent = get_parent() as Node2D
    assert(parent, 'parent required')

    clear_points()

func _physics_process(_delta: float) -> void:
    var new_point := parent.global_position

    if get_point_count() < 2:
        add_point(new_point)
    else:
        var prev_point := get_point_position(get_point_count() - 1)
        if (prev_point - new_point).length() > segment_length:
            add_point(new_point)

    while get_point_count() > beard_length:
        remove_point(0)

    var point_count := get_point_count()
    if point_count > 3:
        var head1 := get_point_position(point_count - 1)
        var head2 := get_point_position(point_count - 2)

        for i in range(0, point_count - 3):
            var segment1 := get_point_position(i)
            var segment2 := get_point_position(i + 1)

            if do_intersect(head1, head2, segment1, segment2):
                self_collision.emit()

func update(amount: int) -> void:
    if amount < 0:
        beard_length = round(beard_length / 2.0) + 1
    else:
        beard_length += amount
