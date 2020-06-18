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
    sub_timed = dxc.dxf_create_subscription_timed(con, 'Candle', int(datetime.now().timestamp()))

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

Symbols that will be processed should be defined

.. code:: python3

    dxc.dxf_add_symbols(sub, ['AAPL', 'MSFT'])
    dxc.dxf_add_symbols(sub_timed, ['AAPL', 'C'])

Access data
~~~~~~~~~~~

The DefaultHandler class has ``get_list()`` and ``get_dataframe()``
methods to access the data.

.. code:: python3

    trade_handler.get_list()[:3]




.. code:: text

    [['AAPL', 336.1948, 'D', 300, 1, -2.6052, 6946983.0, 1592230640159, 0],
     ['MSFT', 187.41, 'N', 200, 1, -0.33, 6418645.0, 1592230639955, 0],
     ['AAPL', 336.8, 'A', 100, 2, -2.35, 5890.0, 1592230481599, 0]]



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
          <td>AAPL</td>
          <td>6838585486932591349</td>
          <td>2020-06-15 14:44:20.619</td>
          <td>148213</td>
          <td>1.0</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>200.0</td>
          <td>335.225</td>
          <td>200.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>1</th>
          <td>AAPL</td>
          <td>6838585485699465971</td>
          <td>2020-06-15 14:44:20.325</td>
          <td>148211</td>
          <td>1.0</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>1500.0</td>
          <td>335.212</td>
          <td>1500.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>2</th>
          <td>AAPL</td>
          <td>6838585485678494449</td>
          <td>2020-06-15 14:44:20.320</td>
          <td>148209</td>
          <td>1.0</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>200.0</td>
          <td>335.220</td>
          <td>NaN</td>
          <td>200.0</td>
          <td>0</td>
          <td>NaN</td>
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
    df1.head()




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
          <td>336.600</td>
          <td>Q</td>
          <td>150</td>
          <td>2</td>
          <td>-2.200</td>
          <td>2144212.0</td>
          <td>2020-06-15 14:17:59.802</td>
          <td>0</td>
        </tr>
        <tr>
          <th>1</th>
          <td>AAPL</td>
          <td>336.600</td>
          <td>Q</td>
          <td>150</td>
          <td>2</td>
          <td>-2.200</td>
          <td>7000532.0</td>
          <td>2020-06-15 14:17:59.802</td>
          <td>0</td>
        </tr>
        <tr>
          <th>2</th>
          <td>AAPL</td>
          <td>336.610</td>
          <td>K</td>
          <td>100</td>
          <td>1</td>
          <td>-1.920</td>
          <td>325307.0</td>
          <td>2020-06-15 14:17:58.368</td>
          <td>0</td>
        </tr>
        <tr>
          <th>3</th>
          <td>MSFT</td>
          <td>187.511</td>
          <td>D</td>
          <td>100</td>
          <td>2</td>
          <td>-0.209</td>
          <td>2083825.0</td>
          <td>2020-06-15 14:17:59.731</td>
          <td>0</td>
        </tr>
        <tr>
          <th>4</th>
          <td>MSFT</td>
          <td>187.511</td>
          <td>D</td>
          <td>100</td>
          <td>2</td>
          <td>-0.229</td>
          <td>6458892.0</td>
          <td>2020-06-15 14:17:59.731</td>
          <td>0</td>
        </tr>
      </tbody>
    </table>
    </div>



.. code:: python3

    df2 = candle_handler.get_dataframe()
    df2.head()




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
          <td>AAPL</td>
          <td>6838585486932591349</td>
          <td>2020-06-15 14:44:20.619</td>
          <td>148213</td>
          <td>1.0</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>335.225</td>
          <td>200.0</td>
          <td>335.225</td>
          <td>200.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>1</th>
          <td>AAPL</td>
          <td>6838585485699465971</td>
          <td>2020-06-15 14:44:20.325</td>
          <td>148211</td>
          <td>1.0</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>335.212</td>
          <td>1500.0</td>
          <td>335.212</td>
          <td>1500.0</td>
          <td>NaN</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>2</th>
          <td>AAPL</td>
          <td>6838585485678494449</td>
          <td>2020-06-15 14:44:20.320</td>
          <td>148209</td>
          <td>1.0</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>200.0</td>
          <td>335.220</td>
          <td>NaN</td>
          <td>200.0</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>3</th>
          <td>AAPL</td>
          <td>6838585485678494447</td>
          <td>2020-06-15 14:44:20.320</td>
          <td>148207</td>
          <td>1.0</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>100.0</td>
          <td>335.220</td>
          <td>NaN</td>
          <td>100.0</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
        <tr>
          <th>4</th>
          <td>AAPL</td>
          <td>6838585485678494445</td>
          <td>2020-06-15 14:44:20.320</td>
          <td>148205</td>
          <td>1.0</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>335.220</td>
          <td>100.0</td>
          <td>335.220</td>
          <td>NaN</td>
          <td>100.0</td>
          <td>0</td>
          <td>NaN</td>
        </tr>
      </tbody>
    </table>
    </div>


