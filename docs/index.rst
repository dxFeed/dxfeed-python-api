.. meta::
   :description lang=en: DxFeed python api for getting realtime and delayed stock exchange data.
   :keywords: python, api, dxfeed, stock exchange, market data, marketdata, finance, realtime, delayed, order, candle

Home
====

This package provides access to `dxFeed <https://www.dxfeed.com/>`_ streaming data. The library is
a thin wrapper over `dxFeed C-API library <https://github.com/dxFeed/dxfeed-c-api>`_.
We use `Cython <https://cython.org/>`_ in this project as it combines flexibility, reliability,
and usability in writing C extensions.


The design of the dxfeed package allows users to write any logic related to events in python as well as
extending lower level Cython functionality. Moreover, one may start working with the API using the default
values like function arguments or a default event handler.

On this website, you will find dxfeed usage examples and docstrings to each function, class,
and its methods and fields.

Source code: `github.com/dxFeed/dxfeed-python-api <https://github.com/dxFeed/dxfeed-python-api>`_

Package distribution: `pypi.org/project/dxfeed <https://pypi.org/project/dxfeed>`_

Table of contents:
------------------

.. toctree::
   :maxdepth: 2

   self
   installation.rst
   basic_usage.rst
   custom_handler.rst
   api.rst
   core_usage.rst
   custom_listener.rst
   devs.rst
