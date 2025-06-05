const std = @import("std");

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
};

const expect = std.testing.expect;

test "blinker start horizontal" {
    // Lets start with a blinker
    const allocator = std.heap.page_allocator;

    var grid = Grid.init(allocator);
    defer grid.deinit();

    try grid.set(0, 0, false);
    try grid.set(1, 0, false);
    try grid.set(2, 0, false);
    try grid.set(0, 1, true);
    try grid.set(1, 1, true);
    try grid.set(2, 1, true);
    try grid.set(0, 2, false);
    try grid.set(1, 2, false);
    try grid.set(2, 2, false);
}

test "blinker start vertical" {}
