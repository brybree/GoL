const grid = @import("grid.zig");

const ALIVE = "♥";
const DEAD = "‧";

pub fn writeGrid(comptime WriterType: type, w: WriterType, grid_arg: grid.Grid) !void {
    try w.print("\n", .{});
    for (grid_arg.rows.items) |row| {
        for (row.items) |cell| {
            const symbol = if (cell == true) ALIVE else DEAD;
            try w.print("{s} ", .{symbol});
        }
        try w.print("\n", .{});
    }
}
