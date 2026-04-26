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
        fn send_promote(self: Self, target: PromoteTarget) !void {
            if (self.last_valid_command != Move) return error.NoMoveBeforePromote;

            const promotee = for (self.board[7 * ~(self.turn % 2)]) |*tile| switch (tile) {
                Piece => |*piece| if (piece.class == .pawn) break piece,
            } else return error.NoPawnInEnemyBackline;

            promotee.class = .from(target);
        }

        last_valid_command: C = Move{ .from = 0, .to = 0 },
        board: chess.Board align(@sizeOf(chess.Board)) = chess.start_board,
        turn: usize = 0,
    };
}
