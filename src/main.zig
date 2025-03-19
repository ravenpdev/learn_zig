//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"}); // stdout is for the actual output of your application, for example if you are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!
}

pub fn assignments() void {
    // const indicates that identifier is a constant that store immutable value.
    // var indicates that identifier is a variable that store a mutable value.
    // : type is a type notation for indentifer, and may be omitted if the data type of value can be inferred.

    const constant: i32 = 5; // signed 32-bit constant
    var variable: u32 = 5000; // unsigned 32-bit variable
    variable = 4000;
    std.debug.print("constant: {d}!\n", .{constant});
    std.debug.print("variable: {d}!\n", .{variable});

    // @as performs an explicit type coercsion
    const inferred_constant = @as(i32, 5);
    const inferred_var = @as(u32, 5000);
    std.debug.print("constant: {d}!\n", .{inferred_constant});
    std.debug.print("variable: {d}!\n", .{inferred_var});

    // constant and variable must have a value. if no known value can be given, the undefined value, which coerces
    // to any type, may be used as long as type annotation is provided.
    const a: i32 = undefined;
    const b: u32 = undefined;
    std.debug.print("constant: {d}!\n", .{a});
    std.debug.print("variable: {d}!\n", .{b});
}

pub fn arrays() void {
    // Arrays denoted by [N]T, where N is the number of elements in the array and T is the type of those elements.
    const a = [5]u8{ 'h', 'e', 'l', 'l', 'o' };
    // For array literal, N may be replaced by _ to infer the size of the array.
    const b = [_]u8{ 'w', 'o', 'r', 'l', 'd' };
    std.debug.print("{s}\n", .{a ++ " " ++ b});

    // To get the size of an array, simply access the array's len field.
    const array = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    const length = array.len; // 5
    std.debug.print("{d}\n", .{length});
}

pub fn ifExpression() void {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    std.debug.print("{d}\n", .{x});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

test "always succeeds" {
    try expect(true);
    // try expect(false);
}

test "if statement" {
    const a: bool = true;
    var x: u16 = 0;

    if (a) {
        x += 1;
    } else {
        x += 2;
    }

    try expect(x == 1);
}

test "if statement expression" {
    const a = true;
    var x: u16 = 0;
    x += if (a) 1 else 2;
    try expect(x == 1);
}

test "while loop" {
    // Zig's while loop has three parts - a condition, a block and a continue expression.

    // without a continue expression
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    try expect(i == 128);
}

test "while loop with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    try expect(sum == 55);
}

test "while with continue" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 3) : (i += 1) {
        if (i == 2) {
            continue;
        }
        sum += i;
    }
    try expect(sum == 4);
}

test "while with a break" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 3) : (i += 1) {
        if (i == 2) {
            break;
        }
        sum += i;
    }
    try expect(sum == 1);
}

test "for loops" {
    // For loops are used to iterate over arrays (and other types, to be discussed later). For loops follow this syntax. Like while,
    // for loops can use break, and continue. Here we've has to assign values to _, as Zig does not allow us to have unused values.
    const string = [_]u8{ 'a', 'b', 'c', 'd' };

    for (string, 0..) |char, index| {
        _ = char;
        _ = index;
    }

    for (string) |char| {
        _ = char;
    }

    for (string, 0..) |_, index| {
        _ = index;
    }

    for (string) |_| {}
}

pub fn addFive(x: u32) u32 {
    return x + 5;
}

test "function" {
    // All functions arguments are immjutable - if a copy is desired the user must explicitly make one. Unlike variables,
    // which are snake_case, functions are camelCase.
    const y = addFive(0);

    try expect(@TypeOf(y) == u32);
    try expect(y == 5);
}

pub fn fibonacci(n: u16) u16 {
    // recursion is allowed
    // When recursion happens, the compiler is no longer able to work out the maximum stack size, which may result in unsafe behavior - stack overflow.
    // Details on how to achieve safe recusion will be covered in the future.
    if (n == 0 or n == 1) return n;

    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    const x = fibonacci(10);
    // std.debug.print("{d}", .{x});
    try expect(x == 55);
}

test "defer" {
    // Defer is used to execute a statement upon existing the current block.
    var x: i16 = 5;
    {
        defer x += 2;
        try expect(x == 5);
    }

    try expect(x == 7);
}

test "multi defer" {
    // When ther are multiple defers is a single bloc, they are executed in reverse order.
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
    }
    try expect(x == 4.5);

    // Defer is useful to ensure that resources are cleaned up when they are no longer needed. Instead
    // of needing to remember to manually free up the resource, you can add a defer statement right next
    // to the statement that allocates the resource.
}

test "array" {
    const arr1: [5]u16 = [5]u16{ 1, 2, 3, 4, 5 };
    const arr2: [3]f64 = [_]f64{ 432.1, 86.2, 900.05 };
    try expect(arr1[2] == 3);
    try expect(arr2[1] == 86.2);
}

test "array slice" {
    const arr = [5]u16{ 1, 33, 88, 135, 55 };
    const array_slice = arr[1..];
    try expect(arr[1..] == array_slice);

    // std.debug.print("{any}\n", .{arr[1..]});
    // std.debug.print("{any}\n", .{array_slice});
}

