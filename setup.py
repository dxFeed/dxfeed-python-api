from setuptools import setup, Extension
from Cython.Build import cythonize
from pathlib import Path


source_files_directory = Path(__file__).resolve().parent.joinpath('lib', 'dxfeed-c-api', 'src')
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
source_files_paths.remove(str(source_files_directory.joinpath('Linux.c')))

new_logic_ext = Extension(
    name="lib",
    sources=["lib/wrapper/connect.pyx"] + source_files_paths,
    language='c',
    include_dirs=["lib/dxfeed-c-api/include/", "lib/dxfeed-c-api/src"],
    libraries=['ws2_32']
)

setup(
    name="pyconnect",
    packages=['pyconnect'],
    package_dir={'pyconnect': 'lib'},
    ext_modules=cythonize([
        new_logic_ext,
        ], language_level=3)
)