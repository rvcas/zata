const std = @import("std");
const testing = std.testing;

pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*Node,
        tail: ?*Node,
        len: usize,
        allocator: *std.mem.Allocator,

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

        pub fn init(allocator: *std.mem.Allocator) Self {
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

                self.allocator.destroy(self.tail);

                self.tail = prev;

                self.len -= 1;
            }

            self.head = null;
        }

        pub fn append(self: *Self, data: T) !void {
            var newNode = try self.allocator.create(Node);
            defer self.allocator.destroy(newNode);

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
    };
}

test "LinkedLink basic init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const list = LinkedList(i32){
        .head = null,
        .tail = null,
        .len = 0,
        .allocator = allocator,
    };

    testing.expect(list.len == 0);
}

test "LinkedList.init method" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const list = LinkedList(i32).init(allocator);

    testing.expectEqual(list.len, 0);
    testing.expect(list.head == null);
    testing.expect(list.tail == null);
}

test "LinkedList.append method" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var list = LinkedList(i32).init(allocator);

    try list.append(4);

    testing.expectEqual(list.len, 1);
    testing.expect(list.head != null);
    testing.expect(list.tail != null);
    testing.expectEqual(list.tail, list.head);

    try list.append(7);

    testing.expectEqual(list.len, 2);
    testing.expect(list.head != list.tail);
    testing.expectEqual(list.head.?.data, 4);
    testing.expectEqual(list.tail.?.data, 7);
}

test "LinkedList.deinit method" {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var list = LinkedList(i32).init(allocator);

    try list.append(4);
    try list.append(100);

    testing.expectEqual(list.len, 2);

    list.deinit();

    testing.expectEqual(list.len, 0);
    testing.expectEqual(list.head, list.tail);
}
