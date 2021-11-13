require daslib/media
require graphics
require dasbox
require daslib/decs_boost

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

let colors = [[ uint[] 0xFF0000; 0x00FF00; 0x0000FF; 0xFFFF00; 0x00FFFF; 0xFF00FF; 0xFFFFFF]]

def draw_smooth_rect_frame(x: int; y: int; w: int; h: int; r: int; color: uint)
    for i in range(2)
        for j in range(2)
            let corner_x = x + w * i + r - 2 * r * i
            let corner_y = y + h * j + r - 2 * r * j
            fill_circle(corner_x, corner_y, r, color)
    // fill x
    fill_rect(x + r, y, w - 2 * r, r, color)
    fill_rect(x + r, y + h - r, w - 2 * r, r, color)
    // fill y
    fill_rect(x, y + r , r, h - 2 * r, color)
    fill_rect(x + w - r, y + r, r, h - 2 * r, color)

def draw_smooth_rect(x: int; y: int; w: int; h: int; r: int; color: uint)
    draw_smooth_rect_frame(x, y, w, h, r, color)
    // fill inside
    fill_rect(x + r, y + r, w - 2 * r, h - 2 * r, color)

def draw_quad_with_border(x: int; y: int; size: int; r: int; color: uint;
                         border: int; border_color: uint)
    assert(border < r, "Border should be less then radius")
    draw_smooth_rect_frame(x, y, size, size, r, border_color)
    draw_smooth_rect(x + border, y + border, size - 2 * border, size - 2 * border, r - border, color)

def print_message_centered(x: int; y: int; text: string; text_color: uint; background_color : uint; font_size: int; r: int = 10)
    let cur_text_sz = get_current_font_size()
    set_font_size(font_size)
    let sz = get_text_size(text)
    var szi = int2(sz)
    draw_smooth_rect(x - szi.x / 2 - 5, y - szi.y / 2 - 5, szi.x + 10, szi.y + 10, r, background_color)
    text_out(x - szi.x / 2, y - szi.y / 2, text, text_color)
    set_font_size(cur_text_sz)

def print_message_screen_centered(text: string; text_color: uint; background_color : uint; var font_size: int = -1; r: int = 10)
    let w = get_screen_width()
    let h = get_screen_height()
    let cur_text_sz = get_current_font_size()
    if font_size == -1
        font_size = h / 10
    set_font_size(font_size)
    let sz = get_text_size(text)
    var szi = int2(sz)
    draw_smooth_rect(w / 2 - szi.x / 2 - 20, h / 2 - szi.y / 2 - 20, szi.x + 40, szi.y +40, r, background_color)
    text_out(w / 2 - szi.x / 2, h / 2 - szi.y / 2, text, text_color)
    set_font_size(cur_text_sz)

def draw_slider(x: int; y: int; w: int; h: int; cur: int; total: int; filled_color: uint; background_color : uint; r: int)
    draw_smooth_rect(x - w / 2, y - h / 2, w, h, r, background_color)
    if h * cur / total > 0 
        draw_smooth_rect(x - w / 2, y + h / 2 - h * cur / total, w, h * cur / total, r, filled_color)

let background_color = 0xFF2F2F2F
let cell_border_color = 0xFF179797
let text_color = 0xFFFFFFFF
let back_color = 0xFF111111
let cell_r = 5
let quad_size = 35
let offset = 2
let field_pos_x = 10
let field_pos_y = 25
let field_height = 23
let field_width = 10
let next_field_pos_x = 400
let next_field_pos_y = 25
let next_field_height = 5
let next_field_width = 5
let ability_score_max = 10
let ability_count_max = 5
let base_movement_speed = 4.0

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
    draw_smooth_rect(x, y, sz_x, sz_y, 4, background_color)
    for i in range(w)
        for j in range(h)
            var border_color = cell_border_color
            var quad_color = background_color
            if main && (field[i][j] != 0u)
                quad_color = field[i][j]
                border_color = compute_border_color(quad_color)
            draw_quad_with_border(x + offset + i * (offset + quad_size),
                                  y + offset + j * (offset + quad_size),
                                  quad_size, cell_r, quad_color, offset,
                                  border_color)

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
        if j < field_height && j >= 0
            draw_quad_with_border(field_x + offset + i * (offset + quad_size),
                            field_y + offset + j * (offset + quad_size),
                            quad_size, cell_r, color, offset,
                            compute_border_color(color))
    apply_per_figure_part(x, y, fig_id, rotation, renderer)


