const std = @import("std");
const Allocator = std.mem.Allocator;
const file_glob = @import("./build/file_glob.zig").file_glob;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_c = b.dependency("sdl3", .{});

    const lib = b.addStaticLibrary(.{
        .name = "SDL3",
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(sdl_c.path("include"));
    lib.addIncludePath(sdl_c.path("include/build_config"));
    lib.addIncludePath(sdl_c.path("src"));
    lib.defineCMacro("SDL_USE_BUILTIN_OPENGL_DEFINITIONS", "1");
    lib.linkLibC();
    lib.linkLibCpp();
    try addCSourceFiles(b, lib, .{
        .root = sdl_c.path(""),
        .globs = &globs_all,
    });

    switch (target.result.os.tag) {
        .macos => {
            lib.defineCMacro("SDL_PLATFORM_MACOS", "1");
            lib.defineCMacro("SDL_PLATFORM_APPLE", "1");
            try addCSourceFiles(b, lib, .{
                .root = sdl_c.path(""),
                .globs = &globs_darwin,
            });
            try addCSourceFiles(b, lib, .{
                .root = sdl_c.path(""),
                .globs = &globs_objective_c,
                .flags = &.{"-fobjc-arc"},
            });
            lib.linkFramework("AudioToolbox");
            lib.linkFramework("AVFoundation");
            lib.linkFramework("Carbon");
            lib.linkFramework("Cocoa");
            lib.linkFramework("CoreAudio");
            lib.linkFramework("CoreBluetooth");
            lib.linkFramework("CoreHaptics");
            lib.linkFramework("CoreMedia");
            lib.linkFramework("CoreVideo");
            lib.linkFramework("ForceFeedback");
            lib.linkFramework("Foundation");
            lib.linkFramework("GameController");
            lib.linkFramework("IOKit");
            lib.linkFramework("Metal");
            lib.linkFramework("OpenGL");
            lib.linkFramework("QuartzCore");
            lib.linkFramework("UniformTypeIdentifiers");
        },
        .windows => {
            lib.defineCMacro("SDL_PLATFORM_WIN32", "1");
            lib.defineCMacro("SDL_PLATFORM_WINDOWS", "1");
            try addCSourceFiles(b, lib, .{
                .root = sdl_c.path(""),
                .globs = &globs_windows,
            });
            lib.linkSystemLibrary("gdi32");
            lib.linkSystemLibrary("imm32");
            lib.linkSystemLibrary("ole32");
            lib.linkSystemLibrary("oleaut32");
            lib.linkSystemLibrary("setupapi");
            lib.linkSystemLibrary("version");
            lib.linkSystemLibrary("winmm");
        },
        .emscripten => {
            lib.defineCMacro("__EMSCRIPTEN_PTHREADS__ ", "1");
            lib.defineCMacro("USE_SDL", "2");
            try addCSourceFiles(b, lib, .{
                .root = sdl_c.path(""),
                .globs = &globs_emscripten,
            });
        },
        else => {
            const config_header = b.addConfigHeader(.{
                .style = .{ .cmake = b.path("include/SDL_config.h.cmake") },
                .include_path = "SDL2/SDL_config.h",
            }, .{});
            lib.addConfigHeader(config_header);
            lib.installConfigHeader(config_header);
        },
    }

    lib.installHeadersDirectory(sdl_c.path("include"), "", .{});
    b.installArtifact(lib);

    var module = b.addModule("sdl", .{
        .root_source_file = b.path("sdl.zig"),
    });
    module.addIncludePath(b.path("include"));
}

const globs_all = [_][]const u8{
    "src/*.c",
    "src/atomic/*.c",
    "src/audio/*.c",
    "src/camera/*.c",
    "src/core/*.c",
    "src/cpuinfo/*.c",
    "src/dialog/*.c",
    "src/dynapi/*.c",
    "src/events/*.c",
    "src/file/*.c",
    "src/filesystem/*.c",
    "src/gpu/*.c",
    "src/haptic/*.c",
    "src/hidapi/*.c",
    "src/joystick/*.c",
    "src/joystick/hidapi/*.c",
    "src/joystick/virtual/*.c",
    "src/locale/*.c",
    "src/main/*.c",
    "src/misc/*.c",
    "src/power/*.c",
    "src/process/*.c",
    "src/render/*.c",
    "src/render/*/*.c",
    "src/sensor/*.c",
    "src/stdlib/*.c",
    "src/storage/*.c",
    "src/thread/*.c",
    "src/time/*.c",
    "src/timer/*.c",
    "src/video/*.c",
    "src/video/offscreen/*.c",
    "src/video/yuv2rgb/*.c",
};

const globs_darwin = [_][]const u8{
    "src/audio/disk/*.c",
    "src/audio/dummy/*.c",
    "src/camera/dummy/*.c",
    "src/filesystem/posix/*.c",
    "src/gpu/vulkan/*.c",
    "src/haptic/darwin/*.c",
    "src/joystick/darwin/*.c",
    "src/loadso/dlopen/*.c",
    "src/main/generic/*.c",
    "src/power/macos/*.c",
    "src/process/posix/*.c",
    "src/render/opengl/*.c",
    "src/render/opengles/*.c",
    "src/render/opengles2/*.c",
    "src/sensor/dummy/*.c",
    "src/storage/generic/*.c",
    "src/thread/pthread/*.c",
    "src/time/unix/*.c",
    "src/timer/unix/*.c",
    "src/video/dummy/*.c",
};

const globs_objective_c = [_][]const u8{
    "src/audio/coreaudio/*.m",
    "src/camera/coremedia/*.m",
    "src/dialog/cocoa/*.m",
    "src/file/cocoa/*.m",
    "src/filesystem/cocoa/*.m",
    "src/gpu/metal/*.m",
    "src/joystick/apple/*.m",
    "src/joystick/hidapi/*.m",
    "src/joystick/virtual/*.m",
    "src/locale/macos/*.m",
    "src/misc/macos/*.m",
    "src/power/uikit/*.m",
    "src/render/metal/*.m",
    "src/sensor/coremotion/*.m",
    "src/video/cocoa/*.m",
    "src/video/uikit/*.m",
};

const globs_windows = [_][]const u8{
    "src/audio/directsound/SDL_directsound.c",
    "src/audio/disk/*.c",
    "src/audio/wasapi/*.c",
    "src/core/windows/*.c",
    "src/dialog/windows/*.c",
    "src/filesystem/windows/*.c",
    "src/haptic/windows/*.c",
    "src/hidapi/windows/*.c",
    "src/joystick/windows/*.c",
    "src/loadso/windows/*.c",
    "src/locale/windows/*.c",
    "src/main/windows/*.c",
    "src/misc/windows/*.c",
    "src/power/windows/*.c",
    "src/process/windows/*.c",
    "src/render/direct3d/*.c",
    "src/render/direct3d11/*.c",
    "src/render/direct3d12/*.c",
    "src/render/opengl/*.c",
    "src/render/opengles2/*.c",
    "src/sensor/windows/*.c",
    "src/thread/generic/*.c",
    "src/thread/windows/*.c",
    "src/time/windows/SDL_systime.c",
    "src/timer/windows/*.c",
};

const linux_src_files = [_][]const u8{
    "src/audio/alsa/*.c",
    "src/audio/jack/*.c",
    "src/audio/pulseaudio/*.c",
    "src/core/linux/*.c",
    "src/haptic/linux/*.c",
    "src/hidapi/linux/*.c",
    "src/joystick/linux/*.c",
    "src/power/linux/*.c",
    "src/video/wayland/*.c",
    "src/video/x11/*.c",
};

const globs_ios = [_][]const u8{
    "src/hidapi/ios/*.m",
    "src/main/ios/*.m",
    "src/misc/ios/*.m",
};
const globs_emscripten = [_][]const u8{
    "src/audio/disk/*.c",
    "src/audio/emscripten/*.c",
    "src/filesystem/emscripten/*.c",
    "src/joystick/emscripten/*.c",
    "src/loadso/dlopen/*.c",
    "src/locale/emscripten/*.c",
    "src/main/emscripten/*.c",
    "src/misc/emscripten/*.c",
    "src/power/emscripten/*.c",
    "src/render/opengles2/*.c",
    "src/sensor/dummy/*.c",
    "src/thread/pthread/*.c",
    "src/timer/unix/*.c",
    "src/video/emscripten/*.c",
};

pub const addCSourceFilesOptions = struct {
    root: std.Build.LazyPath,
    globs: []const []const u8,
    flags: []const []const u8 = &.{},
};
pub fn addCSourceFiles(b: *std.Build, lib: *std.Build.Step.Compile, options: addCSourceFilesOptions) !void {
    const path = options.root.getPath(b);
    const generic_src_files: []const []const u8 = try file_glob(b.allocator, path, options.globs);
    defer b.allocator.free(generic_src_files);
    lib.addCSourceFiles(.{
        .root = options.root,
        .files = generic_src_files,
        .flags = options.flags,
    });
}
