.. _basic_usage:

Basic Usage
===========

Import package
~~~~~~~~~~~~~~

.. code:: python3

    import dxfeed as dx
    from datetime import datetime  # for timed subscription

Configure and create connection with Endpoint class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create instance of Endpoint class which will connect provided address.

.. code:: python3

    endpoint = dx.Endpoint('demo.dxfeed.com:7300')

Endpoint instance contains information about the connection,
e.g. connection address or status

.. code:: python3

    print(f'Connected address: {endpoint.address}')
    print(f'Connection status: {endpoint.connection_status}')

.. code:: text

    Connected address: demo.dxfeed.com:7300
    Connection status: Connected and authorized

Configure and create subscription
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should specify event type. For timed subscription (conflated stream)
you should also provide time to start subscription from.

.. code:: python3

    trade_sub = endpoint.create_subscription('Trade', data_len=-1)

**Attach default listener** - function that process incoming events

.. code:: python3

    trade_sub = trade_sub.attach_listener()

**Add tikers** you want to recieve events for

.. code:: python3

    trade_sub = trade_sub.add_symbols(['C', 'AAPL'])

For timed subscription you may provide either datetime object or string.
String might be incomlete, in this case you will get warning with how
your provided date parsed automatically

.. code:: python3

    tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                      .attach_listener() \
                      .add_symbols(['AMZN'])

.. code:: python3

    candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
    candle_sub = candle_sub.attach_listener()
    candle_sub = candle_sub.add_symbols(['AAPL', 'MSFT'])

Subscription instance properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: python3

    print(f'Subscription event type: {tns_sub.event_type}')
    print(f'Subscription symbols: {candle_sub.symbols}')

.. code:: text

    Subscription event type: TimeAndSale
    Subscription symbols: ['AAPL', 'MSFT']

Access data
~~~~~~~~~~~

Data is stored as deque. Its length is configured with data_len
parameter and by default is 100000. When you call method below you
extracts all data recieved to the moment and clears the buffer in class.

.. code:: python3

    candle_sub.get_data()

Close connection
~~~~~~~~~~~~~~~~

.. code:: python3

    endpoint.close_connection()
    print(f'Connection status: {endpoint.connection_status}')

.. code:: text

    Connection status: Not connected

Transform data to pandas DataFrame
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python3

    trade_df = trade_sub.to_dataframe()
    tns_df = tns_sub.to_dataframe()
    candle_df = candle_sub.to_dataframe()