var downPressed = false
var upPressed = false
var rightPressed = false
var leftPressed = false
var delta_t = 0.0
var seed = random_seed(int(ref_time_ticks() & int64(0xFFFFFFF)))

struct Figure 
    fig_type: int
    rotation: int
    x: int
    y: int
    color: uint
    time_till_move: float

var slowdown_left = 0.0
var movement_speed = 5.0
var active, next: Figure
var score = 0
var ability_score = 0
var pause = false
var manual = true
var finished = false
var first_time = true
var ability_count = 0

def make_figure()
    swap(active, next)
    next.fig_type = random_int(seed) % length(figures)
    next.rotation = random_int(seed) % 4
    let sz_x = length(figures[next.fig_type])
    let sz_y = length(figures[next.fig_type][0])
    var sz = sz_x
    if next.rotation % 2 == 1
        sz = sz_y
    next.x = random_int(seed) % (field_width - sz + 1)
    next.y = 0
    next.color = 0xFF000000
    var color_id = random_int(seed) % length(colors)
    next.color |= colors[color_id] & 0xFFFFFF
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
    set_resolution(600, 900)
    create_figure()
    for i in range(field_width)
        var v: array<uint>
        for j in range(field_height)
            push(v, 0u)
        emplace(field, v)
    decs_stage("clear_background")
    return

def clear_all()
    for i in range(field_width)
        for j in range(field_height)
            field[i][j] = 0u
    first_time = true
    create_figure()
    score = 0
    ability_score = 0
    ability_count = 0
    decs_stage("clear_background")

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
        finished = check_lost()
        if !finished
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
    var lines: array<int>
    var last_line = -1
    var i = field_height - 1
    var score_delta = 0
    while i >= 0
        var to_remove = true
        for j in range(field_width)
            if field[j][i] == 0u
                to_remove = false
        if to_remove  
            i--
            score_delta++
            continue
        push(lines, i)
        last_line = i
        i--
    score += score_delta
    ability_score = ability_score + score_delta * int(sqrt(float(score_delta)))
    if ability_score >= ability_score_max
        ability_count = min(ability_count + 1, ability_count_max)
        ability_score = 0
    for i in range(length(lines))
        for j in range(field_width)
            field[j][field_height - 1 - i] = field[j][lines[i]]
    i = last_line - 1
    while i >= 0
        for j in range(field_width)
            field[j][i] = 0u

def remove_line()
    if ability_count > 0
        ability_count--
        var l = field_height - 1
        while l > 0
            for j in range(field_width)
                field[j][l] = field[j][l - 1]
            l--
        for j in range(field_width)
            field[j][0] = 0u

def check_lost()
    for i in range(field_width)
        if field[i][0] != 0u
            return true
    return false

def skip_figure()
    if ability_count > 0
        create_figure()
        ability_count--

def slowdown_time()
    if ability_count > 0
        slowdown_left = 10.0
        ability_count--

def update_speed()
    slowdown_left -= delta_t
    movement_speed = base_movement_speed
    if slowdown_left > 0.0
        movement_speed = base_movement_speed / 3.0

def draw_figure()
    draw_figure(active.x, active.y, active.fig_type, active.rotation, active.color)

def draw_figure_next()
    draw_figure(1, 1, next.fig_type, next.rotation, next.color, next_field_pos_x, next_field_pos_y)

[decs_template]
struct Ball
    size: float
    position: float2
    speed: float2
    color: uint

def random_ball()
    create_entity <| @ (eid, cmp)
        cmp |> set ( "eid", eid)
        cmp |> set ( "size", 10.0)
        cmp |> set ("position", float2(random_float(seed), random_float(seed))
                                *float2(get_screen_width(), get_screen_height()))
        var speed = float2(random_float(seed), random_float(seed))*200.0 - float2(100.0)
        while length(speed) < 50.0
            speed = float2(random_float(seed), random_float(seed))*200.0 - float2(100.0)
        cmp |> set ("speed", speed)
        var color = 0xFF00000
        color |= (uint(random_int(seed)) & 0xFF) << 0u;
        color |= (uint(random_int(seed)) & 0xFF) << 8u;
        color |= (uint(random_int(seed)) & 0xFF) << 16u;
        cmp |> set ("color", color)
        apply_decs_template(cmp, [[Ball]])

