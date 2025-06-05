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

    // Lets start with a blinker
    try main_grid.set(0, 0, false);
    try main_grid.set(1, 0, false);
    try main_grid.set(2, 0, false);
    try main_grid.set(0, 1, true);
    try main_grid.set(1, 1, true);
    try main_grid.set(2, 1, true);
    try main_grid.set(0, 2, false);
    try main_grid.set(1, 2, false);
    try main_grid.set(2, 2, false);

    try display.writeGrid(@TypeOf(stdout), stdout, main_grid);
    try bw.flush();

    try main_grid.evolveToNextGeneration();

    try display.writeGrid(@TypeOf(stdout), stdout, main_grid);
    try bw.flush();
}
