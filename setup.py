from setuptools import setup
from build import *

global setup_kwargs

setup_kwargs = {'extras_require': {'docs': ['cython>=0.29.13']}}

build(setup_kwargs)
setup(**setup_kwargs)
