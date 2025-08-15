.. _core_usage:

Low-level API
=============

.. note::
    High-Level API have priority support in case of any issues. We highly recommend
    to use it and touch the Low-Level API only in special cases.

This tutorial is about the Cython level of the package, which connects
Python and C API. Though high-level Python classes provide the necessary
functionality safely and conveniently, the user is not restricted to use
low-level functions.

Import core functions
~~~~~~~~~~~~~~~~~~~~~

Here we deal with low level C styled api, so the import is slightly
differ.

.. code:: python3

    from dxfeed.core import DXFeedPy as dxc
    from dxfeed.core.utils.handler import DefaultHandler
    from datetime import datetime  # for timed suscription
    from dateutil.relativedelta import relativedelta

Create connection
~~~~~~~~~~~~~~~~~

There are two ways at the moment to create connection: with token or
with specifying connection address. Here we use the latter for
simplicity.

.. code:: python3

    con = dxc.dxf_create_connection('demo.dxfeed.com:7300')

Create subscription
~~~~~~~~~~~~~~~~~~~

There are two types of subscriptions: ordinary for delivering stream
data as-is and timed for conflated data. Except type of subscription you
should provide type of events you want to get. Note: some event types,
e.g. Candle, support only timed subscription.

.. code:: python3

    sub = dxc.dxf_create_subscription(con, 'Trade')
    sub_timed = dxc.dxf_create_subscription_timed(con, 'Candle', int((datetime.now() - relativedelta(days=3)).timestamp()))

Attach event handler
~~~~~~~~~~~~~~~~~~~~

To process incoming data you have to define define ``update(event)``
method in your EventHandler child class. Or you may use DefaultHandler
which stores upcoming data in deque of the length 100k. In this example
we choose the latter.

.. code:: python3

    trade_handler = DefaultHandler()
    candle_handler = DefaultHandler()

.. code:: python3

    sub.set_event_handler(trade_handler)
    sub_timed.set_event_handler(candle_handler)

Attach listener
~~~~~~~~~~~~~~~

A special function that processes incoming on the C level events should
be initialized. There are default ones for each event type.

.. code:: python3

    dxc.dxf_attach_listener(sub)
    dxc.dxf_attach_listener(sub_timed)

Add tickers
~~~~~~~~~~~

Symbols that will be processed should be defined. For Candle event type
along with base symbol, you should specify an aggregation period. You
can also set price type. More details:
https://kb.dxfeed.com/en/market-data-api/data-access-solutions/rest.html#candle-symbols.

.. code:: python3

    dxc.dxf_add_symbols(sub, ['AAPL', 'MSFT'])
    dxc.dxf_add_symbols(sub_timed, ['AAPL{=d}', 'MSFT{=d}'])

Access data
~~~~~~~~~~~

The DefaultHandler class has ``get_list()`` and ``get_dataframe()``
methods to access the data.

.. code:: python3

    trade_handler.get_list()[-5:]




.. code:: text

    [['MSFT', 196.14, 'X', 100, 2, 0.0, 100.0, 1592510399515, 0],
     ['MSFT', 196.27, 'Y', 100, 2, 0.0, 18.0, 1592510398017, 0],
     ['MSFT', 196.33, 'Z', 100, 1, 0.0, 2693.0, 1592510399823, 0],
     ['AAPL', 351.57, 'D', 200, 1, 0.0, 44022.0, 1592510399435, 0],
     ['AAPL', 351.73, 'Q', 1406354, 1, 0.0, 234771.0, 1592510400351, 0]]



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
          <td>807.0</td>
          <td>354.05</td>
          <td>355.55</td>
          <td>353.35</td>
          <td>354.79</td>
          <td>184838.0</td>
          <td>354.45447</td>
          <td>75518.0</td>
          <td>109320.0</td>
          <td>0</td>
          <td>0.3690</td>
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



Detach listener
~~~~~~~~~~~~~~~

When you are no longer interested in recieving data detach the listener

.. code:: python3

    dxc.dxf_detach_listener(sub)
    dxc.dxf_detach_listener(sub_timed)

Close connection
~~~~~~~~~~~~~~~~

.. code:: python3

    dxc.dxf_close_connection(con)

Transform data to pandas DataFrame
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python3

    df1 = trade_handler.get_dataframe()
    df1.head(3)




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
          <th>Price</th>
          <th>ExchangeCode</th>
          <th>Size</th>
          <th>Tick</th>
          <th>Change</th>
          <th>DayVolume</th>
          <th>Time</th>
          <th>IsETH</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th>0</th>
          <td>AAPL</td>
          <td>351.73</td>
          <td>Q</td>
          <td>1406354</td>
          <td>1</td>
          <td>0.0</td>
          <td>234761.0</td>
          <td>2020-06-18 20:00:00.351</td>
          <td>0</td>
        </tr>
        <tr>
          <th>1</th>
          <td>AAPL</td>
          <td>351.73</td>
          <td>Q</td>
          <td>1406354</td>
          <td>1</td>
          <td>0.0</td>
          <td>41051.0</td>
          <td>2020-06-18 20:00:00.351</td>
          <td>0</td>
        </tr>
        <tr>
          <th>2</th>
          <td>MSFT</td>
          <td>196.32</td>
          <td>Q</td>
          <td>2364517</td>
          <td>2</td>
          <td>0.0</td>
          <td>160741.0</td>
          <td>2020-06-18 20:00:00.327</td>
          <td>0</td>
        </tr>
      </tbody>
    </table>
    </div>



.. code:: python3

    df2 = candle_handler.get_dataframe()
    df2.head(3)




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
          <td>807.0</td>
          <td>354.05</td>
          <td>355.55</td>
          <td>353.35</td>
          <td>354.79</td>
          <td>184838.0</td>
          <td>354.45447</td>
          <td>75518.0</td>
          <td>109320.0</td>
          <td>0</td>
          <td>0.3690</td>
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
