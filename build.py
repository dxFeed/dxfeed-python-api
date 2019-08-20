from setuptools import Extension
from Cython.Build import cythonize
from pathlib import Path


source_files_directory = Path(__file__).resolve().parent.joinpath('lib', 'dxfeed-c-api', 'src')
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
source_files_paths.remove(str(source_files_directory.joinpath('Linux.c')))

package_c_files_dir = Path(__file__).resolve().parent.joinpath('lib', 'wrapper')
package_c_files_paths = [str(path) for path in package_c_files_dir.glob('**/*.c')]

NAME = 'test'
SRC_DIR = 'lib'
PACKAGES = [SRC_DIR]


ext_lis = Extension(name=SRC_DIR + '.wrapper.listeners.listener',
                    sources=[SRC_DIR + '/wrapper/listeners/listener.pyx'],
                    libraries=['ws2_32'],
                    include_dirs=[SRC_DIR + '/dxfeed-c-api/include/', SRC_DIR + '/dxfeed-c-api/src'] +
                                 [SRC_DIR + '/wrapper/pxd_include'] +
                                 [SRC_DIR + '/wrapper/utils']
                    )


ext_helpers = Extension(name=SRC_DIR + '.wrapper.utils.helpers',
                        sources=[SRC_DIR + '/wrapper/utils/helpers.pyx'],
                        libraries=['ws2_32'],
                        include_dirs=[SRC_DIR + '/dxfeed-c-api/include/', SRC_DIR + '/dxfeed-c-api/src',
                                      SRC_DIR + '/wrapper/pxd_include'] + [SRC_DIR + '/wrapper/utils'])


ext_subscription = Extension(name=SRC_DIR + '.wrapper.subscribe',
                             sources=[SRC_DIR + '/wrapper/subscribe.pyx'] + source_files_paths + package_c_files_paths,
                             libraries=['ws2_32'],
                             include_dirs=[SRC_DIR + '/dxfeed-c-api/include/', SRC_DIR + '/dxfeed-c-api/src'] +
                                          [SRC_DIR + '/wrapper/pxd_include'] +
                                          [SRC_DIR + '/wrapper/utils'])

EXTENSIONS = [
    ext_lis,
    ext_helpers,
    ext_subscription,
]


def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': cythonize(EXTENSIONS, language_level=3),
        'zip_safe': False,
    })
