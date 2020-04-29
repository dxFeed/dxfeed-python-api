.. _basic_usage:

Basic Usage
===========

All the functions in C API have similar ones in Python with the same name. Not all arguments are
supported by now, this work is in progress.

First of all you have to import the package:

.. code-block:: python

    import dxfeed as dx

Next, the connection to dxfeed server should be established:

.. code-block:: python

    con = dx.dxf_create_connection(address='demo.dxfeed.com:7300')

To get events of certain types the subscription with this type should be
create. One connection may have several subscriptions.

.. code-block:: python

    sub1 = dx.dxf_create_subscription(con, 'Trade')
    sub2 = dx.dxf_create_subscription(con, 'Quote')

.. note::

    'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
    'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' event types are supported.

Special function called listener should be attached to the subscription to start receiving
events. There are default listeners already implemented in dxpyfeed, but you
can write your own with cython: :ref:`custom_listener`. To attach
default listener just call `dxf_attach_listener`

.. code-block:: python

    dx.dxf_attach_listener(sub1)
    dx.dxf_attach_listener(sub2)

Each subscription should be provided with tickers to get events for:

.. code-block:: python

    dx.dxf_add_symbols(sub1, ['AAPL', 'MSFT'])
    dx.dxf_add_symbols(sub2, ['AAPL', 'C'])

The data can be extracted with `get_data()` method. It is stored as dict with list of columns and list
of events. Note that `get_data` extracts the data and then clean the field. To look at data call this property:

.. code-block:: python

    sub1.get_data()
    sub2.get_data()

The more convenient way to look at data is to convert it into pandas DataFrame.
`to_dataframe` method of subscription class is responsible for that:

.. code-block:: python

    sub1.to_dataframe()
    sub2.to_dataframe()

To stop receiving events just detach the listener:

.. code-block:: python

     dx.dxf_detach_listener(sub1)
     dx.dxf_detach_listener(sub2)

When you are done with subscription you'd better close it:

.. code-block:: python

    dx.dxf_close_subscription(sub1)
    dx.dxf_close_subscription(sub2)

Same with connection:

.. code-block:: python

    dx.dxf_close_connection(con)