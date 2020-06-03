.. _core_usage:

Low-level API
=============

Import low-level functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here we deal with low level C styled api

.. code:: ipython3

    from dxfeed.core import DXFeedPy as dxc
    import time  # for timed suscription

Create connection
~~~~~~~~~~~~~~~~~

There are two ways at the moment to create connection: with token or
with specifying connection address. Here we use the latter for
simplicity.

.. code:: ipython3

    con = dxc.dxf_create_connection('demo.dxfeed.com:7300')

Create subscription
~~~~~~~~~~~~~~~~~~~

There are two types of subscriptions: ordinary for delivering stream
data as-is and timed for conflated data. Except type of subscription you
should provide type of events you want to get. Note: some event types,
e.g. Candle, support only timed subscription.

.. code:: ipython3

    sub = dxc.dxf_create_subscription(con, 'Trade')
    sub_timed = dxc.dxf_create_subscription_timed(con, 'Candle', int(time.time() * 1000))

Attach listener
~~~~~~~~~~~~~~~

A special function that processes incoming events should be initialized.
There are default ones for each event type. You can write a listener that will do your instructions.
For details: :ref:`custom_listener`.

.. code:: ipython3

    dxc.dxf_attach_listener(sub)
    dxc.dxf_attach_listener(sub_timed)

Add tickers
~~~~~~~~~~~

Symbols that will be processed should be defined

.. code:: ipython3

    dxc.dxf_add_symbols(sub, ['AAPL', 'MSFT'])
    dxc.dxf_add_symbols(sub_timed, ['AAPL', 'C'])

Access data
~~~~~~~~~~~

Data is stored as deque in subscription class. Its length by default is
100000. When you call method below you extracts all data recieved to the
moment and clears the buffer in class.

.. code:: ipython3

    sub.get_data()

.. code:: ipython3

    sub_timed.get_data()

Detach listener
~~~~~~~~~~~~~~~

When you are no longer interested in recieving data detach the listener

.. code:: ipython3

    dxc.dxf_detach_listener(sub)
    dxc.dxf_detach_listener(sub_timed)

Close connection
~~~~~~~~~~~~~~~~

.. code:: ipython3

    dxc.dxf_close_connection(con)

Transform data to pandas DataFrame
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: ipython3

    df1 = sub.to_dataframe()
    df1.head()

.. code:: ipython3

    df2 = sub_timed.to_dataframe()
    df2.head()
