const std = @import("std");

const chess = @import("chess");

const stdout = std.Io.File.stdout();
const stdin = std.Io.File.stdin();

var output_buf: [64]u8 = undefined;
var input_buf: [64]u8 = undefined;
pub fn main() !void {
    std.log.info("Tile size: {d}", .{@sizeOf(chess.Tile)});
    // var console_out = stdout.writer(output_buf);
    // console_out.interface.print(comptime fmt: []const u8, args: anytype)
}
