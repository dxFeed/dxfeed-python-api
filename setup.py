from setuptools import setup, Extension
from Cython.Build import cythonize
from pathlib import Path


source_files_directory = Path(__file__).resolve().parent.joinpath('lib', 'dxfeed-c-api', 'src')
source_files_paths = [str(path) for path in source_files_directory.glob('*.c')]
source_files_paths.remove(str(source_files_directory.joinpath('Linux.c')))

examples_extension = Extension(
    name="pyexamples",
    sources=["pyexamples.pyx"] + source_files_paths,
    language='c',
    include_dirs=["lib/dxfeed-c-api/include/", "lib/dxfeed-c-api/src"],
    libraries=['ws2_32']
)

connection_ext = Extension(
    name="pyconnect",
    sources=["pyconnect.pyx", "pydisconnect.pyx"] + source_files_paths,
    language='c',
    include_dirs=["lib/dxfeed-c-api/include/", "lib/dxfeed-c-api/src"],
    libraries=['ws2_32']
)

disconnection_ext = Extension(
    name="pydisconnect",
    sources=["pydisconnect.pyx"] + source_files_paths,
    language='c',
    include_dirs=["lib/dxfeed-c-api/include/", "lib/dxfeed-c-api/src"],
    libraries=['ws2_32']
)

setup(
    name="pyconnect",
    ext_modules=cythonize([
        disconnection_ext,
        connection_ext,
        # examples_extension
        ], language_level=3)
)