const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const t = target.result;

    const sdl_c = b.dependency("sdl3", .{});

    const lib = b.addStaticLibrary(.{
        .name = "SDL3",
        .target = target,
        .optimize = optimize,
    });

    const src_root_path = sdl_c.path("src");

    lib.addIncludePath(sdl_c.path("include"));
    lib.addIncludePath(sdl_c.path("include/build_config"));
    lib.addIncludePath(sdl_c.path("src"));
    lib.addCSourceFiles(.{
        .root = src_root_path,
        .files = &generic_src_files,
    });
    lib.defineCMacro("SDL_USE_BUILTIN_OPENGL_DEFINITIONS", "1");
    // SDL_JOYSTICK_MFI
    lib.linkLibC();

    switch (t.os.tag) {
        .windows => {
            lib.addCSourceFiles(.{
                .root = src_root_path,
                .files = &windows_src_files,
            });
            lib.linkSystemLibrary("setupapi");
            lib.linkSystemLibrary("winmm");
            lib.linkSystemLibrary("gdi32");
            lib.linkSystemLibrary("imm32");
            lib.linkSystemLibrary("version");
            lib.linkSystemLibrary("oleaut32");
            lib.linkSystemLibrary("ole32");
        },
        .macos => {
            lib.addCSourceFiles(.{
                .root = src_root_path,
                .files = &darwin_src_files,
            });
            lib.addCSourceFiles(.{
                .root = src_root_path,
                .files = &objective_c_src_files,
                .flags = &.{"-fobjc-arc"},
            });
            lib.linkFramework("GameController");
            lib.linkFramework("CoreHaptics");
            lib.linkFramework("OpenGL");
            lib.linkFramework("Metal");
            lib.linkFramework("CoreVideo");
            lib.linkFramework("Cocoa");
            lib.linkFramework("IOKit");
            lib.linkFramework("ForceFeedback");
            lib.linkFramework("Carbon");
            lib.linkFramework("CoreAudio");
            lib.linkFramework("AudioToolbox");
            lib.linkFramework("AVFoundation");
            lib.linkFramework("Foundation");
        },
        else => {
            const config_header = b.addConfigHeader(.{
                .style = .{ .cmake = sdl_c.path("include/SDL_config.h.cmake") },
                .include_path = "SDL3/SDL_config.h",
            }, .{});
            lib.addConfigHeader(config_header);
            lib.installConfigHeader(config_header);
        },
    }

    lib.installHeadersDirectory(sdl_c.path("include"), "", .{});
    b.installArtifact(lib);
}

