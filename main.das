require daslib/media
require graphics
require dasbox
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code


// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Tetris")
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
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

let background_color = 0x1F1F1F1F
let quad_color = 0x2F2F2F2F
let r = 5
let quad_size = 30
let offset = 1

def draw_field(x: int; y: int; count_x: int; count_y: int)
    let sz_x = quad_size * count_x + offset * (count_x + 1)
    let sz_y = quad_size * count_y + offset * (count_y + 1)
    fill_rect(x, y, sz_x, sz_y, background_color)
    for i in range(count_x)
        for j in range(count_y)
            draw_quad_with_border(x + offset + i * (offset + quad_size),
                                  y + offset + j * (offset + quad_size),
                                  quad_size, r, quad_color, offset,
                                  background_color)

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    // draw_smooth_quad(100, 100, 100, 10, 0xFFFFFFFF)
    // draw_quad_with_border(100, 100, 100, 10, 0x000000FF, 5, 0x0000FF00)
    draw_field(10, 10, 10, 20)
    return