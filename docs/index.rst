.. meta::
   :description: DXFeed python api for getting stock exchange data
   :keywords: python, api, dxfeed, stock exchange

Home
====

This package provides access to `dxFeed <https://www.dxfeed.com/>`_ streaming data.
The library is build as a thin wrapper over `dxFeed C-API library <https://github.com/dxFeed/dxfeed-c-api>`_.
We use `Cython <https://cython.org/>`_ in this project as it combines flexibility, reliability and
usability in writing C extensions.

This package already contains basic C-API functions related to creating connections, subscriptions etc.
Moreover default listeners (functions responsible for event processing) are ready to use. The user is also able to
write his own custom listener in Cython, the instructions could be found here: :ref:`custom_listener`.

At this web-site you will find information about basic functionality of the library,
how to write your custom listener, documentation to all available functions and information for developers.

Table of contents:
------------------

.. toctree::
   :maxdepth: 2

   self
   installation.rst
   basic_usage.rst
   custom_listener.rst
   api.rst
   devs.rst