const generic_src_files = [_][]const u8{
    "SDL.c",
    "SDL_assert.c",
    "SDL_error.c",
    "SDL_guid.c",
    "SDL_hashtable.c",
    "SDL_hints.c",
    "SDL_list.c",
    "SDL_log.c",
    "SDL_properties.c",
    "SDL_utils.c",

    // atomic
    "atomic/SDL_atomic.c",
    "atomic/SDL_spinlock.c",

    // audio
    "audio/SDL_audio.c",
    "audio/SDL_audiocvt.c",
    "audio/SDL_audiodev.c",
    "audio/SDL_audioqueue.c",
    "audio/SDL_audioresample.c",
    "audio/SDL_audiotypecvt.c",
    "audio/SDL_mixer.c",
    "audio/SDL_wave.c",

    // camera
    "camera/SDL_camera.c",

    // core?

    // cpuinfo
    "cpuinfo/SDL_cpuinfo.c",

    // dialog
    //"dialog/SDL_dialog_utils.c",

    // dynapi
    "dynapi/SDL_dynapi.c",

    // events
    "events/SDL_categories.c",
    "events/SDL_clipboardevents.c",
    "events/SDL_displayevents.c",
    "events/SDL_dropevents.c",
    "events/SDL_events.c",
    "events/SDL_keyboard.c",
    "events/SDL_keymap.c",
    "events/SDL_keysym_to_scancode.c",
    "events/SDL_mouse.c",
    "events/SDL_pen.c",
    "events/SDL_quit.c",
    "events/SDL_scancode_tables.c",
    "events/SDL_touch.c",
    "events/SDL_windowevents.c",
    "events/imKStoUCS.c",

    // file
    "file/SDL_iostream.c",

    // filesystem
    "filesystem/SDL_filesystem.c",

    // gpu
    "gpu/SDL_gpu.c",

    // haptic
    "haptic/SDL_haptic.c",

    // hidapi

    // joystick
    "joystick/SDL_gamepad.c",
    "joystick/SDL_joystick.c",
    "joystick/SDL_steam_virtual_gamepad.c",
    "joystick/controller_type.c",
    "joystick/virtual/SDL_virtualjoystick.c",

    // libm
    "libm/e_atan2.c",
    "libm/e_exp.c",
    "libm/e_fmod.c",
    "libm/e_log.c",
    "libm/e_log10.c",
    "libm/e_pow.c",
    "libm/e_rem_pio2.c",
    "libm/e_sqrt.c",
    "libm/k_cos.c",
    "libm/k_rem_pio2.c",
    "libm/k_sin.c",
    "libm/k_tan.c",
    "libm/s_atan.c",
    "libm/s_copysign.c",
    "libm/s_cos.c",
    "libm/s_fabs.c",
    "libm/s_floor.c",
    "libm/s_isinf.c",
    "libm/s_isinff.c",
    "libm/s_isnan.c",
    "libm/s_isnanf.c",
    "libm/s_modf.c",
    "libm/s_scalbn.c",
    "libm/s_sin.c",
    "libm/s_tan.c",

    // loadso

    // locale
    "locale/SDL_locale.c",

    // main
    // misc
    "misc/SDL_url.c",

    // power
    "power/SDL_power.c",

    // process
    "process/SDL_process.c",

    // render
    "render/SDL_d3dmath.c",
    "render/SDL_render.c",
    "render/SDL_render_unsupported.c",
    "render/SDL_yuv_sw.c",

    // sensor
    "sensor/SDL_sensor.c",

    // stdlib
    "stdlib/SDL_crc16.c",
    "stdlib/SDL_crc32.c",
    "stdlib/SDL_getenv.c",
    "stdlib/SDL_iconv.c",
    "stdlib/SDL_malloc.c",
    "stdlib/SDL_memcpy.c",
    "stdlib/SDL_memmove.c",
    "stdlib/SDL_memset.c",
    "stdlib/SDL_mslibc.c",
    "stdlib/SDL_murmur3.c",
    "stdlib/SDL_qsort.c",
    "stdlib/SDL_random.c",
    "stdlib/SDL_stdlib.c",
    "stdlib/SDL_string.c",
    "stdlib/SDL_strtokr.c",

    // storage
    "storage/SDL_storage.c",

    // test

    // thread
    "thread/SDL_thread.c",

    // time
    "time/SDL_time.c",

    // timer
    "timer/SDL_timer.c",

    // video
    "video/SDL_RLEaccel.c",
    "video/SDL_blit.c",
    "video/SDL_blit_0.c",
    "video/SDL_blit_1.c",
    "video/SDL_blit_A.c",
    "video/SDL_blit_N.c",
    "video/SDL_blit_auto.c",
    "video/SDL_blit_copy.c",
    "video/SDL_blit_slow.c",
    "video/SDL_bmp.c",
    "video/SDL_clipboard.c",
    "video/SDL_egl.c",
    "video/SDL_fillrect.c",
    "video/SDL_pixels.c",
    "video/SDL_rect.c",
    "video/SDL_stretch.c",
    "video/SDL_surface.c",
    "video/SDL_video.c",
    "video/SDL_video_unsupported.c",
    "video/SDL_vulkan_utils.c",
    "video/SDL_yuv.c",
    "video/yuv2rgb/yuv_rgb_std.c",
    "video/yuv2rgb/yuv_rgb_lsx.c",
    "video/yuv2rgb/yuv_rgb_sse.c",
    "video/dummy/SDL_nullevents.c",
    "video/dummy/SDL_nullframebuffer.c",
    "video/dummy/SDL_nullvideo.c",
    "render/software/SDL_blendfillrect.c",
    "render/software/SDL_blendline.c",
    "render/software/SDL_blendpoint.c",
    "render/software/SDL_drawline.c",
    "render/software/SDL_drawpoint.c",
    "render/software/SDL_render_sw.c",
    "render/software/SDL_rotate.c",
    "render/software/SDL_triangle.c",
    "audio/dummy/SDL_dummyaudio.c",
    "joystick/hidapi/SDL_hidapi_combined.c",
    "joystick/hidapi/SDL_hidapi_gamecube.c",
    "joystick/hidapi/SDL_hidapi_luna.c",
    "joystick/hidapi/SDL_hidapi_ps3.c",
    "joystick/hidapi/SDL_hidapi_ps4.c",
    "joystick/hidapi/SDL_hidapi_ps5.c",
    "joystick/hidapi/SDL_hidapi_rumble.c",
    "joystick/hidapi/SDL_hidapi_shield.c",
    "joystick/hidapi/SDL_hidapi_stadia.c",
    "joystick/hidapi/SDL_hidapi_steam.c",
    "joystick/hidapi/SDL_hidapi_steam_hori.c",
    "joystick/hidapi/SDL_hidapi_steamdeck.c",
    "joystick/hidapi/SDL_hidapi_switch.c",
    "joystick/hidapi/SDL_hidapi_wii.c",
    "joystick/hidapi/SDL_hidapi_xbox360.c",
    "joystick/hidapi/SDL_hidapi_xbox360w.c",
    "joystick/hidapi/SDL_hidapi_xboxone.c",
};

