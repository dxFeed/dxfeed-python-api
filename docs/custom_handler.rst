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
‘Size’, ‘Tick’, ‘Change’, ‘DayVolume’, ‘Time’, ‘IsETH’.

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
    from datetime import datetime  # for timed subscription
    from dateutil.relativedelta import relativedelta

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

    candle_sub = endpoint.create_subscription('Candle', date_time=datetime.now() - relativedelta(minutes=30))

.. code:: python3

    class DiffHandler(dx.EventHandler):
        def __init__(self):
            self.__prev_open = 0
            self.__prev_high = 0
            self.__prev_low = 0
            self.__prev_close = 0
            self.__prev_volume = 0
            self.volume_changes = list()
            self.counter = 0
            
        def update(self, event):
            if event[12] == event[12]:  # AskVolume not nan
                print(f'Symbol: {event[0]}')
                print(f'Open changed by: {event[5] - self.__prev_open}')
                self.__prev_open = event[5]
                print(f'High changed by: {event[6] - self.__prev_high}')
                self.__prev_high = event[6]
                print(f'Open changed by: {event[7] - self.__prev_low}')
                self.__prev_low = event[7]
                print(f'Close changed by: {event[8] - self.__prev_close}')
                self.__prev_close = event[8]
                # Volume logic
                vol_change = event[12] - self.__prev_volume
                self.volume_changes.append(vol_change)
                self.counter +=1
                print(f'Volume changed by: {vol_change}, from {self.__prev_volume}, to {event[12]}')
                self.__prev_volume = event[12]
                print(f'Ask events processed: {self.counter}')
                print('-------------------')
                if self.counter % 10 == 0:
                    print(f'Average volume change for 10 past ask events is: {sum(self.volume_changes) / len(self.volume_changes)}')
                    self.volume_changes.clear()
                    print('-------------------')

.. code:: python3

    handler = DiffHandler()
    candle_sub.set_event_handler(handler).add_symbols(['AAPL'])


.. code-block:: text

    Symbol: AAPL
    Open changed by: 336.3
    High changed by: 336.3
    Open changed by: 336.3
    Close changed by: 336.3
    Volume changed by: 200.0, from 0, to 200.0
    Ask events processed: 1
    -------------------
    Symbol: AAPL
    Open changed by: 0.05989999999997053
    High changed by: 0.05989999999997053
    Open changed by: 0.05989999999997053
    Close changed by: 0.05989999999997053
    Volume changed by: -75.0, from 200.0, to 125.0
    Ask events processed: 2
    -------------------
    Symbol: AAPL
    Open changed by: -0.009899999999959164
    High changed by: -0.009899999999959164
    Open changed by: -0.009899999999959164
    Close changed by: -0.009899999999959164
    Volume changed by: -25.0, from 125.0, to 100.0
    Ask events processed: 3
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


.. code-block:: text

    Connection status: Not connected
    
