const std = @import("std");

pub const command = @import("command.zig");

pub const Piece = packed struct {
    class: Class,
    // use nonzero to allow a u8 holding 0 to be null
    // we have the spare space
    team: NonZeroTeam,
};

pub const TileEnum = undefined;

fn create_pawnrow(team: Team) Row {
    return @splat(Tile{ .Piece = .{ .team = .from_Team(team), .class = .pawn } });
}
fn create_backrow(team: Team) Row {
    var rook_knight_bishop: [3]Tile = undefined;
    for (&rook_knight_bishop, [_]Class{ .rook, .knight, .bishop }) |*piece, class| {
        piece.* = .{ .Piece = .{ .team = .from_Team(team), .class = class } };
    }

    // colum of piece
    // 01234567
    // rkbKqbkr
    var row: [8]Tile = undefined;
    for ([2]Coordinate{ 0, 5 }) |offset| {
        @memcpy(row[offset..][0..rook_knight_bishop.len], &rook_knight_bishop);
        std.mem.reverse(Tile, &rook_knight_bishop);
    }
    for (row[rook_knight_bishop.len..][0..2], [_]Class{ .queen, .king }) |*piece, class| {
        piece.* = .{ .Piece = .{ .class = class, .team = .from_Team(team) } };
    }

    return row;
}
fn create_board() Board {
    const empty_row = [_]Tile{.{ .Empty = 0 }} ** 8;

    var board: Board = @splat(empty_row);
    board[0] = create_backrow(.White);
    board[1] = create_pawnrow(.White);
    board[6] = create_pawnrow(.Black);
    board[7] = create_backrow(.Black);

    return board;
}

pub const Class = enum(u3) {
    /// is 1 to allow a u3 of 0 to be null
    queen = 1,
    knight,
    rook,
    bishop,
    pawn,
    king,

    pub fn from(other: anytype) Class {
        // comptime std.debug.assert(is_enum_to_enum_safe(@TypeOf(other), Class));

        return @enumFromInt(@intFromEnum(other) + 1);
    }
    test from {
        const promotion_enums = @typeInfo(promote).@"struct".decls;

        for (promotion_enums) |decl| {
            std.log.info("testing '{s}'", .{decl.name});
            const Enum: type = @field(type, decl.name);

            const classes, const promotions = .{ std.enums.values(Class), std.enums.values(Enum) };
            const min = @min(classes.len, promotions.len);
            for (classes[0..min], promotions[0..min]) |expected, other| {
                try std.testing.expectEqual(expected, Class.from(other));
            }
        }
    }
};
pub const promote = struct {
    pub const PromoteTarget = enum(u2) {
        queen,
        knight,
        rook,
        bishop,
    };
    /// For games where stalemates are excluded
    pub const ReducedPromoteTarget = enum(u1) {
        queen,
        knight,
    };
};

fn is_enum_to_enum_safe(A: type, B: type) bool {
    const a_variants = std.meta.fields(A);
    const b_variants = std.meta.fields(B);

    const len = @min(a_variants.len, b_variants.len);
    inline for (a_variants[0..len], b_variants[0..len]) |a, b| {
        if (a != b) return false;
    }
    return true;
}

pub const NonZeroTeam = enum(u2) {
    White = 1,
    Black,

    pub fn from_Team(team: Team) NonZeroTeam {
        return @enumFromInt(@intFromEnum(team) + @as(u2, 1));
    }
};

pub const Team = enum {
    White,
    Black,
    pub fn toggle_color(self: *Team) void {
        comptime std.debug.assert(@typeInfo(Team).@"enum".tag_type == u1);
        self.* = @enumFromInt(~@intFromEnum(self.*));
    }

    pub fn from_NonZero(team: NonZeroTeam) Team {
        return @enumFromInt(@intFromEnum(team) - 1);
    }
};

pub const Empty = enum(@typeInfo(Piece).@"struct".backing_integer.?) {
    empty = 0,
};
pub const Tile = packed union {
    Piece: Piece,
    Empty: Empty,

    fn is_empty(self: Tile) bool {
        return @as(u8, @bitCast(self)) == 0;
    }
};
pub const Row = [8]Tile;
pub const Board = [8][8]Tile;
pub const start_board: Board = create_board();

pub const Coordinate = u3;
pub const Coordinates = struct { row: Coordinate, column: Coordinate };

pub const Game_Type = enum(u1) {
    /// Includes stalemates
    Normal,
    /// Excludes stalemates
    Reduced,
};

test "Tile size is u8" {
    try std.testing.expectEqual(1, @sizeOf(Tile));
}
