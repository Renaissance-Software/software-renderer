const std = @import("std");
const panic = std.debug.panic;
const print = std.debug.print;

const width = 256;
const height = 256;
var image: [height][width][3]i32 = undefined;

const Color = extern union
{
    rgb: RGB,
    v: [3]f32,

    const RGB = struct
    {
        r: f32,
        g: f32,
        b: f32,
    };
};

pub fn foo1() void
{
    var image: [256][256][3]i32 = undefined;
    const image_bytes = std.mem.sliceAsBytes(&image);
    const array_size = @sizeOf(i32) * 256 * 256 * 3;
    print("Size of image: {}\n", .{array_size});
    print("Byte count: {}\n", .{image_bytes.len});

    var height_i : i64 = height - 1;
    while (height_i >= 0) : (height_i -= 1)
    {
        var width_i : i64 = 0;
        while (width_i < width) : (width_i += 1)
        {
            const r = @intToFloat(f32, width_i) / (width - 1);
            const g = @intToFloat(f32, height_i) / (height - 1);
            const b = 0.25;

            const ir = @floatToInt(i32, 255.999 * r);
            const ig = @floatToInt(i32, 255.999 * g);
            const ib = @floatToInt(i32, 255.999 * b);

            const height_index = @intCast(usize, height_i);
            const width_index = @intCast(usize, width_i);
            //image[height_index][width_index][0] = ir;
            //image[height_index][width_index][1] = ig;
            //image[height_index][width_index][2] = ib;
            //
            image[height_index][width_index][0] = ir;
            image[height_index][width_index][1] = ig;
            image[height_index][width_index][2] = ib;
        }
    }

    const file_handle = try std.fs.cwd().createFile("image.ppm", .{});
    defer file_handle.close();

    const file_writer = file_handle.writer();

    try std.fmt.format(file_writer, "P3\n{} {}\n255\n", .{width, height});

    for (image) |arr|
    {
        for (arr) |arr2|
        {
            try std.fmt.format(file_writer, "{} {} {}\n", .{arr2[0], arr2[1], arr2[2]});
        }
    }
}

fn write_color(color: Color, w: i64, h: i64) void
{
    const r = @intToFloat(f32, w) / (width - 1);
    const g = @intToFloat(f32, h) / (height - 1);
    const b = 0.25;

    const ir = @floatToInt(i32, 255.999 * r);
    const ig = @floatToInt(i32, 255.999 * g);
    const ib = @floatToInt(i32, 255.999 * b);

    const height_index = @intCast(usize, h);
    const width_index = @intCast(usize, w);

    image[height_index][width_index][0] = ir;
    image[height_index][width_index][1] = ig;
    image[height_index][width_index][2] = ib;
}

pub fn abstracted() anyerror!void
{
    print("Byte count: {}\n", .{@sizeOf(@TypeOf(image))});

    //var height_i : i64 = height - 1;
    //while (height_i >= 0) : (height_i -= 1)
    var height_i: i64 = 0;
    while (height_i < height) : (height_i += 1)
    {
        var width_i: i64 = 0;
        while (width_i < width) : (width_i += 1)
        {
            const color = Color { .v = [3]f32 { @intToFloat(f32, width_i) / (width - 1), @intToFloat(f32, height_i) / (height - 1), 0.25 } };
            write_color(color, width_i, height_i);
        }
    }

    const file_handle = try std.fs.cwd().createFile("image.ppm", .{});
    defer file_handle.close();

    const file_writer = file_handle.writer();

    try std.fmt.format(file_writer, "P3\n{} {}\n255\n", .{width, height});


    var image_height: i64 = height - 1;
    while (image_height >= 0) : (image_height -= 1)
    //for (image) |arr|
    {
        var arr = image[@intCast(usize, image_height)];
        for (arr) |arr2|
        {
            try std.fmt.format(file_writer, "{} {} {}\n", .{arr2[0], arr2[1], arr2[2]});
        }
    }
}

pub fn main() anyerror!void
{
    try abstracted();
}
