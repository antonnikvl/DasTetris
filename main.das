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
[export]
def initialize
    set_window_title("Tetris")
    return

var rot = 0

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    if get_key_down(VK_UP)
        rot = (rot + 1) % 4
    if get_key_down(VK_DOWN)
        rot = 0
    return

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

def compute_border_color(c: uint)
    var result = c & (0xFF << 24u)
    for i in range(3)
        let k = (0xFF << (8u*uint(i)))
        result |= ((c & k) / 2u) & k
    return result

def draw_field(count_x: int; count_y: int)
    let sz_x = quad_size * count_x + offset * (count_x + 1)
    let sz_y = quad_size * count_y + offset * (count_y + 1)
    fill_rect(field_pos_x, field_pos_y, sz_x, sz_y, background_color)
    for i in range(count_x)
        for j in range(count_y)
            draw_quad_with_border(field_pos_x + offset + i * (offset + quad_size),
                                  field_pos_y + offset + j * (offset + quad_size),
                                  quad_size, r, background_color, offset,
                                  cell_border_color)
                                //   compute_border_color(background_color))

def draw_figure(x: int; y: int; fig_id: int; rotation: int; color: uint)
    let f := figures[fig_id] 
    let x_l = length(f)
    let y_l = length(f[0])
    for k in range(x_l)
        for l in range(y_l)
            let val = f[k][l]
            var i = k
            var j = l
            var xx = x_l
            var yy = y_l

            if rotation == 1
                swap(i, j)
                swap(xx, yy)
                i = xx - 1 - i
            if rotation == 2
                i = xx - 1 - i
                j = yy - 1 - j
            if rotation == 3
                swap(i, j)
                swap(xx, yy)
                j = yy - 1 - j

            i += x
            j += y
            if val == 1
                draw_quad_with_border(field_pos_x + offset + i * (offset + quad_size),
                                    field_pos_y + offset + j * (offset + quad_size),
                                    quad_size, r, color, offset,
                                    compute_border_color(color))

[export]
def draw
    draw_field(10, 20)
    draw_figure(0, 0, 0, rot, 0xFF00FF00)
    return