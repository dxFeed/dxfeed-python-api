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

Special function called listener should be attached to the subscription to start receiving
events. There are default listeners already implemented in dxpyfeed, but you
can write your own with cython: :ref:`custom_listener`. To attach
default listener just call `dxf_attach_listener`

.. code-block:: python

    dxp.dxf_attach_listener(sub1)
    dxp.dxf_attach_listener(sub2)

The data is kept in `data` property of subscription class as dict with columns and list
of events. To look at data call this property:

.. code-block:: python

    sub1.data
    sub2.data

The more convenient way to look at data is to convert it into pandas DataFrame.
`to_dataframe` method of subscription class is responsible for that:

.. code-block:: python

    sub1.to_dataframe()
    sub2.to_dataframe()

To stop receiving events just detach the listener:

.. code-block:: python

     dxp.dxf_detach_listener(sub1)
     dxp.dxf_detach_listener(sub2)

When you are done with subscription you'd better close it:

.. code-block:: python

    dxp.dxf_close_subscription(sub1)
    dxp.dxf_close_subscription(sub2)

Same with connection:

.. code-block:: python

    dxp.dxf_close_connection(con)