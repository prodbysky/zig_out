const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(640, 480, "Hello Zig!");
    defer rl.closeWindow();

    var paddle = Paddle{ .pos = 100 };

    while (!rl.windowShouldClose()) {
        paddle.update();
        rl.beginDrawing();
        rl.clearBackground(rl.getColor(0x181818ff));
        paddle.draw();
        rl.endDrawing();
    }
}

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
        self.pos = std.math.clamp(self.pos, 0, 640 - Paddle.size.x);
    }
};
