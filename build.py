import os
import shutil
import struct

from setuptools import Extension, find_packages
from setuptools.dist import Distribution
from pathlib import Path
from io import BytesIO
from zipfile import ZipFile
from urllib.request import urlopen
import platform

try:
    from Cython.Build import cythonize
except ImportError:
    use_cython = False
    ext = 'c'
else:
    use_cython = True
    ext = 'pyx'

root_path = Path(__file__).resolve().parent
print(root_path)

capi_version = '8.3.0'

is_x64 = 8 * struct.calcsize("P") == 64

if platform.system() == 'Windows':
    current_os = 'windows'
elif platform.system() == 'Darwin':
    current_os = 'macosx'
else:
    current_os = 'centos'

capi_root_dir = root_path / 'dxfeed' / 'dxfeed-c-api'
capi_include_dir = capi_root_dir / 'include'
# capi_bin_dir = capi_root_dir / 'bin'
capi_bin_dir = root_path / 'dxfeed' / 'core'
path_to_extract = root_path / 'dxfeed' / 'tmp'
capi_extracted_root_dir = path_to_extract / f'dxfeed-c-api-{capi_version}-no-tls'

if (not os.path.exists(path_to_extract)) or (not os.path.exists(capi_extracted_root_dir)):
    url = f'https://github.com/dxFeed/dxfeed-c-api/releases/download/{capi_version}/dxfeed-c-api-{capi_version}-' \
          f'{current_os}-no-tls.zip '
    print(f'Downloading the "{url}"')
    resp = urlopen(url)
    zipfile = ZipFile(BytesIO(resp.read()))
    print(f'Extracting to "{path_to_extract}"')
    zipfile.extractall(path_to_extract)

if platform.system() == 'Windows':
    if is_x64:
        capi_extracted_library_dir = capi_extracted_root_dir / 'bin' / 'x64'
        capi_library_name = 'DXFeed_64'
        capi_library_file_name = f'{capi_library_name}.dll'
        capi_library_file_name2 = f'{capi_library_name}.lib'
    else:
        capi_extracted_library_dir = capi_extracted_root_dir / 'bin' / 'x86'
        capi_library_name = 'DXFeed'
        capi_library_file_name = f'{capi_library_name}.dll'
        capi_library_file_name2 = f'{capi_library_name}.lib'
elif platform.system() == 'Darwin':
    if is_x64:
        capi_extracted_root_dir = capi_extracted_root_dir / f'DXFeedAll-{capi_version}-x64-no-tls'
        capi_extracted_library_dir = capi_extracted_root_dir / 'bin' / 'x64'
        capi_library_name = 'DXFeed_64'
        capi_library_file_name = f'lib{capi_library_name}.dylib'
    else:
        raise Exception('Unsupported platform')
else:
    if is_x64:
        capi_extracted_root_dir = capi_extracted_root_dir / f'DXFeedAll-{capi_version}-x64-no-tls'
        capi_extracted_library_dir = capi_extracted_root_dir / 'bin' / 'x64'
        capi_library_name = 'DXFeed_64'
        capi_library_file_name = f'lib{capi_library_name}.so'
    else:
        raise Exception('Unsupported platform')

if not os.path.exists(capi_include_dir):
    shutil.copytree(capi_extracted_root_dir / 'include', capi_include_dir)
if not os.path.exists(capi_bin_dir / capi_library_file_name):
    #    os.makedirs(capi_bin_dir)
    shutil.copyfile(capi_extracted_library_dir / capi_library_file_name, capi_bin_dir / capi_library_file_name)
if platform.system() == 'Windows':
    # noinspection PyUnboundLocalVariable
    if not os.path.exists(capi_bin_dir / capi_library_file_name2):
        shutil.copyfile(capi_extracted_library_dir / capi_library_file_name2, capi_bin_dir / capi_library_file_name2)

if platform.system() == 'Windows':
    runtime_library_dirs = None
    extra_compiler_args = None
elif platform.system() == 'Darwin':
    runtime_library_dirs = ['.', str(capi_bin_dir)]
    extra_compiler_args = [f'-Wl,-rpath,.', f'-Wl,-rpath,{str(capi_bin_dir)}']
else:
    runtime_library_dirs = ["$ORIGIN", '.', str(capi_bin_dir)]
    extra_compiler_args = None

capi_include_dirs = [str(capi_include_dir)]

libs = [capi_library_name]
if platform.system() == 'Windows':
    libs.append('ws2_32')

extensions = [Extension('dxfeed.core.utils.helpers', ['dxfeed/core/utils/helpers.' + ext],
                        include_dirs=capi_include_dirs),
              Extension('dxfeed.core.utils.handler', ['dxfeed/core/utils/handler.' + ext],
                        include_dirs=capi_include_dirs),
              Extension('dxfeed.core.listeners.listener', ['dxfeed/core/listeners/listener.' + ext],
                        include_dirs=capi_include_dirs),
              Extension('dxfeed.core.DXFeedPy', ['dxfeed/core/DXFeedPy.' + ext], library_dirs=[str(capi_bin_dir)],
                        runtime_library_dirs=runtime_library_dirs,
                        extra_compiler_args=extra_compiler_args,
                        libraries=libs,
                        include_dirs=capi_include_dirs)]

if use_cython:
    extensions = cythonize(extensions, language_level=3)


def build(setup_kwargs):
    setup_kwargs.update({
        'ext_modules': extensions,
        'zip_safe': False,
        'packages': find_packages(),
        'include_dirs': capi_include_dirs
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

    print(f'Removing the "{path_to_extract}"')
    if os.path.exists(path_to_extract):
        shutil.rmtree(path_to_extract)
