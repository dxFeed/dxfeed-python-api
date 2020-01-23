from setuptools import Extension, find_packages
from Cython.Build import cythonize
from pathlib import Path
import platform

source_files_directory = Path(__file__).resolve().parent.joinpath('dxpyfeed', 'dxfeed-c-api', 'src')
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
libs = []
if platform.system() == 'Windows':
    source_files_paths.remove(str(source_files_directory.joinpath('Linux.c')))
    libs = ['ws2_32']
else:
    source_files_paths.remove(str(source_files_directory.joinpath('Win32.c')))

package_c_files_dir = Path(__file__).resolve().parent.joinpath('dxpyfeed', 'wrapper')
package_c_files_paths = [str(path) for path in package_c_files_dir.glob('**/*.c')]

SRC_DIR = 'dxpyfeed'
PACKAGES = [SRC_DIR]

dxfeed = ('dxfeed', {'sources': source_files_paths,
                     'libraries': libs})

ext_lis = Extension(name=SRC_DIR + '.wrapper.listeners.listener',
                    sources=[SRC_DIR + '/wrapper/listeners/listener.pyx'],
                    libraries=libs)

ext_helpers = Extension(name=SRC_DIR + '.wrapper.utils.helpers',
                        sources=[SRC_DIR + '/wrapper/utils/helpers.pyx'],
                        libraries=libs)

ext_dxfeed = Extension(name=SRC_DIR + '.wrapper.DXFeedPy',
                       sources=[SRC_DIR + '/wrapper/DXFeedPy.pyx'] + package_c_files_paths,
                       libraries=libs)

EXTENSIONS = [ext_lis,
              ext_helpers,
              ext_dxfeed]


def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': cythonize(EXTENSIONS, language_level=3),
        'zip_safe': False,
        'libraries': [dxfeed],
        'include_dirs': [SRC_DIR + '/dxfeed-c-api/include/',
                         SRC_DIR + '/dxfeed-c-api/src',
                         SRC_DIR + '/wrapper/pxd_include',
                         SRC_DIR + '/wrapper/utils']
    })
