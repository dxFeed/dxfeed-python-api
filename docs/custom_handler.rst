.. _custom_handler:

Custom Event Handler
====================
Here we will look into custom event handler implementation. Unlike the
Basic Usage example, we will not pay much attention to anything behind
the handler.

Handler is a special object inherited from dxfeed.EventHandler class. It
is attached to the Subscription. When an event comes, internal
structures call the update method of your handler with event as a
parameter. event is a list with data specific to each event type. For
example, for the Trade event type: ‘Symbol’, ‘Price’, ‘ExchangeCode’,
‘Size’, ‘Tick’, ‘Change’, ‘DayVolume’, ‘Time’, ‘IsETH’. More info here:
https://kb.dxfeed.com/display/DS/dxFeed+API+Market+Events

After adding symbols or attaching a default listener (what is actually
done implicitly in the first case) list of one-word descriptions of
event data is stored in columns field of your handler object, attached
to Subscription.

In this example, we will implement the event handler that prints price
and volume changes for candle ask events. It also prints average volume
change for the last 10 ask events.

Import package
~~~~~~~~~~~~~~

.. code:: python3

    import dxfeed as dx
    from dxfeed.core.utils.data_class import DequeWithLock # custom deque with thread lock
    from datetime import datetime  # for timed subscription
    from dateutil.relativedelta import relativedelta
    import numpy as np

Configure and create connection with Endpoint class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create instance of Endpoint class which will connect provided address.

.. code:: python3

    endpoint = dx.Endpoint('demo.dxfeed.com:7300')

Configure and create subscription
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should specify event type. For timed subscription (conflated stream)
you should also provide time to start subscription from.

.. code:: python3

    candle_sub = endpoint.create_subscription('Candle', date_time=datetime.now() - relativedelta(days=3))

.. code:: ipython3

    class DiffHandler(dx.EventHandler):
        def __init__(self):
            self.__prev_open = None
            self.__prev_high = None
            self.__prev_low = None
            self.__prev_close = None
            self.__prev_volume = None
            self.volume_changes = DequeWithLock()
            self.counter = 0

        def update(self, event):
            if not np.isnan(event.ask_volume):  # AskVolume not nan
                self.counter += 1
                print(f'Symbol: {event.symbol}')
                if self.counter == 1:
                    self.__prev_open = event.open
                    self.__prev_high = event.high
                    self.__prev_low = event.low
                    self.__prev_close = event.close
                    self.__prev_volume = event.ask_volume
                    print('First event processed')
                    print('-------------------')
                else:
                    print(f'Open changed by: {event.open - self.__prev_open}')
                    self.__prev_open = event.open
                    print(f'High changed by: {event.high - self.__prev_high}')
                    self.__prev_high = event.high
                    print(f'Open changed by: {event.low - self.__prev_low}')
                    self.__prev_low = event.low
                    print(f'Close changed by: {event.close - self.__prev_close}')
                    self.__prev_close = event.close
                    # Volume logic
                    vol_change = event.ask_volume - self.__prev_volume
                    self.volume_changes.safe_append(vol_change)
                    print(f'Volume changed by: {vol_change}, from {self.__prev_volume}, to {event.ask_volume}')
                    self.__prev_volume = event.ask_volume
                    print(f'Ask events prcessed: {self.counter}')
                    print('-------------------')
                    if self.counter % 10 == 0:
                        print(f'Average volume change for 10 past ask events is: {sum(self.volume_changes) / len(self.volume_changes)}')
                        self.volume_changes.clear()
                        print('-------------------')

For Candle event type along with base symbol, you should specify an
aggregation period. You can also set price type. More details:
https://kb.dxfeed.com/display/DS/REST+API#RESTAPI-Candlesymbols

.. code:: python3

    handler = DiffHandler()
    candle_sub.set_event_handler(handler).add_symbols(['AAPL{=d}']);


.. code:: text

    Symbol: AAPL{=d}
    First event processed
    -------------------
    Symbol: AAPL{=d}
    Open changed by: -2.6399999999999864
    High changed by: -1.0500000000000114
    Open changed by: -4.1299999999999955
    Close changed by: -1.8199999999999932
    Volume changed by: 10387567.0, from 7339.0, to 10394906.0
    Ask events prcessed: 2
    -------------------
    Symbol: AAPL{=d}
    Open changed by: 3.7399999999999523
    High changed by: 1.9499999999999886
    Open changed by: 1.8699999999999477
    Close changed by: -0.1400000000000432
    Volume changed by: 1746584.0, from 10394906.0, to 12141490.0
    Ask events prcessed: 3
    -------------------
    Symbol: AAPL{=d}
    Open changed by: 0.0
    High changed by: 0.0
    Open changed by: 0.0
    Close changed by: 0.0
    Volume changed by: 0.0, from 12141490.0, to 12141490.0
    Ask events prcessed: 4
    -------------------


Close subscription
~~~~~~~~~~~~~~~~~~

.. code:: python3

    candle_sub.close_subscription()

Close connection
~~~~~~~~~~~~~~~~

.. code:: python3

    endpoint.close_connection()
    print(f'Connection status: {endpoint.connection_status}')


.. code:: text

    Connection status: Not connected

