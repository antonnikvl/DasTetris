require daslib/media
require graphics
require dasbox
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
let field_height = 20
let field_width = 10

let next_field_pos_x = 400
let next_field_pos_y = 10
let next_field_height = 5
let next_field_width = 5

var field: array<array<uint>>

def compute_border_color(c: uint)
    var result = c & (0xFF << 24u)
    for i in range(3)
        let k = (0xFF << (8u*uint(i)))
        result |= ((c & k) / 2u) & k
    return result

def draw_field(main: bool = true)
    var w, h, x, y: int
    if main
        w = field_width
        h = field_height
        x = field_pos_x
        y = field_pos_y
    else
        w = next_field_width
        h = next_field_height
        x = next_field_pos_x
        y = next_field_pos_y
    let sz_x = quad_size * w + offset * (w + 1)
    let sz_y = quad_size * h + offset * (h + 1)
    fill_rect(x, y, sz_x, sz_y, background_color)
    for i in range(w)
        for j in range(h)
            var border_color = cell_border_color
            var quad_color = background_color
            if main && (field[i][j] != 0u)
                quad_color = field[i][j]
                border_color = compute_border_color(quad_color)
            draw_quad_with_border(x + offset + i * (offset + quad_size),
                                  y + offset + j * (offset + quad_size),
                                  quad_size, r, quad_color, offset,
                                  border_color)
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

struct Figure 
    fig_type: int
    rotation: int
    x: int
    y: int
    color: uint
    time_till_move: float

var active, next: Figure
var first_time = true;

def make_figure()
    swap(active, next)
    next.fig_type = random_int(seed) % length(figures)
    next.rotation = random_int(seed) % 4
    next.x = random_int(seed) % 7
    next.y = 0
    next.color = 0xFF00000
    next.color |= (uint(random_int(seed)) & 0xFF) << 0u;
    next.color |= (uint(random_int(seed)) & 0xFF) << 8u;
    next.color |= (uint(random_int(seed)) & 0xFF) << 16u;
    next.time_till_move = 1.0

def create_figure()
    if first_time
        make_figure()
        make_figure()
        first_time = false
    make_figure()

[export]
def initialize
    set_window_title("Tetris")
    create_figure()
    for i in range(field_width)
        var v: array<uint>
        for j in range(field_height)
            push(v, 0u)
        emplace(field, v)
    return

def clear_all()
    for i in range(field_width)
        for j in range(field_height)
            field[i][j] = 0u
    first_time = true
    create_figure()

def check_collision(xx: int; yy: int; t: int; r: int)
    var collides = false
    unsafe
        let border_checker <- @ <| [[&collides]] (i:int; j:int) : void
            collides ||= (j < 0) || (i < 0) || (i > field_width-1) || (j > field_height - 1)
            if (j >= 0) && (i >= 0) && (i <= field_width-1) && (j <= field_height - 1)
                collides ||= field[i][j] != 0u
        apply_per_figure_part(xx, yy, t, r, border_checker)
    return collides

def patch_field(xx: int; yy: int; t: int; r: int; color: uint)
    let border_checker <- @ <| [[&collides]] (i:int; j:int) : void
        if (j >= 0) && (i >= 0) && (i < field_width) && (j < field_height)
            field[i][j] = color
    apply_per_figure_part(xx, yy, t, r, border_checker)

def update_pos()
    active.time_till_move -= delta_t * movement_speed
    if active.time_till_move < 0.0
        active.time_till_move = 1.0
        active.y++
    if check_collision(active.x, active.y, active.fig_type, active.rotation)
        active.y--
        patch_field(active.x, active.y, active.fig_type, active.rotation, active.color)
        create_figure()

def update_controls()
    var xt = active.x
    var yt = active.y
    var rt = active.rotation
    if leftPressed
        xt--
    if rightPressed
        xt++
    if upPressed
        rt = (rt + 1) % 4
    if downPressed
        yt++
    if !check_collision(xt, yt, active.fig_type, rt)
        active.x = xt
        active.y = yt
        active.rotation = rt

def check_lines()
    for i in range(field_height)
        var to_remove = true
        for j in range(field_width)
            if field[j][i] == 0u
                to_remove = false
        if to_remove
            // todo: one loop
            var l = i
            while l > 0
                for j in range(field_width)
                    field[j][l] = field[j][l - 1]
                l--

var pause = false

[export]
def act(dt: float)
    delta_t = dt
    if get_key(VK_ESCAPE)
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
        check_lines()
        update_controls()
        update_pos()
    return

def draw_figure()
    draw_figure(active.x, active.y, active.fig_type, active.rotation, active.color)

def draw_figure_next()
    draw_figure(1, 1, next.fig_type, next.rotation, next.color, next_field_pos_x, next_field_pos_y)

[export]
def draw
    draw_field()
    draw_figure()
    draw_field(false)
    draw_figure_next()
    return