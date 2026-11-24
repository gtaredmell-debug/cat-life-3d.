
extends Node3D

var player: Node3D
var camera: Camera3D
var cats: Array[Node3D] = []
var move_dir := Vector2.ZERO
var status_label: Label
var map_panel: Control
var action_text := "Исследуй город и знакомься с котиками"

func _ready():
    create_world()
    create_player()
    create_npcs()
    create_ui()

func material(color: Color) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.85
    return m

func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color):
    var n = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.position = pos
    n.material_override = material(color)
    parent.add_child(n)
    return n

func sphere(parent: Node3D, radius: float, pos: Vector3, color: Color, scale := Vector3.ONE):
    var n = MeshInstance3D.new()
    var mesh = SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    n.mesh = mesh
    n.position = pos
    n.scale = scale
    n.material_override = material(color)
    parent.add_child(n)
    return n

func create_cat(cat_color: Color, is_player := false) -> Node3D:
    var cat = Node3D.new()
    add_child(cat)

    sphere(cat, 0.48, Vector3(0, 0.55, 0), cat_color, Vector3(1.4, 0.9, 0.85))
    sphere(cat, 0.34, Vector3(0, 0.95, -0.4), cat_color)
    sphere(cat, 0.15, Vector3(-0.22, 1.23, -0.48), cat_color, Vector3(0.7, 1.3, 0.6))
    sphere(cat, 0.15, Vector3(0.22, 1.23, -0.48), cat_color, Vector3(0.7, 1.3, 0.6))
    sphere(cat, 0.09, Vector3(-0.13, 0.98, -0.7), Color.BLACK)
    sphere(cat, 0.09, Vector3(0.13, 0.98, -0.7), Color.BLACK)
    sphere(cat, 0.06, Vector3(0, 0.82, -0.73), Color(1, 0.5, 0.6))

    for x in [-0.3, 0.3]:
        for z in [-0.22, 0.32]:
            sphere(cat, 0.13, Vector3(x, 0.22, z), cat_color, Vector3(0.8, 1.5, 0.8))

    sphere(cat, 0.1, Vector3(0, 0.8, 0.6), cat_color, Vector3(0.8, 0.8, 2.5))
    cat.set_meta("phase", randf() * 6.28)
    cat.set_meta("player", is_player)
    return cat

func create_world():
    var env = WorldEnvironment.new()
    var e = Environment.new()
    e.background_mode = Environment.BG_SKY
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.75, 0.8, 0.9)
    e.ambient_light_energy = 0.8
    env.environment = e
    add_child(env)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-45, -30, 0)
    sun.shadow_enabled = false
    add_child(sun)

    box(self, Vector3(100, 0.2, 100), Vector3(0, -0.15, 0), Color(0.25, 0.48, 0.25))
    box(self, Vector3(100, 0.05, 7), Vector3(0, 0, 0), Color(0.35, 0.34, 0.32))
    box(self, Vector3(7, 0.05, 100), Vector3(0, 0, 0), Color(0.35, 0.34, 0.32))

    box(self, Vector3(17, 0.08, 12), Vector3(-23, -0.02, -22), Color(0.15, 0.48, 0.72))

    make_building("CAT CAFE", Vector3(12, 7, 9), Vector3(14, 3.5, -28), Color(0.8, 0.48, 0.34))
    make_building("BAKERY", Vector3(10, 6, 8), Vector3(-14, 3, -29), Color(0.85, 0.68, 0.42))
    make_building("VET CLINIC", Vector3(12, 7, 9), Vector3(29, 3.5, 17), Color(0.7, 0.82, 0.78))
    make_building("LIBRARY", Vector3(12, 7, 9), Vector3(-29, 3.5, 17), Color(0.5, 0.63, 0.78))
    make_building("HOME", Vector3(10, 6, 10), Vector3(0, 3, 34), Color(0.76, 0.55, 0.64))

    for i in range(28):
        var x = randf_range(-45, 45)
        var z = randf_range(-45, 45)
        if abs(x) < 5 or abs(z) < 5:
            continue
        sphere(self, 0.4, Vector3(x, 0.7, z), Color(0.35, 0.22, 0.12), Vector3(0.7, 1.8, 0.7))
        sphere(self, 1.4, Vector3(x, 2.2, z), Color(0.15, 0.42, 0.2))