const windows_src_files = [_][]const u8{
    "core/windows/SDL_hid.c",
    "core/windows/SDL_immdevice.c",
    "core/windows/SDL_windows.c",
    "core/windows/SDL_xinput.c",
    "core/windows/pch.c",
    "dialog/windows/SDL_windowsdialog.c",
    "filesystem/windows/SDL_sysfilesystem.c",
    "filesystem/windows/SDL_sysfsops.c",
    "haptic/windows/SDL_dinputhaptic.c",
    "haptic/windows/SDL_windowshaptic.c",
    "hidapi/windows/hid.c",
    "hidapi/windows/hidapi_descriptor_reconstruct.c",
    "joystick/windows/SDL_dinputjoystick.c",
    "joystick/windows/SDL_rawinputjoystick.c",
    "joystick/windows/SDL_windows_gaming_input.c",
    "joystick/windows/SDL_windowsjoystick.c",
    "joystick/windows/SDL_xinputjoystick.c",

    "loadso/windows/SDL_sysloadso.c",
    "locale/windows/SDL_syslocale.c",
    "main/windows/SDL_sysmain_runapp.c",
    "misc/windows/SDL_sysurl.c",
    "power/windows/SDL_syspower.c",
    "process/windows/SDL_windowsprocess.c",
    "sensor/windows/SDL_windowssensor.c",
    "timer/windows/SDL_systimer.c",
    "video/windows/SDL_windowsclipboard.c",
    "video/windows/SDL_windowsevents.c",
    "video/windows/SDL_windowsframebuffer.c",
    "video/windows/SDL_windowsgameinput.c",
    "video/windows/SDL_windowskeyboard.c",
    "video/windows/SDL_windowsmessagebox.c",
    "video/windows/SDL_windowsmodes.c",
    "video/windows/SDL_windowsmouse.c",
    "video/windows/SDL_windowsopengl.c",
    "video/windows/SDL_windowsopengles.c",
    "video/windows/SDL_windowsrawinput.c",
    "video/windows/SDL_windowsshape.c",
    "video/windows/SDL_windowsvideo.c",
    "video/windows/SDL_windowsvulkan.c",
    "video/windows/SDL_windowswindow.c",

    "thread/windows/SDL_syscond_cv.c",
    "thread/windows/SDL_sysmutex.c",
    "thread/windows/SDL_sysrwlock_srw.c",
    "thread/windows/SDL_syssem.c",
    "thread/windows/SDL_systhread.c",
    "thread/windows/SDL_systls.c",
    "thread/generic/SDL_syscond.c",
    "thread/generic/SDL_sysmutex.c",
    "thread/generic/SDL_sysrwlock.c",
    "thread/generic/SDL_syssem.c",
    "thread/generic/SDL_systhread.c",
    "thread/generic/SDL_systls.c",

    "time/windows/SDL_systime.c",

    "render/direct3d/SDL_render_d3d.c",
    "render/direct3d/SDL_shaders_d3d.c",
    "render/direct3d11/SDL_render_d3d11.c",
    "render/direct3d11/SDL_shaders_d3d11.c",
    "render/direct3d12/SDL_render_d3d12.c",
    "render/direct3d12/SDL_shaders_d3d12.c",

    "audio/directsound/SDL_directsound.c",
    "audio/wasapi/SDL_wasapi.c",
    "audio/wasapi/SDL_wasapi_win32.c",
    "audio/disk/SDL_diskaudio.c",

    "render/opengl/SDL_render_gl.c",
    "render/opengl/SDL_shaders_gl.c",
    "render/opengles2/SDL_render_gles2.c",
    "render/opengles2/SDL_shaders_gles2.c",
};

