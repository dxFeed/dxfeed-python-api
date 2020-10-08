from setuptools import setup
from build import *

global setup_kwargs

setup_kwargs = {}

build_extensions()
build(setup_kwargs)
setup(**setup_kwargs)
