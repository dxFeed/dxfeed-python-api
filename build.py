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
    """Class that downloads a dxFeed C API bundle and places the necessary include or lib files"""

    def __init__(self, version: str, path_to_extract: Path,
                 path_to_copy_includes: Path, path_to_copy_libs: Path):
        """
        Parameters
        ----------
        version : str
            The dxFeed C API version
        path_to_extract : Path
            The temporary directory where the bundle should be unpacked
        path_to_copy_includes : Path
            The directory where the include files should be placed
        path_to_copy_libs
            The directory where the library files should be placed
        """

        self.__version = version
        self.__path_to_extract = path_to_extract
        self.__path_to_copy_includes = path_to_copy_includes
        self.__path_to_copy_libs = path_to_copy_libs

    def download(self, dxfeed_c_api_bundle_url_template: str) -> str:
        """
        The method that does the bulk of the work of downloading and placement files.


        Parameters
        ----------
        dxfeed_c_api_bundle_url_template: str
            The URL template for zipped dxFeed C API bundle. Parameters used:
                {version} - The C API version
                {os}      - The target OS

        Returns
        -------
        : str
            The resulting name of the library, which is required to build an extension

        """
        c_api_extracted_root_path = self.__path_to_extract / f'dxfeed-c-api-{self.__version}-no-tls'
        is_x64 = 8 * struct.calcsize('P') == 64

        url_template_os = 'centos'  # Since centos uses an earlier version of libc

        if platform.system() == 'Darwin':
            url_template_os = 'macosx'
        elif platform.system() == 'Windows':
            url_template_os = 'windows'

        if (not os.path.exists(self.__path_to_extract)) or (not os.path.exists(c_api_extracted_root_path)):
            url = dxfeed_c_api_bundle_url_template.format(version=self.__version, os=url_template_os)
            print(f'Downloading the "{url}"')
            resp = urlopen(url)
            zipfile = ZipFile(BytesIO(resp.read()))
            print(f'Extracting to "{self.__path_to_extract}"')
            zipfile.extractall(self.__path_to_extract)

        c_api_x64_suffix = '_64' if is_x64 else ''
        resulting_c_api_library_name = f'DXFeed{c_api_x64_suffix}'

        # Determine and fixing paths for unpacked artifacts.
        # The workaround is related to the packaging feature on POSIX systems in the dxFeed API' CI\CD.
        if is_x64:
            if platform.system() != 'Windows':
                c_api_extracted_root_path = c_api_extracted_root_path / f'DXFeedAll-{self.__version}-x64-no-tls'

            c_api_extracted_library_path = c_api_extracted_root_path / 'bin' / 'x64'
        else:
            if platform.system() == 'Windows':
                c_api_extracted_library_path = c_api_extracted_root_path / 'bin' / 'x86'
            else:
                raise RuntimeError('Unsupported platform')

        # Determine possible prefixes and extensions for library files
        lib_file_name_prefixes = [''] * 2
        lib_file_name_extensions = ['dll', 'lib']

        if platform.system() != 'Windows':
            lib_file_name_prefixes = ['lib']
            lib_file_name_extensions = ['dylib'] if platform.system() == 'Darwin' else ['so']

        # Create paths for libraries to be copied
        c_api_library_file_source_paths = []
        c_api_library_file_dest_paths = []

        for idx, prefix in enumerate(lib_file_name_prefixes):
            file_name = f'{prefix}{resulting_c_api_library_name}.{lib_file_name_extensions[idx]}'
            c_api_library_file_source_paths.append(c_api_extracted_library_path / file_name)
            c_api_library_file_dest_paths.append(self.__path_to_copy_libs / file_name)

        print('Copying all headers')
        # Copying all headers
        if not Path(self.__path_to_copy_includes).exists():
            shutil.copytree(c_api_extracted_root_path / 'include', self.__path_to_copy_includes)

        # Create a directory where we will copy libraries, if necessary
        if not Path(self.__path_to_copy_libs).exists():
            print(f'Creating the {self.__path_to_copy_libs} path')
            os.makedirs(self.__path_to_copy_libs)

        print('Copying the required libraries')
        # Copying the required libraries
        for idx, path in enumerate(c_api_library_file_source_paths):
            print(f'  {path} -> {c_api_library_file_dest_paths[idx]}')
            shutil.copyfile(path, c_api_library_file_dest_paths[idx])

        return resulting_c_api_library_name


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
c_api_library_name = downloader.download(pyproject['build']['native-dependencies']['dxfeed_c_api_bundle_url_template'])

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