const linux_src_files = [_][]const u8{
    "core/linux/SDL_dbus.c",
    "core/linux/SDL_evdev.c",
    "core/linux/SDL_evdev_capabilities.c",
    "core/linux/SDL_evdev_kbd.c",
    "core/linux/SDL_fcitx.c",
    "core/linux/SDL_ibus.c",
    "core/linux/SDL_ime.c",
    "core/linux/SDL_system_theme.c",
    "core/linux/SDL_threadprio.c",
    "core/linux/SDL_udev.c",
    "haptic/linux/SDL_syshaptic.c",
    "hidapi/linux/hid.c",
    "joystick/linux/SDL_sysjoystick.c",
    "power/linux/SDL_syspower.c",

    "video/wayland/SDL_waylandclipboard.c",
    "video/wayland/SDL_waylanddatamanager.c",
    "video/wayland/SDL_waylanddyn.c",
    "video/wayland/SDL_waylandevents.c",
    "video/wayland/SDL_waylandkeyboard.c",
    "video/wayland/SDL_waylandmessagebox.c",
    "video/wayland/SDL_waylandmouse.c",
    "video/wayland/SDL_waylandopengles.c",
    "video/wayland/SDL_waylandshmbuffer.c",
    "video/wayland/SDL_waylandvideo.c",
    "video/wayland/SDL_waylandvulkan.c",
    "video/wayland/SDL_waylandwindow.c",

    "video/x11/SDL_x11clipboard.c",
    "video/x11/SDL_x11dyn.c",
    "video/x11/SDL_x11events.c",
    "video/x11/SDL_x11framebuffer.c",
    "video/x11/SDL_x11keyboard.c",
    "video/x11/SDL_x11messagebox.c",
    "video/x11/SDL_x11modes.c",
    "video/x11/SDL_x11mouse.c",
    "video/x11/SDL_x11opengl.c",
    "video/x11/SDL_x11opengles.c",
    "video/x11/SDL_x11pen.c",
    "video/x11/SDL_x11settings.c",
    "video/x11/SDL_x11shape.c",
    "video/x11/SDL_x11touch.c",
    "video/x11/SDL_x11video.c",
    "video/x11/SDL_x11vulkan.c",
    "video/x11/SDL_x11window.c",
    "video/x11/SDL_x11xfixes.c",
    "video/x11/SDL_x11xinput2.c",
    "video/x11/edid-parse.c",
    "video/x11/xsettings-client.c",

    "audio/alsa/SDL_alsa_audio.c",
    "audio/jack/SDL_jackaudio.c",
    "audio/pulseaudio/SDL_pulseaudio.c",
};

