from setuptools import Extension, find_packages
from Cython.Build import cythonize
from pathlib import Path
import platform

SRC_DIR='dxpyfeed'

try:
    from Cython.Build import cythonize
except ImportError:
    use_cython = False
    ext = 'c'
    ext_pp = 'cpp'
else:
    use_cython = True
    ext = ext_pp = 'pyx'

# Get all dxfeed c api c files to be compiled into separate lib
source_files_directory = Path(__file__).resolve().parent.joinpath('dxpyfeed', 'dxfeed-c-api', 'src')
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
libs = list()
if platform.system() == 'Windows':
    source_files_paths.remove(str(source_files_directory.joinpath('Linux.c')))
    libs = ['ws2_32']
else:
    source_files_paths.remove(str(source_files_directory.joinpath('Win32.c')))

# Separate dxfeed c api library
dxfeed_c = ('dxfeed_c', {'sources': source_files_paths,
                         'libraries': libs})

extensions = [Extension('dxpyfeed.wrapper.utils.helpers', ['dxpyfeed/wrapper/utils/helpers.' + ext]),
              Extension('dxpyfeed.wrapper.listeners.listener', ['dxpyfeed/wrapper/listeners/listener.' + ext]),
              Extension('dxpyfeed.wrapper.DXFeedPy', ['dxpyfeed/wrapper/DXFeedPy.' + ext_pp], libraries=libs)]

if use_cython:
    extensions = cythonize(extensions, language_level=3)

package_data = {'': ['*']}

def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': extensions,
        'zip_safe': False,
        'libraries': [dxfeed_c],
        'packages': find_packages(),
        'package_data': package_data,
        'include_dirs': [SRC_DIR + '/dxfeed-c-api/include/',
                         SRC_DIR + '/dxfeed-c-api/src']
    })
