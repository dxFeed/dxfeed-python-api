.. _basic_usage:

Basic Usage
===========


There are three levels in the dxfeed package. The lowest is the C API
library, the highest is Python wrapper classes. Cython level in the
middle aims to connect these two. Here we are going to look into Python
level.

Python level, in its turn, mainly consists of three class types. The
first one is the Endpoint. This class is responsible for connection
management.

The Endpoint is also responsible for creating dependent classes, for
example Subscription. One Endpoint may have several different
Subscriptions, but each Subscription is related to one Endpoint. This
class sets the type of subscription (stream or timed), the type of
events (e.g. Trade, Candle), etc.

After you specified the data you want to receive, you have to specify
how to process upcoming events. This is where the EventHandler class and
its children come into play. Every time an event arrives Cython event
listener will call ``self.update(event)`` method. You have to inherit
from the EventHandler class and redefine the update method. Or you may
use DefaultHandler which stores upcoming data in deque of the length
100k.

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


.. code-block:: text

    Connected address: demo.dxfeed.com:7300
    Connection status: Connected and authorized
    

Configure and create subscription
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should specify event type. For timed subscription (conflated stream)
you should also provide time to start subscription from.

.. code:: python3

    trade_sub = endpoint.create_subscription('Trade')

**Set event handler** - class that process incoming events. Here we use
default one

.. code:: python3

    trade_handler = dx.DefaultHandler()
    trade_sub.set_event_handler(trade_handler);

**Add tikers** you want to recieve events for

.. code:: python3

    trade_sub = trade_sub.add_symbols(['C', 'IBM'])

For timed subscription you should provide either datetime object or
string. String might be incomlete, in this case you will get warning
with how your provided date parsed automatically

.. code:: python3

    tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                      .add_symbols(['AMZN'])

.. code:: python3

    candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
    candle_sub = candle_sub.add_symbols(['AAPL', 'MSFT'])


.. code-block:: text

    c:\job\python-api\dxfeed\wrappers\class_utils.py:38: UserWarning: Datetime argument does not exactly match %Y-%m-%d %H:%M:%S.%f format, date was parsed automatically as 2020-04-16 13:05:00.000000
      warn(warn_message, UserWarning)
    

**Note** Two previous subscriptions attached DefaultHandler implicitly.
To retrieve instances just call ``get_event_handler()`` method.

.. code:: python3

    tns_handler = tns_sub.get_event_handler()
    candle_handler = candle_sub.get_event_handler()

Subscription instance properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: python3

    print(f'TimeAndSale subscription event type: {tns_sub.event_type}')
    print(f'Candle subscription symbols: {candle_sub.symbols}')


.. code-block:: text

    TimeAndSale subscription event type: TimeAndSale
    Candle subscription symbols: ['AAPL', 'MSFT']
    

Access data from DefaultHandler instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can get colums, list or dataframe. You are also allowed to write
handler that stores no data.

.. code:: python3

    print(f'Trade columns: {trade_handler.columns}')
    print(f'Candle columns: {candle_handler.columns}')


.. code-block:: text

    Trade columns: ['Symbol', 'Price', 'ExchangeCode', 'Size', 'Tick', 'Change', 'DayVolume', 'Time', 'IsETH']
    Candle columns: ['Symbol', 'Index', 'Time', 'Sequence', 'Count', 'Open', 'High', 'Low', 'Close', 'Volume', 'VWap', 'BidVolume', 'AskVolume', 'OpenInterest', 'ImpVolatility']
    

.. code:: python3

    candle_handler.get_dataframe().head(3)




.. raw:: html

    <div>
    <style scoped>
        .dataframe tbody tr th:only-of-type {
            vertical-align: middle;
        }
    
        .dataframe tbody tr th {
            vertical-align: top;
        }
    
        .dataframe thead th {
            text-align: right;
        }
    </style>
    <table border="1" class="dataframe">
      <thead>
        <tr style="text-align: right;">
          <th></th>
          <th>Symbol</th>
          <th>Index</th>
          <th>Time</th>
          <th>Sequence</th>
          <th>Count</th>
          <th>Open</th>
          <th>High</th>
          <th>Low</th>
          <th>Close</th>
          <th>Volume</th>
          <th>VWap</th>
          <th>BidVolume</th>
          <th>AskVolume</th>
          <th>OpenInterest</th>
          <th>ImpVolatility</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th>0</th>
          <td>MSFT</td>
          <td>6838531241273198328</td>
          <td>2020-06-15 11:13:50.566</td>
          <td>1784</td>
          <td>1.0</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>635.0</td>
          <td>184.17</td>
          <td>635.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>1</th>
          <td>MSFT</td>
          <td>6838531241273198326</td>
          <td>2020-06-15 11:13:50.566</td>
          <td>1782</td>
          <td>1.0</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>100.0</td>
          <td>184.17</td>
          <td>100.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>2</th>
          <td>MSFT</td>
          <td>6838531058896471782</td>
          <td>2020-06-15 11:13:08.092</td>
          <td>1766</td>
          <td>1.0</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>184.17</td>
          <td>100.0</td>
          <td>184.17</td>
          <td>100.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
      </tbody>
    </table>
    </div>



.. code:: python3

    candle_handler.get_list()[:3]




.. code-block:: text

    [['MSFT',
      6838531241273198328,
      1592219630566,
      1784,
      1.0,
      184.17,
      184.17,
      184.17,
      184.17,
      635.0,
      184.17,
      635.0,
      nan,
      0,
      nan],
     ['MSFT',
      6838531241273198326,
      1592219630566,
      1782,
      1.0,
      184.17,
      184.17,
      184.17,
      184.17,
      100.0,
      184.17,
      100.0,
      nan,
      0,
      nan],
     ['MSFT',
      6838531058896471782,
      1592219588092,
      1766,
      1.0,
      184.17,
      184.17,
      184.17,
      184.17,
      100.0,
      184.17,
      100.0,
      nan,
      0,
      nan]]



Close subscription
~~~~~~~~~~~~~~~~~~

.. code:: python3

    trade_sub.close_subscription()
    tns_sub.close_subscription()
    candle_sub.close_subscription()

Close connection
~~~~~~~~~~~~~~~~

.. code:: python3

    endpoint.close_connection()
    print(f'Connection status: {endpoint.connection_status}')


.. code-block:: text

    Connection status: Not connected
    
