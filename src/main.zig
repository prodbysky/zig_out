const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(Global.Window.width, Global.Window.height, Global.Window.title);
    defer rl.closeWindow();

    var paddle = Paddle{ .pos = 100 };
    var ball = Ball{};
    var grid = BlockGrid.init();

    while (!rl.windowShouldClose()) {
        paddle.update();
        ball.update(&paddle, &grid);
        rl.beginDrawing();
        rl.clearBackground(rl.getColor(0x181818ff));
        paddle.draw();
        grid.draw();
        ball.draw();
        rl.endDrawing();
    }
}

const Global = struct {
    const Window = struct {
        const width: u16 = 640;
        const height: u16 = 480;
        const title: *const [7:0]u8 = "ZigOut!";
    };
};

const BlockGrid = struct {
    const n_x: u8 = 10;
    const n_y: u8 = 4;
    const padding_y: u16 = 100;
    const block_w: f32 = Global.Window.width / n_x;
    const block_h: f32 = (Global.Window.height - padding_y) / n_x;

    blocks: [n_x * n_y]rl.Rectangle,

    pub fn init() BlockGrid {
        var grid = BlockGrid{ .blocks = std.mem.zeroes([n_x * n_y]rl.Rectangle) };
        for (0..n_y) |y| {
            for (0..n_x) |x| {
                grid.blocks[y * n_x + x] = .{ .x = @as(f32, @floatFromInt(x)) * block_w, .y = @as(f32, @floatFromInt(y)) * block_h + 10, .width = block_w, .height = block_h };
            }
        }

        return grid;
    }
    pub fn draw(self: *const BlockGrid) void {
        for (self.blocks, 0..) |block, idx| {
            const color = rl.getColor(0xcc0000ff + @as(u32, @intCast(idx * idx * 256)));

            rl.drawRectangleRec(block, color);
        }
    }
};

const Paddle = struct {
    const speed: u16 = 400;
    const y_pos: f32 = 400;
    const color: rl.Color = .{ .r = 0xdd, .g = 0, .b = 0xee, .a = 0xff };
    const size: rl.Vector2 = .{ .x = 128, .y = 32 };
    pos: f32 = 0,

    pub fn draw(self: *const Paddle) void {
        rl.drawRectangleV(.{ .x = self.pos, .y = Paddle.speed }, Paddle.size, Paddle.color);
    }

    pub fn update(self: *Paddle) void {
        if (rl.isKeyDown(.key_a)) {
            self.pos -= Paddle.speed * rl.getFrameTime();
        }
        if (rl.isKeyDown(.key_d)) {
            self.pos += Paddle.speed * rl.getFrameTime();
        }
        self.pos = std.math.clamp(self.pos, 0, Global.Window.width - Paddle.size.x);
    }
};

const Ball = struct {
    const radius: f32 = 16;
    speed: rl.Vector2 = .{ .x = 100, .y = 100 },
    pos: rl.Vector2 = .{ .x = (Global.Window.width + Ball.radius) / 2, .y = (Global.Window.height + Ball.radius) / 2 },

    pub fn draw(self: *const Ball) void {
        rl.drawCircleV(self.pos, Ball.radius, rl.getColor(0x00ff00ff));
    }

    pub fn update(self: *Ball, paddle: *const Paddle, blocks: *BlockGrid) void {
        const dt = rl.getFrameTime();

        // Move the ball
        self.pos.x += self.speed.x * dt;
        self.pos.y += self.speed.y * dt;

        // Screen edge collision
        if (self.pos.x - Ball.radius <= 0 or self.pos.x + Ball.radius >= Global.Window.width) {
            self.speed.x = -self.speed.x;
        }
        if (self.pos.y - Ball.radius <= 0) {
            self.speed.y = -self.speed.y;
        }

        // Paddle collision
        const paddle_rect = rl.Rectangle{
            .x = paddle.pos,
            .y = Paddle.y_pos,
            .width = Paddle.size.x,
            .height = Paddle.size.y,
        };

        if (rl.checkCollisionCircleRec(self.pos, Ball.radius, paddle_rect)) {
            self.speed.y = -self.speed.y;
            const hit_pos = (self.pos.x - paddle.pos) / Paddle.size.x - 0.5;
            self.speed.x += hit_pos * 200;
        }

        for (&blocks.blocks) |*block| {
            if (block.width > 0 and rl.checkCollisionCircleRec(self.pos, Ball.radius, block.*)) {
                self.speed.y = -self.speed.y;

                // Destroy the block by setting its width to 0
                block.width = 0;

                break;
            }
        }
        self.speed.x = std.math.clamp(self.speed.x, -300, 300);
        self.speed.y = std.math.clamp(self.speed.y, -300, 300);
    }
};
