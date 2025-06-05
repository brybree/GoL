const std = @import("std");
const display = @import("display.zig");
const grid = @import("grid.zig");
const Grid = grid.Grid;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
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

    // Lets start with a blinker
    const allocator = std.heap.page_allocator;

    var main_grid = Grid.init(allocator);
    defer main_grid.deinit();

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

    const neighbors = [_][2]isize{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };

    var gridcp = try main_grid.clone();
    defer gridcp.deinit();

    for (gridcp.rows.items, 0..) |row, row_index| {
        for (row.items, 0..) |cell, cell_index| {
            var alive_neighbors: usize = 0;

            for (neighbors) |offset| {
                const ni = @as(isize, @intCast(cell_index)) + offset[0];
                const nj = @as(isize, @intCast(row_index)) + offset[1];

                // check for boundaries
                if (ni < 0 or nj < 0)
                    continue;

                const niu = @as(u8, @intCast(ni));
                const nju = @as(u8, @intCast(nj));

                // check for boundaries
                if (nju >= gridcp.rows.items.len) continue;
                const tmp_row = gridcp.rows.items[nju];
                if (niu >= tmp_row.items.len) continue;

                if (try gridcp.get(niu, nju) == true) {
                    alive_neighbors += 1;
                }
            }

            if (cell == false) {
                if (alive_neighbors == 3) {
                    try main_grid.set(cell_index, row_index, true);
                }
            }
            if (cell == true) {
                if (alive_neighbors < 2 or alive_neighbors > 3) {
                    try main_grid.set(cell_index, row_index, false);
                }
            }
        }
    }
    try display.writeGrid(@TypeOf(stdout), stdout, main_grid);
    try bw.flush();
}

//fn calculNextGeneration(grid: Grid) Grid {}
