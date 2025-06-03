const std = @import("std");

const ALIVE = "♥";
const DEAD = "‧";

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
    const grid = [3][3][]const u8{
        .{ DEAD, DEAD, DEAD },
        .{ ALIVE, ALIVE, ALIVE },
        .{ DEAD, DEAD, DEAD },
    };
    try writeGrid(@TypeOf(stdout), stdout, grid);
    try bw.flush();

    const grid_cp = calculNextGeneration(grid);

    try writeGrid(@TypeOf(stdout), stdout, grid_cp);
    try bw.flush(); // Don't forget to flush!

}

fn writeGrid(comptime WriterType: type, w: WriterType, grid: [3][3][]const u8) !void {
    for (grid) |row| {
        for (row) |cell| {
            try w.print("{s} ", .{cell});
        }
        try w.print("\n", .{});
    }
}

fn calculNextGeneration(grid: [3][3][]const u8) [3][3][]const u8 {
    // copy grid
    var grid_copy = grid;
    const neighbors = [_][2]isize{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };
    // Calcul next generation
    for (&grid_copy, 0..) |*row, i| {
        for (row, 0..) |*cell, j| {
            var alive_neighbors: usize = 0;

            for (neighbors) |offset| {
                const ni = @as(isize, @intCast(i)) + offset[0];
                const nj = @as(isize, @intCast(j)) + offset[1];

                if (ni < 0 or nj < 0 or ni >= grid.len or nj >= grid[0].len)
                    continue;

                const niu = @as(u8, @intCast(ni));
                const nju = @as(u8, @intCast(nj));

                if (std.mem.eql(u8, grid[niu][nju], ALIVE)) {
                    alive_neighbors += 1;
                }
            }
            if (std.mem.eql(u8, cell.*, DEAD)) {
                if (alive_neighbors == 3) {
                    cell.* = ALIVE;
                }
            }
            if (std.mem.eql(u8, cell.*, ALIVE)) {
                if (alive_neighbors < 2 or alive_neighbors > 3) {
                    cell.* = DEAD;
                }
            }
        }
    }
    return grid_copy;
}

test "blinker start horizontal" {
    const grid = [_][3][]const u8{
        .{ DEAD, DEAD, DEAD },
        .{ ALIVE, ALIVE, ALIVE },
        .{ DEAD, DEAD, DEAD },
    };

    // call CalculateNextGeneration();
    //try std.testing.expect(std.mem.eql(u8, grid[0][0], DEAD));
    //try std.testing.expect(std.mem.eql(u8, grid[0][1], ALIVE));
    //try std.testing.expect(std.mem.eql(u8, grid[0][2], DEAD));
    //try std.testing.expect(std.mem.eql(u8, grid[1][0], DEAD));
    try std.testing.expect(std.mem.eql(u8, grid[1][1], ALIVE));
    //try std.testing.expect(std.mem.eql(u8, grid[1][2], DEAD));
    //try std.testing.expect(std.mem.eql(u8, grid[2][0], DEAD));
    //try std.testing.expect(std.mem.eql(u8, grid[2][1], ALIVE));
    //try std.testing.expect(std.mem.eql(u8, grid[2][2], DEAD));
}

test "blinker start vertical" {}
