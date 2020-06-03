.. _basic_usage:

Basic Usage
===========

Import package
~~~~~~~~~~~~~~

.. code:: ipython3

    import dxfeed as dx
    from datetime import datetime  # for timed subscription

Configure and create connection with Endpoint class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create instance of Endpoint class which will connect provided address.

.. code:: ipython3

    endpoint = dx.Endpoint('demo.dxfeed.com:7300')

Endpoint instance contains information about the connection,
e.g. connection address or status

.. code:: ipython3

    print(f'Connected address: {endpoint.address}')
    print(f'Connection status: {endpoint.connection_status}')

Configure and create subscription
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should specify event type. For timed subscription (conflated stream)
you should also provide time to start subscription from.

.. code:: ipython3

    trade_sub = endpoint.create_subscription('Trade', data_len=-1)

**Attach default listener** - function that process incoming events

.. code:: ipython3

    trade_sub = trade_sub.attach_listener()

**Add tikers** you want to recieve events for

.. code:: ipython3

    trade_sub = trade_sub.add_symbols(['C', 'TSLA'])

For timed subscription you may provide either datetime object or string.
String might be incomlete, in this case you will get warning with how
your provided date parsed automatically

.. code:: ipython3

    tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                      .attach_listener() \
                      .add_symbols(['AMZN'])

.. code:: ipython3

    candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
    candle_sub = candle_sub.attach_listener()
    candle_sub = candle_sub.add_symbols(['AAPL', 'MSFT'])

Subscription instance properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: ipython3

    print(f'Subscription event type: {tns_sub.event_type}')
    print(f'Subscription symbols: {candle_sub.symbols}')

Access data
~~~~~~~~~~~

Data is stored as deque. Its length is configured with data_len
parameter and by default is 100000. When you call method below you
extracts all data recieved to the moment and clears the buffer in class.

.. code:: ipython3

    candle_sub.get_data()

Detach listener
~~~~~~~~~~~~~~~

.. code:: ipython3

    trade_sub.detach_listener()
    tns_sub.detach_listener()
    candle_sub.detach_listener();

Close connection
~~~~~~~~~~~~~~~~

.. code:: ipython3

    endpoint.close_connection()
    print(f'Connection status: {endpoint.connection_status}')

Transform data to pandas DataFrame
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: ipython3

    trade_df = trade_sub.to_dataframe()
    trade_df.head()

.. code:: ipython3

    tns_df = tns_sub.to_dataframe()
    tns_df.head()

.. code:: ipython3

    candle_df = candle_sub.to_dataframe()
    candle_df.head()
