from Cython.Build import cythonize
from setuptools import setup, Extension
import dxfeed

ext = Extension(name="cust",
                sources=["cust.pyx"],
                include_dirs=dxfeed.get_include()
                )

setup(
    ext_modules=cythonize([ext], language_level=3)
)
