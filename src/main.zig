const std = @import("std");
const rl = @import("raylib");

const Player = struct {
    color: rl.Color = .{ .r = 0xdd, .g = 0, .b = 0xee, .a = 0xff },
    pos: rl.Vector2 = .{ .x = 0, .y = 0 },
    size: rl.Vector2 = .{ .x = 64, .y = 64 },

    pub fn draw(self: *const Player) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }
};

pub fn main() !void {
    rl.initWindow(640, 480, "Hello Zig!");
    defer rl.closeWindow();

    const player = Player{ .pos = .{ .x = 100, .y = 100 }, .size = .{ .x = 100, .y = 100 } };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        player.draw();
        rl.endDrawing();
    }
}
