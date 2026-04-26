const chess = @import("chess.zig");
const Coordinates = chess.Coordinates;
const Piece = chess.Piece;

const Game_Type = chess.Game_Type;
const promote = chess.promote;

pub fn Command(game_type: Game_Type) type {
    return union(enum) {
        move: Move,
        /// must be used after a move command
        promote: switch (game_type) {
            .Normal => promote.PromoteTarget,
            .Reduced => promote.ReducedPromoteTarget,
        },
    };
}

const Move = struct {
    from: Coordinates,
    to: Coordinates,
};

pub fn Game(game_type: Game_Type) type {
    const C = Command(game_type);
    const PromoteTarget = @FieldType(C, "promote");

    return struct {
        const Self = @This();
        pub fn parse_command(self: Self, command: C) !void {
            try switch (command) {
                .move => |move| send_move(move),
                .promote => |target| send_promote(self, target),
            };
            self.last_valid_command = command;
        }
        fn send_move(move: Move) !void {
            _ = move; // autofix

        }
        fn send_promote(self: *Self, target: PromoteTarget) !void {
            const last_move = switch (self.last_valid_command) {
                .move => |move| move.to,
                else => return error.NoMoveBeforePromote,
            };
            const enemy_backrow_coord = ~(self.turn % 2) * 7;
            const moved_piece = &self.board[last_move.row][last_move.column].piece;

            if (last_move.row == enemy_backrow_coord and moved_piece.class == .pawn)
                moved_piece.class = .from(target)
            else
                return error.NoPawnInEnemyBackrow;
        }

        last_valid_command: C = Move{ .from = 0, .to = 0 },
        board: chess.Board align(@sizeOf(chess.Board)) = chess.start_board,
        turn: usize = 0,
    };
}
