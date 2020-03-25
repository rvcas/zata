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

pub fn fib_lin(n: u64, map: *std.AutoHashMap(u64, u64)) u64 {
    // limit to 256 max fib number. 
    var i : u8 = 2;
    while(i <= n): (i += 1) {
        _ =  map.put(i, map.getValue(i - 1).? + map.getValue(i - 2).?) catch unreachable;
    }
    return map.getValue(n).?;
}    

pub fn fib_dyn(n: u64) u64 {
    var f0: u64  = 0;
    var f1: u64  = 1;
    var sum: u64 = 0; 
    var i: u8 = 0;
    
    while(i <= n): (i += 1) {
        sum = f0 + f1;
        f1 = f0;
        f0 = sum;
    }

    return sum;
}



test "dynamic" {
    assert(fib(8) == 21);
}

test "memorization" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();
    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;
    assert(fib_mem(8, &map) == 21);

}

test "linear memorization" {
    var map = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer map.deinit();
    _ = map.put(0, 0) catch unreachable;
    _ = map.put(1, 1) catch unreachable;
    assert(fib_lin(8, &map) == 21);   
}


test "fib dynamic programming goal" {
    assert(fib_dyn(8) == 21);
}
