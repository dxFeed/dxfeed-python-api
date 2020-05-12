from setuptools import setup
from build import *

global setup_kwargs

setup_kwargs = {'extras_require': {'docs': ['toml', 'cython']}}

build(setup_kwargs)
setup(**setup_kwargs)