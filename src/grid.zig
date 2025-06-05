const std = @import("std");

const neighbors = [_][2]isize{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
    .{ 1, 0 },   .{ 1, 1 },
};

// True values are alive cell
// False values are dead cell
pub const Grid = struct {
    allocator: std.mem.Allocator,
    rows: std.ArrayList(std.ArrayList(bool)),

    pub fn init(allocator: std.mem.Allocator) Grid {
        return Grid{
            .allocator = allocator,
            .rows = std.ArrayList(std.ArrayList(bool)).init(allocator),
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
            var new_row = std.ArrayList(bool).init(self.allocator);
            try new_row.appendSlice(row.items);
            try new_grid.rows.append(new_row);
        }
        return new_grid;
    }

    pub fn appendRow(self: *Grid) !void {
        try self.rows.append(std.ArrayList(bool).init(self.allocator));
    }

    pub fn appendToRow(self: *Grid, rowIndex: usize, value: bool) !void {
        if (rowIndex >= self.rows.items.len) return error.IndexOutOfBounds;
        try self.rows.items[rowIndex].append(value);
    }

    pub fn get(self: *Grid, x: usize, y: usize) !bool {
        if (y >= self.rows.items.len) return error.IndexOutOfBounds;
        const row = self.rows.items[y];
        if (x >= row.items.len) return error.IndexOutOfBounds;
        return row.items[x];
    }

    pub fn set(self: *Grid, x: usize, y: usize, value: bool) !void {
        while (self.rows.items.len <= y) {
            try appendRow(self);
        }

        var row = &self.rows.items[y];

        while (row.items.len <= x) {
            try row.append(false);
        }

        row.items[x] = value;
    }

    pub fn evolveToNextGeneration(self: *Grid) !void {
        var gridcp = try self.clone();
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
                        try self.set(cell_index, row_index, true);
                    }
                }
                if (cell == true) {
                    if (alive_neighbors < 2 or alive_neighbors > 3) {
                        try self.set(cell_index, row_index, false);
                    }
                }
            }
        }
    }
};

const expectEqual = std.testing.expectEqual;

test "blinker start horizontal" {
    const allocator = std.heap.page_allocator;

    var grid = Grid.init(allocator);
    defer grid.deinit();

    // horizontal blinker
    try grid.set(0, 0, false);
    try grid.set(1, 0, false);
    try grid.set(2, 0, false);
    try grid.set(0, 1, true);
    try grid.set(1, 1, true);
    try grid.set(2, 1, true);
    try grid.set(0, 2, false);
    try grid.set(1, 2, false);
    try grid.set(2, 2, false);

    try grid.evolveToNextGeneration();

    // should become a vertical blinker
    try expectEqual(try grid.get(0, 0), false);
    try expectEqual(try grid.get(1, 0), true);
    try expectEqual(try grid.get(2, 0), false);
    try expectEqual(try grid.get(0, 1), false);
    try expectEqual(try grid.get(1, 1), true);
    try expectEqual(try grid.get(2, 1), false);
    try expectEqual(try grid.get(0, 2), false);
    try expectEqual(try grid.get(1, 2), true);
    try expectEqual(try grid.get(2, 2), false);
}

test "blinker start vertical" {
    const allocator = std.heap.page_allocator;

    var grid = Grid.init(allocator);
    defer grid.deinit();

    // vertical blinker
    try grid.set(0, 0, false);
    try grid.set(1, 0, true);
    try grid.set(2, 0, false);
    try grid.set(0, 1, false);
    try grid.set(1, 1, true);
    try grid.set(2, 1, false);
    try grid.set(0, 2, false);
    try grid.set(1, 2, true);
    try grid.set(2, 2, false);

    try grid.evolveToNextGeneration();

    // should become a vertical blinker
    try expectEqual(try grid.get(0, 0), false);
    try expectEqual(try grid.get(1, 0), false);
    try expectEqual(try grid.get(2, 0), false);
    try expectEqual(try grid.get(0, 1), true);
    try expectEqual(try grid.get(1, 1), true);
    try expectEqual(try grid.get(2, 1), true);
    try expectEqual(try grid.get(0, 2), false);
    try expectEqual(try grid.get(1, 2), false);
    try expectEqual(try grid.get(2, 2), false);
}
