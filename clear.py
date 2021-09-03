import shutil
from pathlib import Path
from itertools import chain

c_files = Path('dxfeed/core').glob('**/*.c')
cpp_files = Path('dxfeed/core').glob('**/*.cpp')
pyd_files = Path('dxfeed/core').glob('**/*.pyd')
so_files = Path('dxfeed/core').glob('**/*.so')
dll_files = Path('dxfeed/core').glob('**/*.dll')
lib_files = Path('dxfeed/core').glob('*.lib')
dylib_files = Path('dxfeed/core').glob('**/*.dylib')

for file_path in chain(c_files, cpp_files, pyd_files, so_files, dll_files, lib_files, dylib_files):
    file_path.unlink()

if Path('dxfeed/tmp').exists():
    shutil.rmtree('dxfeed/tmp')

if Path('dxfeed/dxfeed-c-api/include').exists():
    shutil.rmtree('dxfeed/dxfeed-c-api/include')
