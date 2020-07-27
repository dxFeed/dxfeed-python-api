.. _basic_usage:

Basic Usage
===========

There are three levels in the dxfeed package. The lowest is the C API
library, the highest is Python wrapper classes. Cython level in the
middle aims to connect these two. Here we are going to look into Python
level.

Python level, in its turn, mainly consists of three class types:

1. Endpoint
2. Subscription
3. EventHandler

The **Endpoint** is responsible for connection management and creating
dependent classes, for example Subscription. One Endpoint may have
several different Subscriptions, but each Subscription is related to one
Endpoint.

**Subscription** class sets the type of subscription (stream or timed),
the type of events (e.g. Trade, Candle), etc.

After you specified the data you want to receive, you have to specify
how to process upcoming events. This is where the **EventHandler** class
and its children come into play. Every time an event arrives Cython
event listener will call ``self.update(event)`` method. You have to
inherit from the EventHandler class and redefine the update method. Or
you may use DefaultHandler which stores upcoming data in deque of the
length 100k.

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
with how your provided date parsed automatically. For Candle event type
along with base symbol, you should specify an aggregation period. You
can also set price type. More details:
https://kb.dxfeed.com/display/DS/REST+API#RESTAPI-Candlesymbols.

.. code:: python3

    tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                      .add_symbols(['AMZN'])

.. code:: python3

    candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
    candle_sub = candle_sub.add_symbols(['AAPL{=d}', 'MSFT{=d}'])


.. code:: text

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
    print(f'Candle subscription event type: {candle_sub.event_type}')
    print(f'Candle subscription symbols: {candle_sub.symbols}')


.. code:: text

    TimeAndSale subscription event type: TimeAndSale
    Candle subscription event type: Candle
    Candle subscription symbols: ['AAPL{=d}', 'MSFT{=d}']
    

Access data from DefaultHandler instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can get colums, list or dataframe. You are also allowed to write
handler that stores no data.

.. code:: python3

    print(f'Trade columns: {trade_handler.columns}')
    print(f'Candle columns: {candle_handler.columns}')


.. code:: text

    Trade columns: ['Symbol', 'Price', 'ExchangeCode', 'Size', 'Tick', 'Change', 'DayVolume', 'Time', 'IsETH']
    Candle columns: ['Symbol', 'Index', 'Time', 'Sequence', 'Count', 'Open', 'High', 'Low', 'Close', 'Volume', 'VWap', 'BidVolume', 'AskVolume', 'OpenInterest', 'ImpVolatility']
    

.. code:: python3

    candle_handler.get_list()[-5:]




.. code:: text

    [['MSFT{=d}', 6816463568083353600, 1587081600000, 0, 189986.0, 179.5, 180.0, 175.87, 178.6, 52765625.0, 177.90622, 24188832.0, 22094602.0, 0, 0.4384],
     ['MSFT{=d}', 6816294775868620800, 1587042300000, 0, 189986.0, 179.5, 180.0, 175.87, 178.6, 52765625.0, 177.90622, 24188832.0, 22094602.0, 0, 0.4384],
     ['AAPL{=d}', 6839841934068940800, 1592524800000, 0, 827.0, 354.05, 355.55, 353.35, 354.72, 188804.0, 354.45941, 78039.0, 110765.0, 0, 0.3691],
     ['AAPL{=d}', 6839841934068940800, 1592524800000, 0, 831.0, 354.05, 355.55, 353.35, 354.9, 189555.0, 354.4611, 78039.0, 111516.0, 0, 0.3691],
     ['AAPL{=d}', 6839841934068940800, 1592524800000, 0, 832.0, 354.05, 355.55, 353.35, 354.72, 190055.0, 354.46178, 78539.0, 111516.0, 0, 0.3691]]



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
          <td>AAPL{=d}</td>
          <td>6839841934068940800</td>
          <td>2020-06-19</td>
          <td>0</td>
          <td>827.0</td>
          <td>354.05</td>
          <td>355.55</td>
          <td>353.35</td>
          <td>354.72</td>
          <td>188804.0</td>
          <td>354.45941</td>
          <td>78039.0</td>
          <td>110765.0</td>
          <td>0</td>
          <td>0.3691</td>
        </tr>
        <tr>
          <th>1</th>
          <td>AAPL{=d}</td>
          <td>6839470848894566400</td>
          <td>2020-06-18</td>
          <td>0</td>
          <td>96172.0</td>
          <td>351.41</td>
          <td>353.45</td>
          <td>349.22</td>
          <td>351.73</td>
          <td>24205096.0</td>
          <td>351.56873</td>
          <td>8565421.0</td>
          <td>10394906.0</td>
          <td>0</td>
          <td>0.3673</td>
        </tr>
        <tr>
          <th>2</th>
          <td>AAPL{=d}</td>
          <td>6839099763720192000</td>
          <td>2020-06-17</td>
          <td>0</td>
          <td>110438.0</td>
          <td>355.15</td>
          <td>355.40</td>
          <td>351.09</td>
          <td>351.59</td>
          <td>28601626.0</td>
          <td>353.70998</td>
          <td>10686232.0</td>
          <td>12141490.0</td>
          <td>0</td>
          <td>0.3713</td>
        </tr>
      </tbody>
    </table>
    </div>



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


.. code:: text

    Connection status: Not connected
    
