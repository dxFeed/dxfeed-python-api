from dxfeed.wrappers.endpoint import Endpoint
from dxfeed.core.utils.handler import EventHandler, DefaultHandler
try:
    from importlib_metadata import version
except ModuleNotFoundError:
    # Python 3.8
    from importlib.metadata import version


__version__ = version('dxfeed')
__all__ = ['Endpoint', 'EventHandler', 'DefaultHandler']
