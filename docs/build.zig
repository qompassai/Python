const std = @import("std");
const zine = @import("zine");

pub fn build(b: *std.Build) !void {
    try zine.website(b, .{
        .title = "OnTrack Documentation",
        .host_url = "https://qompassai.github.io/Python",
        .layouts_dir_path = "layouts",
        .content_dir_path = "content",
        .assets_dir_path = "assets",
    });
}
