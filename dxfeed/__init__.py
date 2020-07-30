from dxfeed.wrappers.endpoint import Endpoint
from dxfeed.core.utils.handler import EventHandler, DefaultHandler
import pkg_resources
import toml
from pathlib import Path


try:
    __version__ = pkg_resources.get_distribution('dxfeed').version
except pkg_resources.DistributionNotFound:
    pyproject = toml.load(Path(__file__).parents[1] / 'pyproject.toml')
    __version__ = pyproject['tool']['poetry']['version']
