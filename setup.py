from distutils.core import setup, Extension
import pkgconfig
import numpy as np
import os

d = pkgconfig.parse('libavformat libswscale opencv4')

# Raise error if the user forgot to tell us where ffmpeg was installed
ffmpeg_dir = os.environ.get("FFMPEG_INSTALL_DIR", "")
if not ffmpeg_dir:
    raise AssertionError(
        "setup.py needs to know where ffmpeg was installed. Make sure the "
        "'FFMPEG_INSTALL_DIR' environment variable is defined."
    )
if not os.path.isdir(ffmpeg_dir):
    raise ValueError(
        "setup.py needs to know where ffmpeg was installed. 'FFMPEG_INSTALL_DIR' "
        " was defined but does not point to a directory. Found: "
        f"FFMPEG_INSTALL_DIR={ffmpeg_dir}"
    )

stream_sync = Extension('stream_sync',
                    include_dirs = [ffmpeg_dir,
                                    *d['include_dirs'],
                                    np.get_include()],
                    library_dirs = d['library_dirs'],
                    libraries = d['libraries'],
                    sources = ['src/py_stream_sync.cpp',
                               'src/stream_sync.cpp',
                               '../video_cap/src/video_cap.cpp',
                               '../video_cap/src/time_cvt.cpp'],
                    extra_compile_args = ['-std=c++17'],
                    extra_link_args = ['-fPIC', '-Wl,-Bsymbolic'])

setup (name = 'stream_sync',
       version = '1.0',
       description = 'Synchronizes multiple RTSP streams based on UNIX timestamp of each frame.',
       ext_modules = [stream_sync])
