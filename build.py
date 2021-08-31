import os
import platform
import struct
from io import BytesIO
from pathlib import Path
from urllib.request import urlopen
from zipfile import ZipFile
import shutil
from setuptools import Extension, find_packages
from setuptools.dist import Distribution
import toml


class Downloader(object):
    def __init__(self, version: str, path_to_extract: Path,
                 path_to_copy_includes: Path, path_to_copy_libs: Path):
        self.__version = version
        self.__path_to_extract = path_to_extract
        self.__path_to_copy_includes = path_to_copy_includes
        self.__path_to_copy_libs = path_to_copy_libs

    def download(self) -> str:
        __c_api_extracted_root_dir = self.__path_to_extract / f'dxfeed-c-api-{self.__version}-no-tls'
        is_x64 = 8 * struct.calcsize("P") == 64

        if platform.system() == 'Windows':
            current_os = 'windows'
        elif platform.system() == 'Darwin':
            current_os = 'macosx'
        else:
            current_os = 'centos'  # Since centos uses an earlier version of libc

        if (not os.path.exists(self.__path_to_extract)) or (not os.path.exists(__c_api_extracted_root_dir)):
            url = f'https://github.com/dxFeed/dxfeed-c-api/releases/download/{self.__version}/dxfeed-c-api-' \
                  f'{self.__version}-{current_os}-no-tls.zip '
            print(f'Downloading the "{url}"')
            resp = urlopen(url)
            zipfile = ZipFile(BytesIO(resp.read()))
            print(f'Extracting to "{self.__path_to_extract}"')
            zipfile.extractall(self.__path_to_extract)

        if is_x64:
            c_api_x64_suffix = '_64'
        else:
            c_api_x64_suffix = ''

        __c_api_library_name = f'DXFeed{c_api_x64_suffix}'

        if platform.system() == 'Windows':
            if is_x64:
                c_api_extracted_library_dir = __c_api_extracted_root_dir / 'bin' / 'x64'
                c_api_library_file_name = f'{__c_api_library_name}.dll'
                c_api_library_file_name2 = f'{__c_api_library_name}.lib'
            else:
                c_api_extracted_library_dir = __c_api_extracted_root_dir / 'bin' / 'x86'
                c_api_library_file_name = f'{__c_api_library_name}.dll'
                c_api_library_file_name2 = f'{__c_api_library_name}.lib'
        elif platform.system() == 'Darwin':
            if is_x64:
                __c_api_extracted_root_dir = __c_api_extracted_root_dir / f'DXFeedAll-{self.__version}-x64-no-tls'
                c_api_extracted_library_dir = __c_api_extracted_root_dir / 'bin' / 'x64'
                c_api_library_file_name = f'lib{__c_api_library_name}.dylib'
            else:
                raise Exception('Unsupported platform')
        else:
            if is_x64:
                __c_api_extracted_root_dir = __c_api_extracted_root_dir / f'DXFeedAll-{self.__version}-x64-no-tls'
                c_api_extracted_library_dir = __c_api_extracted_root_dir / 'bin' / 'x64'
                c_api_library_file_name = f'lib{__c_api_library_name}.so'
            else:
                raise Exception('Unsupported platform')

        if not os.path.exists(self.__path_to_copy_includes):
            shutil.copytree(__c_api_extracted_root_dir / 'include', self.__path_to_copy_includes)
        if not os.path.exists(self.__path_to_copy_libs / c_api_library_file_name):
            if not os.path.exists(self.__path_to_copy_libs):
                os.makedirs(self.__path_to_copy_libs)
            shutil.copyfile(c_api_extracted_library_dir / c_api_library_file_name,
                            self.__path_to_copy_libs / c_api_library_file_name)
        if platform.system() == 'Windows':
            # noinspection PyUnboundLocalVariable
            if not os.path.exists(self.__path_to_copy_libs / c_api_library_file_name2):
                shutil.copyfile(c_api_extracted_library_dir / c_api_library_file_name2,
                                self.__path_to_copy_libs / c_api_library_file_name2)

        return __c_api_library_name


try:
    from Cython.Build import cythonize
except ImportError:
    use_cython = False
    ext = 'c'
else:
    use_cython = True
    ext = 'pyx'

root_path = Path(__file__).resolve().parent

pyproject = toml.load(root_path / 'pyproject.toml')
c_api_version = pyproject['build']['native-dependencies']['dxfeed_c_api']
if c_api_version == 'env':
    c_api_version = os.getenv('DXFEED_C_API_VERSION')

c_api_root_dir = root_path / 'dxfeed' / 'dxfeed-c-api'
path_to_extract = root_path / 'dxfeed' / 'tmp'
c_api_include_dir = c_api_root_dir / 'include'
c_api_bin_dir = root_path / 'dxfeed' / 'core'

downloader = Downloader(c_api_version, path_to_extract, c_api_include_dir, c_api_bin_dir)
c_api_library_name = downloader.download()

if platform.system() == 'Windows':
    runtime_library_dirs = None
    extra_link_args = None
elif platform.system() == 'Darwin':
    runtime_library_dirs = None
    extra_link_args = ['-Wl,-rpath,@loader_path']
else:
    runtime_library_dirs = ['$ORIGIN']
    extra_link_args = None

c_api_include_dirs = [str(c_api_include_dir)]

libs = [c_api_library_name]
if platform.system() == 'Windows':
    libs.append('ws2_32')

extensions = [Extension('dxfeed.core.utils.helpers', ['dxfeed/core/utils/helpers.' + ext],
                        include_dirs=c_api_include_dirs),
              Extension('dxfeed.core.utils.handler', ['dxfeed/core/utils/handler.' + ext],
                        include_dirs=c_api_include_dirs),
              Extension('dxfeed.core.listeners.listener', ['dxfeed/core/listeners/listener.' + ext],
                        include_dirs=c_api_include_dirs),
              Extension('dxfeed.core.DXFeedPy', ['dxfeed/core/DXFeedPy.' + ext], library_dirs=[str(c_api_bin_dir)],
                        runtime_library_dirs=runtime_library_dirs,
                        extra_link_args=extra_link_args,
                        libraries=libs,
                        include_dirs=c_api_include_dirs)]

if use_cython:
    extensions = cythonize(extensions, language_level=3)


def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': extensions,
        'zip_safe': False,
        'packages': find_packages(),
        'include_dirs': c_api_include_dirs
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