const darwin_src_files = [_][]const u8{
    "haptic/darwin/SDL_syshaptic.c",
    "joystick/darwin/SDL_iokitjoystick.c",
    "power/macos/SDL_syspower.c",
    "timer/unix/SDL_systimer.c",
    "loadso/dlopen/SDL_sysloadso.c",
    "audio/disk/SDL_diskaudio.c",
    "render/opengl/SDL_render_gl.c",
    "render/opengl/SDL_shaders_gl.c",
    "render/opengles2/SDL_render_gles2.c",
    "render/opengles2/SDL_shaders_gles2.c",
    "sensor/dummy/SDL_dummysensor.c",

    "hidapi/mac/hid.c",

    "thread/pthread/SDL_syscond.c",
    "thread/pthread/SDL_sysmutex.c",
    "thread/pthread/SDL_sysrwlock.c",
    "thread/pthread/SDL_syssem.c",
    "thread/pthread/SDL_systhread.c",
    "thread/pthread/SDL_systls.c",
};

const objective_c_src_files = [_][]const u8{
    "audio/coreaudio/SDL_coreaudio.m",
    "camera/coremedia/SDL_camera_coremedia.m",
    "dialog/cocoa/SDL_cocoadialog.m",
    "filesystem/cocoa/SDL_sysfilesystem.m",
    "gpu/metal/SDL_gpu_metal.m",
    //"hidapi/testgui/mac_support_cocoa.m",
    "joystick/apple/SDL_mfijoystick.m",
    "locale/macos/SDL_syslocale.m",
    "misc/macos/SDL_sysurl.m",
    "power/uikit/SDL_syspower.m",
    "render/metal/SDL_render_metal.m",
    "sensor/coremotion/SDL_coremotionsensor.m",
    "video/cocoa/SDL_cocoaclipboard.m",
    "video/cocoa/SDL_cocoaevents.m",
    "video/cocoa/SDL_cocoakeyboard.m",
    "video/cocoa/SDL_cocoamessagebox.m",
    "video/cocoa/SDL_cocoametalview.m",
    "video/cocoa/SDL_cocoamodes.m",
    "video/cocoa/SDL_cocoamouse.m",
    "video/cocoa/SDL_cocoaopengl.m",
    "video/cocoa/SDL_cocoaopengles.m",
    "video/cocoa/SDL_cocoapen.m",
    "video/cocoa/SDL_cocoashape.m",
    "video/cocoa/SDL_cocoavideo.m",
    "video/cocoa/SDL_cocoavulkan.m",
    "video/cocoa/SDL_cocoawindow.m",
    "video/uikit/SDL_uikitappdelegate.m",
    "video/uikit/SDL_uikitclipboard.m",
    "video/uikit/SDL_uikitevents.m",
    "video/uikit/SDL_uikitmessagebox.m",
    "video/uikit/SDL_uikitmetalview.m",
    "video/uikit/SDL_uikitmodes.m",
    "video/uikit/SDL_uikitopengles.m",
    "video/uikit/SDL_uikitopenglview.m",
    "video/uikit/SDL_uikitvideo.m",
    "video/uikit/SDL_uikitview.m",
    "video/uikit/SDL_uikitviewcontroller.m",
    "video/uikit/SDL_uikitvulkan.m",
    "video/uikit/SDL_uikitwindow.m",
};

const ios_src_files = [_][]const u8{
    "hidapi/ios/hid.m",
    "main/ios/SDL_sysmain_callbacks.m",
    "misc/ios/SDL_sysurl.m",
};

