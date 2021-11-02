require daslib/media
require graphics
require dasbox
require daslib/decs_boost
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code

let figures <- [{ auto
 [{auto
    [{int 1; 1; 1; 1}]
 }];
 [{auto
    [{int 1; 0; 0}]; [{int 1; 1; 1}]
 }];
 [{auto
    [{int 0; 0; 1}]; [{int 1; 1; 1}]
 }];
 [{auto
    [{int 1; 1}]; [{int 1; 1}]
 }];
 [{auto
    [{int 0; 1; 1}]; [{int 1; 1; 0}]
 }];
 [{auto
    [{int 0; 1; 0}]; [{int 1; 1; 1}]
 }];
 [{auto
    [{int 1; 1; 0}]; [{int 0; 1; 1}]
 }]
}]

// helpers start

def draw_smooth_quad_frame(x: int; y: int; size: int; r: int; color: uint)
    for i in range(2)
        for j in range(2)
            let corner_x = x + size * i + r - 2 * r * i
            let corner_y = y + size * j + r - 2 * r * j
            fill_circle(corner_x, corner_y, r, color)
    // fill x
    fill_rect(x + r, y, size - 2 * r, r, color)
    fill_rect(x + r, y + size - r, size - 2 * r, r, color)
    // fill y
    fill_rect(x, y +r , r, size - 2 * r, color)
    fill_rect(x + size - r, y + r, r, size - 2 * r, color)

def draw_smooth_quad(x: int; y: int; size: int; r: int; color: uint)
    draw_smooth_quad_frame(x, y, size, r, color)
    // fill inside
    fill_rect(x + r, y + r, size - 2 * r, size - 2 * r, color)

def draw_quad_with_border(x: int; y: int; size: int; r: int; color: uint;
                         border: int; border_color: uint)
    assert(border < r, "Border should be less then radius")
    draw_smooth_quad_frame(x, y, size, r, border_color)
    draw_smooth_quad(x + border, y + border, size - 2 * border, r - border, color)

let background_color = 0xFF2F2F2F
let cell_border_color = 0xFF179797
let r = 5
let quad_size = 30
let offset = 2
let field_pos_x = 10
let field_pos_y = 10
var field_height = 20
let field_width = 10

let next_field_pos_x = 400
let next_field_pos_y = 10
var next_field_height = 5
let next_field_width = 5

def compute_border_color(c: uint)
    var result = c & (0xFF << 24u)
    for i in range(3)
        let k = (0xFF << (8u*uint(i)))
        result |= ((c & k) / 2u) & k
    return result

def draw_field(x: int; y: int; w: int; h: int)
    let sz_x = quad_size * w + offset * (w + 1)
    let sz_y = quad_size * h + offset * (h + 1)
    fill_rect(x, y, sz_x, sz_y, background_color)
    for i in range(w)
        for j in range(h)
            draw_quad_with_border(x + offset + i * (offset + quad_size),
                                  y + offset + j * (offset + quad_size),
                                  quad_size, r, background_color, offset,
                                  cell_border_color)
                                //   compute_border_color(background_color))

def apply_per_figure_part(x: int; y: int; fig_type: int; rot: int;
                          func: lambda<(xp: int; yp: int):void>)
    let f := figures[fig_type] 
    let x_l = length(f)
    let y_l = length(f[0])
    for k in range(x_l)
        for l in range(y_l)
            let val = f[k][l]
            var i = k
            var j = l
            var xx = x_l
            var yy = y_l

            if rot == 1
                swap(i, j)
                swap(xx, yy)
                i = xx - 1 - i
            if rot == 2
                i = xx - 1 - i
                j = yy - 1 - j
            if rot == 3
                swap(i, j)
                swap(xx, yy)
                j = yy - 1 - j

            i += x
            j += y
            if val == 1
                invoke(func, i, j)

def draw_figure(x: int; y: int; fig_id: int; rotation: int; color: uint;
                field_x: int = field_pos_x; field_y: int = field_pos_y)
    let renderer <- @ <| (i:int; j:int) : void
        if j < field_height
            draw_quad_with_border(field_x + offset + i * (offset + quad_size),
                            field_y + offset + j * (offset + quad_size),
                            quad_size, r, color, offset,
                            compute_border_color(color))
    apply_per_figure_part(x, y, fig_id, rotation, renderer)

var movement_speed = 10.0
var delta_t = 0.0

