from setuptools import Extension, find_packages
from setuptools.dist import Distribution
from pathlib import Path
import platform

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
root_path = Path(__file__).resolve().parent
source_files_directory = root_path / 'dxfeed' / 'dxfeed-c-api' / 'src'
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
libs = list()
include_dirs = [str(source_files_directory.parent / 'include'),
                str(source_files_directory)]
# Build dxfeed c library
dxfeed_c_lib_args = dict()
if platform.system() == 'Windows':
    source_files_paths.remove(str(source_files_directory / 'Linux.c'))
    libs.append('ws2_32')
else:
    source_files_paths.remove(str(source_files_directory / 'Win32.c'))
dxfeed_c_lib_args.update({'sources': source_files_paths,
                          'include_dirs': include_dirs})

if platform.system() == 'Darwin':
    dxfeed_c_lib_args.update({'macros': [('MACOSX', 'TRUE')]})

dxfeed_c = ('dxfeed_c', dxfeed_c_lib_args)

extensions = [Extension('dxfeed.core.utils.helpers', ['dxfeed/core/utils/helpers.' + ext],
                        include_dirs=include_dirs),
              Extension('dxfeed.core.listeners.listener', ['dxfeed/core/listeners/listener.' + ext],
                        include_dirs=include_dirs),
              Extension('dxfeed.core.DXFeedPy', ['dxfeed/core/DXFeedPy.' + ext_pp], libraries=libs,
                        include_dirs=include_dirs)]

if use_cython:
    extensions = cythonize(extensions, language_level=3)

def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': extensions,
        'zip_safe': False,
        'libraries': [dxfeed_c],
        'packages': find_packages(),
        'include_dirs': include_dirs
    })

def build_extensions():
    """
    Function for building extensions inplace for docs and tests
    :return:
    """
    build_params = {}
    build(build_params)
    dist = Distribution(attrs=build_params)
    build_clib_cmd = dist.get_command_obj('build_clib')
    build_clib_cmd.ensure_finalized()
    build_clib_cmd.run()
    build_ext_cmd = dist.get_command_obj('build_ext')
    build_ext_cmd.ensure_finalized()
    build_ext_cmd.inplace = 1
    build_ext_cmd.run()