const unknown_src_files = [_][]const u8{
    "thread/generic/SDL_syscond.c",
    "thread/generic/SDL_sysmutex.c",
    "thread/generic/SDL_syssem.c",
    "thread/generic/SDL_systhread.c",
    "thread/generic/SDL_systls.c",

    "audio/aaudio/SDL_aaudio.c",
    "audio/android/SDL_androidaudio.c",
    "audio/arts/SDL_artsaudio.c",
    "audio/dsp/SDL_dspaudio.c",
    "audio/emscripten/SDL_emscriptenaudio.c",
    "audio/esd/SDL_esdaudio.c",
    "audio/fusionsound/SDL_fsaudio.c",
    "audio/n3ds/SDL_n3dsaudio.c",
    "audio/nacl/SDL_naclaudio.c",
    "audio/nas/SDL_nasaudio.c",
    "audio/netbsd/SDL_netbsdaudio.c",
    "audio/openslES/SDL_openslES.c",
    "audio/os2/SDL_os2audio.c",
    "audio/paudio/SDL_paudio.c",
    "audio/pipewire/SDL_pipewire.c",
    "audio/ps2/SDL_ps2audio.c",
    "audio/psp/SDL_pspaudio.c",
    "audio/qsa/SDL_qsa_audio.c",
    "audio/sndio/SDL_sndioaudio.c",
    "audio/sun/SDL_sunaudio.c",
    "audio/vita/SDL_vitaaudio.c",

    "core/android/SDL_android.c",
    "core/freebsd/SDL_evdev_kbd_freebsd.c",
    "core/openbsd/SDL_wscons_kbd.c",
    "core/openbsd/SDL_wscons_mouse.c",
    "core/os2/SDL_os2.c",
    "core/os2/geniconv/geniconv.c",
    "core/os2/geniconv/os2cp.c",
    "core/os2/geniconv/os2iconv.c",
    "core/os2/geniconv/sys2utf8.c",
    "core/os2/geniconv/test.c",
    "core/unix/SDL_poll.c",

    "file/n3ds/SDL_rwopsromfs.c",

    "filesystem/android/SDL_sysfilesystem.c",
    "filesystem/dummy/SDL_sysfilesystem.c",
    "filesystem/emscripten/SDL_sysfilesystem.c",
    "filesystem/n3ds/SDL_sysfilesystem.c",
    "filesystem/nacl/SDL_sysfilesystem.c",
    "filesystem/os2/SDL_sysfilesystem.c",
    "filesystem/ps2/SDL_sysfilesystem.c",
    "filesystem/psp/SDL_sysfilesystem.c",
    "filesystem/riscos/SDL_sysfilesystem.c",
    "filesystem/unix/SDL_sysfilesystem.c",
    "filesystem/vita/SDL_sysfilesystem.c",

    "haptic/android/SDL_syshaptic.c",
    "haptic/dummy/SDL_syshaptic.c",

    "hidapi/libusb/hid.c",

    "joystick/android/SDL_sysjoystick.c",
    "joystick/bsd/SDL_bsdjoystick.c",
    "joystick/dummy/SDL_sysjoystick.c",
    "joystick/emscripten/SDL_sysjoystick.c",
    "joystick/n3ds/SDL_sysjoystick.c",
    "joystick/os2/SDL_os2joystick.c",
    "joystick/ps2/SDL_sysjoystick.c",
    "joystick/psp/SDL_sysjoystick.c",
    "joystick/steam/SDL_steamcontroller.c",
    "joystick/vita/SDL_sysjoystick.c",

    "loadso/dummy/SDL_sysloadso.c",
    "loadso/os2/SDL_sysloadso.c",

    "locale/android/SDL_syslocale.c",
    "locale/dummy/SDL_syslocale.c",
    "locale/emscripten/SDL_syslocale.c",
    "locale/n3ds/SDL_syslocale.c",
    "locale/unix/SDL_syslocale.c",
    "locale/vita/SDL_syslocale.c",
    "locale/winrt/SDL_syslocale.c",

    "main/android/SDL_android_main.c",
    "main/dummy/SDL_dummy_main.c",
    "main/gdk/SDL_gdk_main.c",
    "main/n3ds/SDL_n3ds_main.c",
    "main/nacl/SDL_nacl_main.c",
    "main/ps2/SDL_ps2_main.c",
    "main/psp/SDL_psp_main.c",
    "main/uikit/SDL_uikit_main.c",

    "misc/android/SDL_sysurl.c",
    "misc/dummy/SDL_sysurl.c",
    "misc/emscripten/SDL_sysurl.c",
    "misc/riscos/SDL_sysurl.c",
    "misc/unix/SDL_sysurl.c",
    "misc/vita/SDL_sysurl.c",

    "power/android/SDL_syspower.c",
    "power/emscripten/SDL_syspower.c",
    "power/haiku/SDL_syspower.c",
    "power/n3ds/SDL_syspower.c",
    "power/psp/SDL_syspower.c",
    "power/vita/SDL_syspower.c",

    "sensor/android/SDL_androidsensor.c",
    "sensor/n3ds/SDL_n3dssensor.c",
    "sensor/vita/SDL_vitasensor.c",

    "test/SDL_test_assert.c",
    "test/SDL_test_common.c",
    "test/SDL_test_compare.c",
    "test/SDL_test_crc32.c",
    "test/SDL_test_font.c",
    "test/SDL_test_fuzzer.c",
    "test/SDL_test_harness.c",
    "test/SDL_test_imageBlit.c",
    "test/SDL_test_imageBlitBlend.c",
    "test/SDL_test_imageFace.c",
    "test/SDL_test_imagePrimitives.c",
    "test/SDL_test_imagePrimitivesBlend.c",
    "test/SDL_test_log.c",
    "test/SDL_test_md5.c",
    "test/SDL_test_memory.c",
    "test/SDL_test_random.c",

    "thread/n3ds/SDL_syscond.c",
    "thread/n3ds/SDL_sysmutex.c",
    "thread/n3ds/SDL_syssem.c",
    "thread/n3ds/SDL_systhread.c",
    "thread/os2/SDL_sysmutex.c",
    "thread/os2/SDL_syssem.c",
    "thread/os2/SDL_systhread.c",
    "thread/os2/SDL_systls.c",
    "thread/ps2/SDL_syssem.c",
    "thread/ps2/SDL_systhread.c",
    "thread/psp/SDL_syscond.c",
    "thread/psp/SDL_sysmutex.c",
    "thread/psp/SDL_syssem.c",
    "thread/psp/SDL_systhread.c",
    "thread/vita/SDL_syscond.c",
    "thread/vita/SDL_sysmutex.c",
    "thread/vita/SDL_syssem.c",
    "thread/vita/SDL_systhread.c",

    "timer/dummy/SDL_systimer.c",
    "timer/haiku/SDL_systimer.c",
    "timer/n3ds/SDL_systimer.c",
    "timer/os2/SDL_systimer.c",
    "timer/ps2/SDL_systimer.c",
    "timer/psp/SDL_systimer.c",
    "timer/vita/SDL_systimer.c",

    "video/android/SDL_androidclipboard.c",
    "video/android/SDL_androidevents.c",
    "video/android/SDL_androidgl.c",
    "video/android/SDL_androidkeyboard.c",
    "video/android/SDL_androidmessagebox.c",
    "video/android/SDL_androidmouse.c",
    "video/android/SDL_androidtouch.c",
    "video/android/SDL_androidvideo.c",
    "video/android/SDL_androidvulkan.c",
    "video/android/SDL_androidwindow.c",
    "video/directfb/SDL_DirectFB_WM.c",
    "video/directfb/SDL_DirectFB_dyn.c",
    "video/directfb/SDL_DirectFB_events.c",
    "video/directfb/SDL_DirectFB_modes.c",
    "video/directfb/SDL_DirectFB_mouse.c",
    "video/directfb/SDL_DirectFB_opengl.c",
    "video/directfb/SDL_DirectFB_render.c",
    "video/directfb/SDL_DirectFB_shape.c",
    "video/directfb/SDL_DirectFB_video.c",
    "video/directfb/SDL_DirectFB_vulkan.c",
    "video/directfb/SDL_DirectFB_window.c",
    "video/emscripten/SDL_emscriptenevents.c",
    "video/emscripten/SDL_emscriptenframebuffer.c",
    "video/emscripten/SDL_emscriptenmouse.c",
    "video/emscripten/SDL_emscriptenopengles.c",
    "video/emscripten/SDL_emscriptenvideo.c",
    "video/kmsdrm/SDL_kmsdrmdyn.c",
    "video/kmsdrm/SDL_kmsdrmevents.c",
    "video/kmsdrm/SDL_kmsdrmmouse.c",
    "video/kmsdrm/SDL_kmsdrmopengles.c",
    "video/kmsdrm/SDL_kmsdrmvideo.c",
    "video/kmsdrm/SDL_kmsdrmvulkan.c",
    "video/n3ds/SDL_n3dsevents.c",
    "video/n3ds/SDL_n3dsframebuffer.c",
    "video/n3ds/SDL_n3dsswkb.c",
    "video/n3ds/SDL_n3dstouch.c",
    "video/n3ds/SDL_n3dsvideo.c",
    "video/nacl/SDL_naclevents.c",
    "video/nacl/SDL_naclglue.c",
    "video/nacl/SDL_naclopengles.c",
    "video/nacl/SDL_naclvideo.c",
    "video/nacl/SDL_naclwindow.c",
    "video/offscreen/SDL_offscreenevents.c",
    "video/offscreen/SDL_offscreenframebuffer.c",
    "video/offscreen/SDL_offscreenopengles.c",
    "video/offscreen/SDL_offscreenvideo.c",
    "video/offscreen/SDL_offscreenwindow.c",
    "video/os2/SDL_os2dive.c",
    "video/os2/SDL_os2messagebox.c",
    "video/os2/SDL_os2mouse.c",
    "video/os2/SDL_os2util.c",
    "video/os2/SDL_os2video.c",
    "video/os2/SDL_os2vman.c",
    "video/pandora/SDL_pandora.c",
    "video/pandora/SDL_pandora_events.c",
    "video/ps2/SDL_ps2video.c",
    "video/psp/SDL_pspevents.c",
    "video/psp/SDL_pspgl.c",
    "video/psp/SDL_pspmouse.c",
    "video/psp/SDL_pspvideo.c",
    "video/qnx/gl.c",
    "video/qnx/keyboard.c",
    "video/qnx/video.c",
    "video/raspberry/SDL_rpievents.c",
    "video/raspberry/SDL_rpimouse.c",
    "video/raspberry/SDL_rpiopengles.c",
    "video/raspberry/SDL_rpivideo.c",
    "video/riscos/SDL_riscosevents.c",
    "video/riscos/SDL_riscosframebuffer.c",
    "video/riscos/SDL_riscosmessagebox.c",
    "video/riscos/SDL_riscosmodes.c",
    "video/riscos/SDL_riscosmouse.c",
    "video/riscos/SDL_riscosvideo.c",
    "video/riscos/SDL_riscoswindow.c",
    "video/vita/SDL_vitaframebuffer.c",
    "video/vita/SDL_vitagl_pvr.c",
    "video/vita/SDL_vitagles.c",
    "video/vita/SDL_vitagles_pvr.c",
    "video/vita/SDL_vitakeyboard.c",
    "video/vita/SDL_vitamessagebox.c",
    "video/vita/SDL_vitamouse.c",
    "video/vita/SDL_vitatouch.c",
    "video/vita/SDL_vitavideo.c",
    "video/vivante/SDL_vivanteopengles.c",
    "video/vivante/SDL_vivanteplatform.c",
    "video/vivante/SDL_vivantevideo.c",
    "video/vivante/SDL_vivantevulkan.c",

    "render/opengl/SDL_render_gl.c",
    "render/opengl/SDL_shaders_gl.c",
    "render/opengles/SDL_render_gles.c",
    "render/opengles2/SDL_render_gles2.c",
    "render/opengles2/SDL_shaders_gles2.c",
    "render/ps2/SDL_render_ps2.c",
    "render/psp/SDL_render_psp.c",
    "render/vitagxm/SDL_render_vita_gxm.c",
    "render/vitagxm/SDL_render_vita_gxm_memory.c",
    "render/vitagxm/SDL_render_vita_gxm_tools.c",
};
