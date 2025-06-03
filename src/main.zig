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

const Grid = struct {
    allocator: std.mem.Allocator,
    rows: std.ArrayList(std.ArrayList(u8)),

    pub fn init(allocator: std.mem.Allocator) Grid {
        return Grid{
            .allocator = allocator,
            .rows = std.ArrayList(std.ArrayList(u8)).init(allocator),
       };
    }

    pub fn deinit(self: *Grid) void {
        for (self.rows.items) |*row| {
            row.deinit();
        }
        self.rows.deinit();
    }

    pub fn appendRow(self: *Grid) !void {
        try self.rows.append(std.ArrayList(u8).init(self.allocator));
    }

    pub fn appendToRow(self: *Grid, rowIndex: usize, value: u8) !void {
        if (rowIndex >= self.rows.items.len) return error.IndexOutOfBounds;
        try self.rows.items[rowIndex].append(value);
    }

    pub fn get(self: *Grid, x: usize, y: usize) !u8 {
        if (y >= self.rows.items.len) return error.IndexOutOfBounds;
        const row = self.rows.items[y];
        if (x >= row.items.len) return error.IndexOutOfBounds;
        return row.items[x];
    }

    pub fn set(self: *Grid, x: usize, y: usize, value: u8) !void {
        while (self.rows.items.len <= y) {
            try appendRow(self);
        }

        var row = &self.rows.items[y];

        while (row.items.len <= x) {
            try row.append(0);
        }

        row.items[x] = value;
    }
};

pub fn mama() !void {
    const allocator = std.heap.page_allocator;

    var grid = Grid.init(allocator);
    defer grid.deinit();

    try grid.appendRow();
    try grid.appendRow();
    try grid.appendRow();

    try grid.appendToRow(0, 1);
    try grid.appendToRow(0, 2);
    try grid.appendToRow(0, 3);
    try grid.appendToRow(1, 4);
    try grid.appendToRow(1, 5);
    try grid.appendToRow(1, 6);
    try grid.appendToRow(2, 7);
    try grid.appendToRow(2, 8);

    try grid.set(0, 2, 9);

    for (grid.rows.items) |row| {
        for (row.items) |cell| {
            std.debug.print("{d}", .{cell});
        }
        std.debug.print("\n", .{});
    }
}
