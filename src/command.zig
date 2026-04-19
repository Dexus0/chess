const chess = @import("chess");
const Coordinates = chess.Coordinates;

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
        pub fn send_command(command: C) !void {
            switch (command) {
                .move => |move| execute_move(move),
                .promote => |target| execute_promote(target),
            }
        }
        fn execute_move(move: Move) !void {}
        fn execute_promote(target: PromoteTarget) !void {}

        last_command: C = Move{ .from = 0, .to = 0 },
        board: chess.Board align(@sizeOf(chess.Board)) = chess.start_board,
        turn: usize = 0,
    };
}
