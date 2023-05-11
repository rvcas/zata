const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: usize = 1,
        items: NodeList,
        count: usize,

        const Self = @This();

        pub const SearchResult = union(enum) {
            found: Found,
            not_found,
        };

        const Found = struct {
            location: usize,
            data: T,
        };

        const NodeList = std.ArrayList(?Node);

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
                .items = NodeList.init(allocator),
                .count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn insert(self: *Self, data: T) !void {
            var iter: usize = 0;
            while (true) {
                try self.items.ensureTotalCapacity(iter);

                if (self.items.items[iter]) |node| {
                    if (data == node.data) {
                        break;
                    } else if (data > node.data) {
                        iter = node.right;
                    } else {
                        iter = node.left;
                    }
                } else {
                    try self.items.insert(iter, Node.init(data, iter));
                    self.count += 1;

                    break;
                }
            }
        }

        pub fn map(self: *Self, comptime func: fn (T) T) void {
            for (self.items.items) |*item| {
                if (item.*) |node| {
                    item.*.?.data = func(node.data);
                }
            }
        }

        // TODO: fix the links might need to shift some nodes around
        pub fn delete(self: *Self, data: T) !void {
            switch (self.search(data)) {
                .found => |result| {
                    try self.items.insert(result.location, null);
                    self.count -= 1;
                },
                .not_found => {},
            }
        }

        pub fn search(self: *Self, data: T) SearchResult {
            var iter: usize = 1;
            while (true) {
                if (iter > self.items.capacity) {
                    return .not_found;
                }

                if (self.items.items[iter]) |node| {
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
    };
}

test "BinaryTree.init" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try testing.expectEqual(@as(usize, 0), tree.count);
}

test "BinaryTree.insert" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    try testing.expectEqual(@as(usize, 3), tree.count);
    try testing.expectEqual(@as(i32, 3), tree.items.items[tree.root].?.data);
    try testing.expectEqual(@as(i32, 7), tree.items.items[tree.items.items[tree.root].?.right].?.data);
    try testing.expectEqual(@as(i32, 2), tree.items.items[tree.items.items[tree.root].?.left].?.data);
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
    try testing.expectEqual(@as(i32, 4), tree.items.items[tree.root].?.data);
    try testing.expectEqual(@as(i32, 8), tree.items.items[tree.items.items[tree.root].?.right].?.data);
    try testing.expectEqual(@as(i32, 3), tree.items.items[tree.items.items[tree.root].?.left].?.data);
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

    try tree.delete(3);

    try testing.expectEqual(@as(usize, 4), tree.count);
}