test "more on slices" {
    const arr = [5]u16{ 1, 7, 20, 29, 92 };
    const sl = arr[2..];

    try expect(sl.len == 3);
}

test "array ++ operator" {
    const arr1 = [3]u16{ 1, 2, 3 };
    const arr2 = [3]u16{ 4, 5, 6 };
    const arr3 = arr1 ++ arr2;

    try expect(arr3.len == 6);
    // a string object in Zig is essentially an array of bytes. so you can use this array concatenation operator to concatenate string together
}

test "array ** operator" {
    const arr1 = [3]u16{ 1, 2, 3 };
    const arr2 = arr1 ** 2;
    try expect(arr2.len == 6);
}

test "compile-time slices" {
    const arr1 = [3]u16{ 1, 2, 3 };

    // This slice have compile-time known range.
    // Because we know both the start and end of the range.
    const sl = arr1[1..3];
    try expect(sl.len == 2);
}

pub fn runtimeKnownRange() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var n: usize = 0;

    if (builtin.target.os == .windows) {
        n = 10;
    } else {
        n = 12;
    }

    const buffer = try allocator.alloc(u64, n);
    const slice = buffer[1..];
    _ = slice;
}

// Blocks and scopes
test "blocks" {
    var y: i32 = 123;
    const x = add_one: {
        y += 1;
        break :add_one y;
    };

    if (x == 124 and y == 124) {
        std.debug.print("Hey!\n", .{});
    }
}

// Strings
test "strings" {
    // "A literal string";

    // This is a string object;
    const object: []const u8 = "A string object";
    std.debug.print("{s}\n", .{object});

    const bytes = [_]u8{ 0x48, 0x65, 0x6C, 0x6C, 0x6F };
    std.debug.print("{s}\n", .{bytes});

    const string_object = "This is an example";
    for (string_object) |byte| {
        std.debug.print("{X} ", .{byte});
    }
    std.debug.print("\n", .{});

    std.debug.print("{d}\n", .{string_object.len});
}

test "A better look at object type" {
    const simple_array = [_]i32{ 1, 2, 3, 4 };
    std.debug.print("Type 1: {}\n", .{@TypeOf(simple_array)});

    const string_obj: []const u8 = "A string object";
    std.debug.print("Type 2: {}\n", .{@TypeOf(string_obj)});

    std.debug.print("Type 3: {}\n", .{@TypeOf(&simple_array)});

    std.debug.print("Type 4: {}\n", .{@TypeOf("A string literal")});
}

test "Byte vs unicode points" {
    const string_object = "Ⱥ";

    for (string_object) |char| {
        std.debug.print("{X} ", .{char});
    }
    std.debug.print("\n", .{});
}

test "Iterate through characters of string" {
    var utf8 = try std.unicode.Utf8View.init("アメリカ");
    var iterator = utf8.iterator();

    while (iterator.nextCodepointSlice()) |codepoint| {
        std.debug.print("got codepoint {}\n", .{std.fmt.fmtSliceHexUpper(codepoint)});
    }
}

test "Useful functions for strings" {
    // std.mem.eql() to compoare if two strings are equal.
    // std.mem.splitScalar to split a string into an array of substrings given a delimeter value.
    // std.mem.splitSequence to split a string into an array of substrings given a substring delimiter.
    // std.mem.startsWith() to check if a string starts with a substring
    // std.mem.endswith() to check if a string ends with substring
    // std.mem.trim() to remove specific values from both start and end of the string.
    // std.mem.concat() to concatenate strings together.
    // std.mem.replace() to replace ocurrenes of substring in the string

    const name: []const u8 = "raven";
    std.debug.print("{any}\n", .{std.mem.eql(u8, name, "raven")});
    std.debug.print("{any}\n", .{std.mem.startsWith(u8, name, "ra")});

    const str1 = "Hello";
    const str2 = " you!";

    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = alloc.allocator();
    const str3 = try std.mem.concat(allocator, u8, &[_][]const u8{ str1, str2 });
    std.debug.print("{s}\n", .{str3});

    const str4 = "Hello";
    var buffer: [5]u8 = undefined;
    const nrep = std.mem.replace(u8, str4, "el", "34", buffer[0..]);

    std.debug.print("New string: {s}\n", .{buffer});
    std.debug.print("N of replacements: {d}\n", .{nrep});
}

// Errors
// An error set is like an enum, where each error in the set is a value. There are no exception in Zig; errors are values.
const FileOpenError = error{ AccessDenied, OutOfMemory, FileNotFound };

// Error sets coerce to their supersets
const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

// An error set type and another type can be combined with the ! operator to form an error union type.
// Values of these types may be an error value or a value of the other type.

// Let's create a value of an error union type. Here catch is used, which is followed by an expression
// which is evaluated when the value preceding it is an error. The catch here is used to provide a
// fallback value, but could instead be a noreturn - the type of return, while (true) and others.
test "error union" {
    const maybe_error: AllocationError!u16 = 10;
    const no_error = maybe_error catch 0;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);
}

// Functions often return error unions. Here's one using a catch, where the |err| syntax receives the
// value of the error. This is called payload capturing, and is used similarly in many places.
pub fn failingFunction() error{Oops}!void {
    return error.Oops;
}

test "returning error" {
    failingFunction() catch |err| {
        try expect(err == error.Oops);
        return;
    };
}

const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("learn_zig_lib");
