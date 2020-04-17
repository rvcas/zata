const std = @import("std");
const testing = std.testing;

pub fn BinaryTree(comptime T: type) type {
    return struct {
        root: usize = 1,
        items: []?Node,
        count: usize = 0,
        capacity: usize = 0,
        allocator: *std.mem.Allocator,

        const Self = @This();

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

        pub fn init(allocator: *std.mem.Allocator) Self {
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

        pub fn map(self: *Self, func: fn (T) T) void {
            for (self.items) |*item| {
                if (item.*) |node| {
                    item.*.?.data = func(node.data);
                }
            }
        }

        // pub fn delete(self: *Self, data: T) void {
        //     self.root = Node.delete(self.root, self, data);
        // }

        pub fn contains(self: *Self, data: T) bool {
            var iter: usize = 1;
            while (true) {
                if (iter > self.capacity) {
                    return false;
                }

                if (self.items[iter]) |node| {
                    if (data == node.data) {
                        return true;
                    } else if (data > node.data) {
                        iter = node.right;
                    } else {
                        iter = node.left;
                    }
                } else {
                    return false;
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

test "BinaryTree.init method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    testing.expectEqual(@as(usize, 0), tree.count);
    testing.expectEqual(@as(usize, 0), tree.items.len);
}

test "BinaryTree.insert method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    testing.expectEqual(@as(usize, 3), tree.count);
    testing.expectEqual(@as(i32, 3), tree.items[tree.root].?.data);
    testing.expectEqual(@as(i32, 7), tree.items[tree.items[tree.root].?.right].?.data);
    testing.expectEqual(@as(i32, 2), tree.items[tree.items[tree.root].?.left].?.data);
}

test "BinaryTree.map method" {
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

    testing.expectEqual(@as(usize, 3), tree.count);
    testing.expectEqual(@as(i32, 4), tree.items[tree.root].?.data);
    testing.expectEqual(@as(i32, 8), tree.items[tree.items[tree.root].?.right].?.data);
    testing.expectEqual(@as(i32, 3), tree.items[tree.items[tree.root].?.left].?.data);
}

test "BinaryTree.contains method" {
    var tree = BinaryTree(i32).init(testing.allocator);
    defer tree.deinit();

    testing.expect(!tree.contains(7));

    try tree.insert(3);
    try tree.insert(7);
    try tree.insert(2);

    testing.expect(tree.contains(7));
    testing.expect(tree.contains(2));
    testing.expect(!tree.contains(8));
}

// test "BinaryTree.delete method" {
//     var tree = BinaryTree(i32).init(testing.allocator);
//     defer tree.deinit();

//     try tree.insert(4);
//     try tree.insert(7);
//     try tree.insert(1);
//     try tree.insert(3);
//     try tree.insert(6);

//     testing.expectEqual(tree.count, 5);
//     testing.expectEqual(tree.root.?.data, 4);

//     tree.delete(4);

//     testing.expectEqual(tree.count, 4);
//     testing.expectEqual(tree.root.?.data, 6);
// }
