const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: usize = 1,
        items: []?Node,
        count: usize = 0,
        capacity: usize = 0,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub const SearchResult = union(enum) {
            found: Found,
            not_found,
        };

        const Found = struct {
            location: usize,
            data: T,
        };

        const Node = struct {
            left: usize,
            right: usize,
            location: usize,
            data: T,

            pub fn init(data: T, location: usize) Node {
                return Node{
                    .left = 2 * location,
                    .right = (2 * location) + 1,
                    .location = location,
                    .data = data,
                };
            }
        };

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .items = &[_]?Node{},
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items.ptr[0..self.capacity]);
        }

        pub fn insert(self: *Self, data: T) !void {
            var iter: usize = 1;
            while (true) {
                try self.ensureCapacity(iter);

                if (self.items[iter]) |node| {
                    if (data == node.data) {
                        break;
                    } else if (data > node.data) {
                        iter = node.right;
                    } else {
                        iter = node.left;
                    }
                } else {
                    self.items[iter] = Node.init(data, iter);
                    self.count += 1;

                    break;
                }
            }
        }

        pub fn map(self: *Self, comptime func: fn (T) T) void {
            for (self.items) |*item| {
                if (item.*) |node| {
                    item.*.?.data = func(node.data);
                }
            }
        }

        // TODO: fix the links might need to shift some nodes around
        pub fn delete(self: *Self, data: T) void {
            switch (self.search(data)) {
                .found => |result| {
                    self.items[result.location] = null;
                    self.count -= 1;
                },
                .not_found => {},
            }
        }

        pub fn search(self: *Self, data: T) SearchResult {
            var iter: usize = 1;
            while (true) {
                if (iter > self.capacity) {
                    return .not_found;
                }

                if (self.items[iter]) |node| {
                    if (data == node.data) {
                        return .{ .found = .{ .location = node.location, .data = node.data } };
                    } else if (data > node.data) {
                        iter = node.right;
                    } else {
                        iter = node.left;
                    }
                } else {
                    return .not_found;
                }
            }
        }

        fn ensureCapacity(self: *Self, new_capacity: usize) !void {
            var better_capacity = self.capacity;
            if (better_capacity >= new_capacity) return;

            while (true) {
                better_capacity += better_capacity / 2 + 8;
                if (better_capacity >= new_capacity) break;
            }

            const new_memory = try self.allocator.realloc(self.items.ptr[0..self.capacity], better_capacity);
            self.items.ptr = new_memory.ptr;
            self.capacity = new_memory.len;
            self.items.len = self.capacity;
        }
    };
}

test "BinaryTree.init" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try testing.expectEqual(@as(usize, 0), tree.count);
    try testing.expectEqual(@as(usize, 0), tree.items.len);
}

test "BinaryTree.insert" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    try testing.expectEqual(@as(usize, 3), tree.count);
    try testing.expectEqual(@as(i32, 3), tree.items[tree.root].?.data);
    try testing.expectEqual(@as(i32, 7), tree.items[tree.items[tree.root].?.right].?.data);
    try testing.expectEqual(@as(i32, 2), tree.items[tree.items[tree.root].?.left].?.data);
}

test "BinaryTree.map" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    const addOne = struct {
        fn function(data: i32) i32 {
            return data + 1;
        }
    }.function;

    tree.map(addOne);

    try testing.expectEqual(@as(usize, 3), tree.count);
    try testing.expectEqual(@as(i32, 4), tree.items[tree.root].?.data);
    try testing.expectEqual(@as(i32, 8), tree.items[tree.items[tree.root].?.right].?.data);
    try testing.expectEqual(@as(i32, 3), tree.items[tree.items[tree.root].?.left].?.data);
}

test "BinaryTree.search" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    const SearchResult = BinaryTree(i32).SearchResult;

    try testing.expectEqual(SearchResult.not_found, tree.search(7));

    try tree.insert(5);
    try tree.insert(7);
    try tree.insert(4);

    try testing.expectEqual(SearchResult{
        .found = .{
            .data = 7,
            .location = 3,
        },
    }, tree.search(7));

    try testing.expectEqual(SearchResult{
        .found = .{
            .data = 4,
            .location = 2,
        },
    }, tree.search(4));

    try testing.expectEqual(SearchResult.not_found, tree.search(8));
}

test "BinaryTree.delete" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(4);
    try tree.insert(7);
    try tree.insert(1);
    try tree.insert(3);
    try tree.insert(6);

    try testing.expectEqual(@as(usize, 5), tree.count);

    tree.delete(3);

    try testing.expectEqual(@as(usize, 4), tree.count);
}
