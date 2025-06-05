const std = @import("std");
const display = @import("display.zig");
const grid = @import("grid.zig");
const Grid = grid.Grid;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(
        \\Conway Game of Life simulation
        \\Rules:
        \\ - Alive cells die if they have fewer than two or more than three living neighbors.
        \\ - Dead cells with exactly three living neighbors become alive.
        \\
    , .{});

    try bw.flush();

    const allocator = std.heap.page_allocator;

    var main_grid = Grid.init(allocator);
    defer main_grid.deinit();

    const cols = std.crypto.random.intRangeAtMost(u8, 3, 10);
    const rows = std.crypto.random.intRangeAtMost(u8, 3, 10);

    for (0..cols) |col| {
        for (0..rows) |row| {
            try main_grid.set(col, row, std.crypto.random.boolean());
        }
    }

    try display.writeGrid(@TypeOf(stdout), stdout, main_grid);
    try bw.flush();

    try main_grid.evolveToNextGeneration();

    try display.writeGrid(@TypeOf(stdout), stdout, main_grid);
    try bw.flush();
}
