const std = @import("std");

const chess = @import("chess");

const stdout = std.Io.File.stdout();
const stdin = std.Io.File.stdin();

var output_buf: [64]u8 align(64) = undefined;
var input_buf: [64]u8 align(64) = undefined;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var console_out = stdout.writer(io, output_buf);
    var console_in = stdin.reader(io, input_buf);
    std.debug.print("Tile size: {d}", .{@sizeOf(chess.Tile)});
}

fn print_board(writer: std.Io.Writer, board: chess.Board) !void {
    _ = board; // autofix
}