func make_building(title: String, size: Vector3, pos: Vector3, color: Color):
    var b = Node3D.new()
    b.position = pos
    add_child(b)
    box(b, size, Vector3.ZERO, color)
    box(b, Vector3(size.x + 0.8, 0.5, size.z + 0.8), Vector3(0, size.y / 2 + 0.25, 0), Color(0.28, 0.2, 0.18))
    box(b, Vector3(1.8, 2.8, 0.2), Vector3(0, -size.y / 2 + 1.4, size.z / 2), Color(0.3, 0.18, 0.12))
    var sign = Label3D.new()
    sign.text = title
    sign.position = Vector3(0, size.y / 2 + 1, size.z / 2 + 0.2)
    sign.font_size = 48
    b.add_child(sign)

func create_player():
    player = create_cat(Color(0.85, 0.55, 0.28), true)
    player.position = Vector3(0, 0, 8)

    camera = Camera3D.new()
    camera.position = Vector3(0, 10, 14)
    camera.rotation_degrees = Vector3(-28, 0, 0)
    camera.current = true
    player.add_child(camera)

func create_npcs():
    var colors = [
        Color(0.9, 0.88, 0.8),
        Color(0.2, 0.2, 0.22),
        Color(0.8, 0.5, 0.3),
        Color(0.55, 0.6, 0.65),
        Color(0.9, 0.72, 0.4)
    ]
    for i in range(18):
        var c = create_cat(colors[i % colors.size()])
        c.position = Vector3(randf_range(-35, 35), 0, randf_range(-35, 35))
        cats.append(c)

func create_ui():
    var layer = CanvasLayer.new()
    add_child(layer)

    status_label = Label.new()
    status_label.position = Vector2(20, 15)
    status_label.add_theme_font_size_override("font_size", 22)
    layer.add_child(status_label)

    var directions = [
        ["↑", Vector2(75, -175), Vector2(0, -1)],
        ["↓", Vector2(75, -55), Vector2(0, 1)],
        ["←", Vector2(15, -115), Vector2(-1, 0)],
        ["→", Vector2(135, -115), Vector2(1, 0)]
    ]

    for item in directions:
        var btn = Button.new()
        btn.text = item[0]
        btn.position = Vector2(20, get_viewport().get_visible_rect().size.y) + item[1]
        btn.size = Vector2(55, 55)
        layer.add_child(btn)
        var direction: Vector2 = item[2]
        btn.button_down.connect(func(): move_dir = direction)
        btn.button_up.connect(func(): move_dir = Vector2.ZERO)

    var actions = HBoxContainer.new()
    actions.position = Vector2(300, get_viewport().get_visible_rect().size.y - 85)
    layer.add_child(actions)

    add_action(actions, "Погладить", "Котик довольно мурлычет")
    add_action(actions, "Кормить", "Котик кушает")
    add_action(actions, "Играть", "Котик играет с игрушкой")
    add_action(actions, "На руки", "Ты поднял котика")

    map_panel = MiniMap.new()
    map_panel.game = self
    map_panel.position = Vector2(get_viewport().get_visible_rect().size.x - 165, 15)
    map_panel.size = Vector2(150, 150)
    layer.add_child(map_panel)

func add_action(parent: HBoxContainer, title: String, message: String):
    var btn = Button.new()
    btn.text = title
    btn.custom_minimum_size = Vector2(95, 58)
    btn.pressed.connect(func(): action_text = message)
    parent.add_child(btn)

func _process(delta):
    if move_dir.length() > 0:
        var direction = Vector3(move_dir.x, 0, move_dir.y).normalized()
        player.position += direction * 5.0 * delta
        player.rotation.y = atan2(direction.x, direction.z)
        player.position.x = clamp(player.position.x, -47, 47)
        player.position.z = clamp(player.position.z, -47, 47)

    camera.global_position = camera.global_position.lerp(player.global_position + Vector3(0, 10, 14), delta * 3)
    camera.look_at(player.global_position)

    for c in cats:
        var phase = float(c.get_meta("phase")) + delta * 2
        c.set_meta("phase", phase)
        c.position.y = abs(sin(phase)) * 0.06

    status_label.text = "CAT LIFE 3D   |   " + action_text
    map_panel.queue_redraw()

class MiniMap extends Control:
    var game
    func _draw():
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.06, 0.08, 0.8), true)
        draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), Color(0.2, 0.35, 0.22), false, 2)
        if game == null or game.player == null:
            return
        var center = size / 2
        var p = center + Vector2(game.player.position.x, game.player.position.z) * 1.3
        draw_circle(p, 5, Color.YELLOW)
        for c in game.cats:
            var q = center + Vector2(c.position.x, c.position.z) * 1.3
            if Rect2(Vector2.ZERO, size).has_point(q):
                draw_circle(q, 3, Color.WHITE)
