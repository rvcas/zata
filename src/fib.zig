const std = @import("std");
const assert = std.debug.assert;

pub fn fib(n: u64) u64 {
    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }

    return fib(n - 1) + fib(n - 2);
}


pub fn fib_mem(n: u64, map: *std.AutoHashMap(u64,u64)) u64 {
    if (map.contains(n)) {
        return map.getValue(n) orelse 0;
    }

    var x: u64 = fib(n - 1) + fib(n - 2);
    _  = map.put(n, x) catch unreachable;

    return x;
}

test "fib(21)" {
pub fn fib_lin(n: u64, map: *std.AutoHashMap(u64, u64)) u64 {
    // limit to 256 max fib number. 
    var i : u8 = 2;
    while(i <= n): (i += 1) {
        _ =  map.put(i, map.getValue(i - 1).? + map.getValue(i - 2).?) catch unreachable;
    }
    return map.getValue(n).?;
}    
    assert(fib(21) == 10946);
test "memorization" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();
    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;
    assert(fib_mem(21, &map) == 10946);

}

test "linear memorization" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();
    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;
    assert(fib_lin(21, &map) == 10946);   
}

}