[decs(stage=update_background)]
def update_balls(var position: float2&; var speed: float2&; size: float)
    position += speed * delta_t
    if position.x - size < 0.0
        position.x = size
        speed.x = -speed.x
    if position.y - size < 0.0
        position.y = size
        speed.y = -speed.y
    if position.x + size > float(get_screen_width())
        position.x = float(get_screen_width()) - size
        speed.x = -speed.x
    if position.y + size > float(get_screen_height())
        position.y = float(get_screen_height()) - size
        speed.y = -speed.y

[decs(stage=draw_background)]
def draw_balls(size: float; position: float2; color: uint)
    fill_circle(int(position.x), int(position.y), int(size), color)

def spawn_balls()
    var count = 0
    query <| $ (position: float2)
        count++
    while count < 100
        random_ball()
        count++

[decs(stage=clear_background)]
def clear_balls(eid:EntityId; size: float; position: float2; color: uint)
    delete_entity(eid)

[export]
def act(dt: float)
    delta_t = dt
    spawn_balls()
    decs_stage("update_background")
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    let pPressed = get_key_down(VK_P)
    downPressed = get_key_press(VK_DOWN)
    upPressed = get_key_press(VK_UP)
    leftPressed = get_key_press(VK_LEFT)
    rightPressed = get_key_press(VK_RIGHT)
    if get_key_down(VK_D)
        skip_figure()
    if get_key_down(VK_S)
        slowdown_time()
    if get_key_down(VK_R)
        remove_line()
    if !finished && !manual
        if pPressed
            pause = !pause
        if !pause
            update_speed()
            check_lines()
            update_controls()
            update_pos()
    else
        if downPressed || upPressed || leftPressed || rightPressed || pPressed
            if finished
                finished = false
                clear_all()
            if manual
                manual = false

[export]
def draw
    decs_stage("draw_background")
    enable_alpha_blend()
    fill_rect(0, 0, get_screen_width(), get_screen_height(), 0xAA111111)
    disable_alpha_blend()
    if !manual
        draw_field()
        draw_figure()
        draw_field(false)
        draw_figure_next()
        print_message_centered(next_field_pos_x + 93, next_field_pos_y + 250,
                                 "Score: {score}", text_color, background_color, 30)
        draw_slider(next_field_pos_x + 70, next_field_pos_y + 570, 100, 500,
                    ability_score, ability_score_max, text_color, background_color, 4)
        for i in range(ability_count_max)
            fill_circle(next_field_pos_x + 155, next_field_pos_y + 350 + i * 100, 20, background_color)
            if i < ability_count
                fill_circle(next_field_pos_x + 155, next_field_pos_y + 350 + i * 100, 15, text_color)
        if pause
            enable_alpha_blend()
            print_message_screen_centered("PAUSE", text_color, back_color)
            disable_alpha_blend()
        if finished
            print_message_screen_centered("GAME OVER\nSCORE: {score}", text_color, back_color, 70)
    else
        enable_alpha_blend()
        print_message_screen_centered(
"MANUAL:
-Figures can be moved with left and right
  arrows
-Rotation is done with up arrow
-To drop figure faster press down arrow
  (each time it moves one cell downwards)
-Pause or restart after lost game is done
  with P key
-Bonus scale on right is filled when lines
  are destroyed (the more lines are destroyed
  with one figure, the faster scale is filled)
-Each filled scale gives one bonus point
-Number of available bonus points is shown
  with with dots on right to bonus scale
  (with maximum {ability_count_max} in total)
-You can use one of three bonuses:
   1) Remove bottom line (R key)
   2) Slow down time for 10 seconds (S key)
   3) Destroy current figure (D key)
-Press P to skip this message", text_color, back_color, 20, 30)
        disable_alpha_blend()
