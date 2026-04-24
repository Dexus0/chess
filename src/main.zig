const std = @import("std");

const chess = @import("chess");

const stdout = std.fs.File.stdout();
const stdin = std.fs.File.stdin();

var write_buf: [64]u8 = undefined;
var input_buf: [64]u8 = undefined;
pub fn main() !void {
    std.log.info("Tile size: {d}", .{@sizeOf(chess.Tile)});
    // var console_out = stdout.writer(write_buf);
    // while () {}
    // console_out.interface.print(comptime fmt: []const u8, args: anytype)
}
