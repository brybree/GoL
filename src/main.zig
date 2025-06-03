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
    const allocator = std.heap.page_allocator;

    var grid = Grid.init(allocator);
    defer grid.deinit();

    try grid.set(0, 0, DEAD);
    try grid.set(1, 0, DEAD);
    try grid.set(2, 0, DEAD);
    try grid.set(0, 1, ALIVE);
    try grid.set(1, 1, ALIVE);
    try grid.set(2, 1, ALIVE);
    try grid.set(0, 2, DEAD);
    try grid.set(1, 2, DEAD);
    try grid.set(2, 2, DEAD);

    try writeGrid(@TypeOf(stdout), stdout, grid);
    try bw.flush();

    const neighbors = [_][2]isize{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
        .{ 1, 0 },   .{ 1, 1 },
    };

    var gridcp = try grid.clone();
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

                if (std.mem.eql(u8, try gridcp.get(niu, nju), ALIVE)) {
                    alive_neighbors += 1;
                }
            }

            if (std.mem.eql(u8, cell, DEAD)) {
                if (alive_neighbors == 3) {
                    try grid.set(cell_index, row_index, ALIVE);
                }
            }
            if (std.mem.eql(u8, cell, ALIVE)) {
                if (alive_neighbors < 2 or alive_neighbors > 3) {
                    try grid.set(cell_index, row_index, DEAD);
                }
            }
        }
    }
    try writeGrid(@TypeOf(stdout), stdout, grid);
    try bw.flush();
}

fn writeGrid(comptime WriterType: type, w: WriterType, grid: Grid) !void {
    try w.print("\n", .{});
    for (grid.rows.items) |row| {
        for (row.items) |cell| {
            try w.print("{s} ", .{cell});
        }
        try w.print("\n", .{});
    }
}

//fn calculNextGeneration(grid: Grid) Grid {}

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
    rows: std.ArrayList(std.ArrayList([]const u8)),

    pub fn init(allocator: std.mem.Allocator) Grid {
        return Grid{
            .allocator = allocator,
            .rows = std.ArrayList(std.ArrayList([]const u8)).init(allocator),
        };
    }

    pub fn deinit(self: *Grid) void {
        for (self.rows.items) |*row| {
            row.deinit();
        }
        self.rows.deinit();
    }

    pub fn clone(self: *Grid) !Grid {
        var new_grid = Grid.init(self.allocator);

        for (self.rows.items) |row| {
            var new_row = std.ArrayList([]const u8).init(self.allocator);
            try new_row.appendSlice(row.items);
            try new_grid.rows.append(new_row);
        }
        return new_grid;
    }

    pub fn appendRow(self: *Grid) !void {
        try self.rows.append(std.ArrayList([]const u8).init(self.allocator));
    }

    pub fn appendToRow(self: *Grid, rowIndex: usize, value: []const u8) !void {
        if (rowIndex >= self.rows.items.len) return error.IndexOutOfBounds;
        try self.rows.items[rowIndex].append(value);
    }

    pub fn get(self: *Grid, x: usize, y: usize) ![]const u8 {
        if (y >= self.rows.items.len) return error.IndexOutOfBounds;
        const row = self.rows.items[y];
        if (x >= row.items.len) return error.IndexOutOfBounds;
        return row.items[x];
    }

    pub fn set(self: *Grid, x: usize, y: usize, value: []const u8) !void {
        while (self.rows.items.len <= y) {
            try appendRow(self);
        }

        var row = &self.rows.items[y];

        while (row.items.len <= x) {
            try row.append(DEAD);
        }

        row.items[x] = value;
    }
};
