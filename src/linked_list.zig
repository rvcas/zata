const std = @import("std");
const testing = std.testing;

pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*Node,
        tail: ?*Node,
        len: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,

            pub fn init(value: T) Node {
                return Node{
                    .prev = null,
                    .next = null,
                    .data = value,
                };
            }
        };

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .tail = null,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.head == null and self.tail == null) return;

            while (self.len > 0) {
                var prev = self.tail.?.prev;

                if (self.tail) |tail| {
                    self.allocator.destroy(tail);
                }

                self.tail = prev;

                self.len -= 1;
            }

            self.head = null;
        }

        pub fn insert(self: *Self, data: T) !void {
            var newNode = try self.allocator.create(Node);
            errdefer self.allocator.destroy(newNode);

            newNode.* = Node.init(data);

            if (self.head) |head| {
                newNode.next = head;
                head.prev = newNode;
            } else {
                self.tail = newNode;
            }

            self.head = newNode;

            self.len += 1;
        }

        pub fn append(self: *Self, data: T) !void {
            var newNode = try self.allocator.create(Node);
            errdefer self.allocator.destroy(newNode);

            newNode.* = Node.init(data);

            if (self.tail) |tail| {
                newNode.prev = tail;
                tail.next = newNode;
            } else {
                self.head = newNode;
            }

            self.tail = newNode;
            self.len += 1;
        }

        pub fn map(self: *Self, comptime func: fn (T) T) void {
            var iter = self.head;

            while (iter) |node| {
                node.data = func(node.data);

                iter = node.next;
            }
        }

        pub fn contains(self: *Self, data: T) bool {
            var iter = self.head;

            while (iter) |node| {
                if (node.data == data) {
                    return true;
                }

                iter = node.next;
            } else {
                return false;
            }
        }

        pub fn delete(self: *Self) ?T {
            if (self.tail) |tail| {
                var data = tail.data;
                var prev = tail.prev;

                self.allocator.destroy(tail);
                self.len -= 1;

                self.tail = prev;

                if (prev == null) {
                    self.head = null;
                }

                return data;
            } else {
                return null;
            }
        }
    };
}

test "LinkedList basic init" {
    const list = LinkedList(i32){
        .head = null,
        .tail = null,
        .len = 0,
        .allocator = testing.allocator,
    };

    try testing.expect(list.len == 0);
}

test "LinkedList.init method" {
    const list = LinkedList(i32).init(testing.allocator);

    try testing.expectEqual(list.len, 0);
    try testing.expect(list.head == null);
    try testing.expect(list.tail == null);
}

test "LinkedList.insert method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.insert(8);

    try testing.expectEqual(list.len, 1);
    try testing.expect(list.head != null);
    try testing.expect(list.tail != null);
    try testing.expectEqual(list.tail, list.head);

    try list.insert(3);

    try testing.expectEqual(list.len, 2);
    try testing.expect(list.head != list.tail);
    try testing.expectEqual(list.head.?.data, 3);
    try testing.expectEqual(list.tail.?.data, 8);
}

test "LinkedList.append method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.append(4);

    try testing.expectEqual(list.len, 1);
    try testing.expect(list.head != null);
    try testing.expect(list.tail != null);
    try testing.expectEqual(list.tail, list.head);

    try list.append(7);

    try testing.expectEqual(list.len, 2);
    try testing.expect(list.head != list.tail);
    try testing.expectEqual(list.head.?.data, 4);
    try testing.expectEqual(list.tail.?.data, 7);
}

test "LinkedList.map method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.insert(2);
    try list.insert(3);

    const multThree = struct {
        fn function(data: i32) i32 {
            return data * 3;
        }
    }.function;

    list.map(multThree);

    try testing.expectEqual(list.len, 2);
    try testing.expectEqual(list.head.?.data, 9);
    try testing.expectEqual(list.tail.?.data, 6);
}

test "LinkedList.contains method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.insert(11);

    try testing.expect(list.contains(11));
    try testing.expect(!list.contains(7));
}

test "LinkedList.deinit method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.append(4);
    try list.append(100);

    try testing.expectEqual(list.len, 2);

    list.deinit();

    try testing.expectEqual(list.len, 0);
    try testing.expectEqual(list.head, list.tail);
}

test "LinkedList.delete method" {
    var list = LinkedList(i32).init(testing.allocator);
    defer list.deinit();

    try list.append(5);
    try list.insert(8);
    try list.append(9);

    try testing.expectEqual(list.delete(), 9);
    try testing.expectEqual(list.delete(), 5);
    try testing.expectEqual(list.delete(), 8);
    try testing.expectEqual(list.len, 0);
}