var downPressed = false
var upPressed = false
var rightPressed = false
var leftPressed = false

var seed = random_seed(42)

[decs_template]
struct Figure 
    fig_type: int
    rotation: int
    x: int
    y: int
    color: uint
    time_till_move: float
    active: bool
    next: bool


def make_figure()
    var figure_id = create_entity <| @ ( eid, cmp )
        cmp |> set ("eid", eid )
        cmp |> set ("fig_type", random_int(seed) % length(figures))
        cmp |> set ("rotation", random_int(seed) % 4)
        cmp |> set ("x", random_int(seed) % 7)
        cmp |> set ("y", field_height)
        cmp |> set ("color", (0xFF000000 | uint(random_int(seed)) & 0xFFFFFF))
        cmp |> set ("time_till_move", 1.0)
        cmp |> set ("active", false)
        cmp |> set ("next", true)
        apply_decs_template(cmp, [[Figure]])

def create_figure()
    query <| $(var next : bool&; var active : bool&)
        if next
            active = true
            next = false
    make_figure()

[decs(stage=init)]
def clear_all(eid:EntityId)
    delete_entity(eid)

[export]
def initialize
    set_window_title("Tetris")
    decs_stage("init")
    return

def check_collision(xx: int; yy: int; t: int; r: int)
    var collides = false
    unsafe
        let border_checker <- @ <| [[&collides]] (i:int; j:int) : void
            collides ||= (j < 0) || (i < 0) || (i > field_width-1)
        apply_per_figure_part(xx, yy, t, r, border_checker)
        if collides
            return true
        let checker <- @ <| [[&collides]] (i:int; j:int) : void
            let checker_int <- @ <| [[&collides]] (u:int; v:int) : void
                collides ||= (u == i) && (v == j)
            apply_per_figure_part(xx, yy, t, r, checker_int)
        query <| $ (x: int; y: int; rotation: int; fig_type: int; active: bool; next: bool)
            if (!active) && (!next)
                apply_per_figure_part(x, y, fig_type, rotation, checker)
    return collides

[decs(stage=update)]
def update_pos(x: int; var y: int&; fig_type: int; rotation: int;
               var time_till_move: float&; var active: bool&)
    if !active
        return
    var yy = y
    time_till_move -= delta_t * movement_speed
    if time_till_move < 0.0
        time_till_move = 1.0
        yy--
    if check_collision(x, yy, fig_type, rotation)
        active = false
    else
        y = yy

[decs(stage=update, before=update_pos)]
def controls(var y: int&; var x: int&; var rotation: int&; active: bool; fig_type: int)
    if !active
        return
    var xt = x
    var yt = y
    var rt = rotation
    if leftPressed
        xt--
    if rightPressed
        xt++
    if upPressed
        rt = (rt + 1) % 4
    if downPressed
        yt--
    if !check_collision(xt, yt, fig_type, rt)
        x = xt
        y = yt
        rotation = rt

def add_new_if_needed()
    var has_active = false
    let t = find_query <| $(active : bool)
        has_active ||= active
    if !has_active
        create_figure()

var pause = false

[export]
def act(dt: float)
    delta_t = dt
    if get_key(VK_ESCAPE)
        clear_all()
        schedule_quit_game()
    if get_key_down(VK_E)
        clear_all()
    if get_key_down(VK_P)
        pause = !pause
    downPressed = get_key_down(VK_DOWN)
    upPressed = get_key_down(VK_UP)
    leftPressed = get_key_down(VK_LEFT)
    rightPressed = get_key_down(VK_RIGHT)
    if !pause
        decs_stage("update")
        add_new_if_needed()
    return

[decs(stage=draw)]
def draw_figures(fig_type: int; rotation: int; x:int; y: int; color: uint; next: bool)
    if !next
        draw_figure(x, y, fig_type, rotation, color)

[decs(stage=draw_next)]
def draw_figure_next(fig_type: int; rotation: int; x:int; y: int; color: uint; next: bool)
    if next
        draw_figure(1, 1, fig_type, rotation, color, next_field_pos_x, next_field_pos_y)

[export]
def draw
    draw_field(field_pos_x, field_pos_y, field_width, field_height)
    decs_stage("draw")
    draw_field(next_field_pos_x, next_field_pos_y, next_field_width, next_field_height)
    decs_stage("draw_next")
    return