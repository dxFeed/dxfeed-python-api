import glob
import os
import shutil

c_files = glob.glob('dxfeed/core/**/*.c', recursive=True)
cpp_files = glob.glob('dxfeed/core/**/*.cpp', recursive=True)
pyd_files = glob.glob('dxfeed/core/**/*.pyd', recursive=True)
so_files = glob.glob('dxfeed/core/**/*.so', recursive=True)
dll_files = glob.glob('dxfeed/core/**/*.dll', recursive=True)
lib_files = glob.glob('dxfeed/core/**/*.lib', recursive=True)
dylib_files = glob.glob('dxfeed/core/**/*.dylib', recursive=True)

for file_path in c_files + cpp_files + pyd_files + so_files + dll_files + lib_files + dylib_files:
    os.remove(file_path)

if os.path.exists('dxfeed/tmp'):
    shutil.rmtree('dxfeed/tmp')

if os.path.exists('dxfeed/dxfeed-c-api/bin'):
    shutil.rmtree('dxfeed/dxfeed-c-api/bin')

if os.path.exists('dxfeed/dxfeed-c-api/include'):
    shutil.rmtree('dxfeed/dxfeed-c-api/include')
