.. _basic_usage:

Basic Usage
===========

All the functions in C API have similar ones in Python with the same name. Not all arguments are
supported by now, this work is in progress.

First of all you have to import the package:

.. code-block:: python

    import dxpyfeed as dxp

Next, the connection to dxfeed server should be established:

.. code-block:: python

    con = dxp.dxf_create_connection(address='demo.dxfeed.com:7300')

To get events of certain types the subscription with this type should be
create. One connection may have several subscriptions.

.. code-block:: python

    sub1 = dxp.dxf_create_subscription(con, 'Trade')
    sub2 = dxp.dxf_create_subscription(con, 'Quote')

.. note::

    'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
    'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' event types are supported.

Each subscription should be provided with tickers to get events for:

.. code-block:: python

    dxp.dxf_add_symbols(sub1, ['AAPL', 'MSFT'])
    dxp.dxf_add_symbols(sub2, ['AAPL', 'C'])

Special function called listener should be attached to the subscription to start recieving
events. There are default listeners already implemented in dxpyfeed, but you
can write your own with cython. :ref:`custom_listener_tutorial`