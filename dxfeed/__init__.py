from dxfeed.wrappers.endpoint import Endpoint
from dxfeed.core.utils.handler import EventHandler, DefaultHandler
import pkg_resources

try:
    __version__ = pkg_resources.get_distribution('dxfeed').version
except pkg_resources.DistributionNotFound:
    import toml
    from pathlib import Path
    pyproject = toml.load(Path(__file__).parents[1].joinpath('pyproject.toml'))
    __version__ = pyproject['tool']['poetry']['version']
