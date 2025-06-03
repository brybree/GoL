const std = @import("std");

pub fn main() !void {
    // shortcut based on `std.io.getStdErr()`
    // std.debug.print("Conway Game of Life", .{});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Conway Game of Life", .{});

    try stdout.print(
        \\Rules:
        \\ - Alive cells die if they have fewer than two or more than three living neighbors.
        \\ - Dead cells with exactly three living neighbors become alive.
        \\
    , .{});

    try bw.flush();
    const ALIVE = "♥";
    const DEAD = "‧";

    // Lets start with a blinker
    // note: even if the cell is a []const u8, we're mutating the reference
    // stored in the array
    const grid = [_][3][]const u8{
        .{ DEAD, DEAD, DEAD },
        .{ ALIVE, ALIVE, ALIVE },
        .{ DEAD, DEAD, DEAD },
    };
    // Print grid
    for (grid) |row| {
        for (row) |cell| {
            try stdout.print("{s} ", .{cell});
        }
        try stdout.print("\n", .{});
    }

    try bw.flush();

    const neighbors = [_][2]isize{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };

    // Calcul next generation
    for (&grid, 0..) |*row, i| {
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
                    //cell becomes alive
                    std.debug.print("alive ", .{});
                }
            }
            if (std.mem.eql(u8, cell.*, ALIVE)) {
                if (alive_neighbors < 2 or alive_neighbors > 3) {
                    //cell dies
                    std.debug.print("dead ", .{});
                }
            }
        }
    }

    try bw.flush(); // Don't forget to flush!

}

test "blinker start horizontal" {
    const ALIVE: []const u8 = "♥";
    const DEAD: []const u8 = "‧";

    var grid = [_][3][]const u8{
        .{ DEAD, DEAD, DEAD },
        .{ ALIVE, ALIVE, ALIVE },
        .{ DEAD, DEAD, DEAD },
    };

    try std.testing.expect(std.mem.eql(u8, grid[1][1], ALIVE));

    for (&grid) |*row| {
        for (row) |*cell| {
            cell.* = ALIVE;
        }
    }
    try std.testing.expect(std.mem.eql(u8, grid[1][1], ALIVE));
}

test "blinker start vertical" {}

fn dead() []u8 {
    return "♥";
}
