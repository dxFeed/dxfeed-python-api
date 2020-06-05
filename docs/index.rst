.. meta::
   :description: DXFeed python api for getting stock exchange data
   :keywords: python, api, dxfeed, stock exchange, market data, marketdata, finance

Home
====

This package provides access to `dxFeed <https://www.dxfeed.com/>`_ streaming data. The library is
a thin wrapper over `dxFeed C-API library <https://github.com/dxFeed/dxfeed-c-api>`_.
We use `Cython <https://cython.org/>`_ in this project as it combines flexibility, reliability,
and usability in writing C extensions.


dxfeed library already contains basic C-API functions and convenient access to them via wrapper classes.
For now, the package covers the core C-API functionality, for example, creating connections and subscriptions,
receiving data, etc.

Moreover, default listeners (functions responsible for event processing) are ready to use. The user may also
write his custom listener in Cython. The instructions are here: :ref:`custom_listener`.

At this website, you will find information about the functionality of the library, how to write your custom listener,
documentation to all available functions, and information for developers.

Table of contents:
------------------

.. toctree::
   :maxdepth: 2

   self
   installation.rst
   basic_usage.rst
   api.rst
   core_usage.rst
   custom_listener.rst
   devs.rst
