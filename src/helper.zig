const std = @import("std");

const Type = std.builtin.Type;
const EnumField = Type.EnumField;

/// Creates an enum containing all possible states of a struct
///
/// Created enum layout allows for bitcasting between packed struct and enum
pub fn TransparentEnumFromStruct(T: type) type {
    return @Type(EnumInfoFromStruct(T));
}
pub fn EnumInfoFromStruct(T: type) Type.Enum {
    comptime var ret_enum: Type.Enum = .{ .fields = .{.{}}, .is_exhaustive = true, .tag_type = u0 };

    const info_type = @typeInfo(T);
    switch (info_type) {
        .int => for (0..std.math.maxInt(T) + 1) |value| {
            ret_enum.fields = ret_enum.fields ++ EnumField{ .value = value, .name = std.fmt.comptimePrint("{d}", .{value}) };
        },
        .@"struct" => |s| {
            const backing_int = s.backing_integer.?;
            if (@typeInfo(backing_int).int.bits == 0) return EnumInfoFromStruct(backing_int);

            var bitoffset = 0;
            var fields: []EnumField = .{};
            for (s.fields) |field| {
                const field_info = @typeInfo(field.type);

                fields = fields ++ ret: switch (field_info) {
                    else => continue :ret EnumInfoFromStruct(field.type),
                    // .@"struct" => continue :ret EnumInfoFromStruct(field.type),
                    // .int => continue :ret EnumInfoFromStruct(field.type),
                    .@"enum" => |e| {
                        const enum_fields = e.fields;
                        for (enum_fields) |*subfield| {
                            subfield.value <<= bitoffset;
                            subfield.name = field.name ++ '_' ++ subfield.name;
                        }
                        bitoffset += @bitSizeOf(e.tag_type);
                        ret_enum = ret_enum ++ enum_fields;
                    },
                };
            }
            ret_enum.fields = fields;
        },
        else => @compileError("type: '" ++ @tagName(info_type) ++ "' not supported"),
    }
    return ret_enum;
}

test TransparentEnumFromStruct {
    const NonZero = enum(u3) {
        B = 1,
        C,
    };
    const Struct = packed struct {
        b: NonZero,
        c: NonZero,
    };

    const Transparent = TransparentEnumFromStruct(Struct);

    // 2026-03-27
    // After writing all this it has occured to me that 'TransparentEnumFromStruct' might be useless for me.
    // As there is a much simpler solution, in the form of unions with u0.
    // const Union = packed union {
    //     Struct: Struct,
    //     Null: u0,
    // };
    const expected: u6 = @bitCast(Struct{ .b = .B, .c = .C });
    const actual: u6 = @bitCast(Transparent.b_B);

    try std.testing.expectEqual(expected, actual);
}
