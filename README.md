# dxfeed package

[![PyPI](https://img.shields.io/pypi/v/dxfeed)](https://pypi.org/project/dxfeed/)
[![Documentation Status](https://readthedocs.org/projects/dxfeed/badge/?version=latest)](https://dxfeed.readthedocs.io/en/latest/?badge=latest)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/dxfeed)](https://pypi.org/project/dxfeed/)
[![PyPI - Wheel](https://img.shields.io/pypi/wheel/dxfeed)](https://pypi.org/project/dxfeed/)
[![PyPI - License](https://img.shields.io/pypi/l/dxfeed)](https://github.com/dxFeed/dxfeed-python-api/blob/master/LICENSE)
[![Test workflow](https://github.com/dxFeed/dxfeed-python-api/workflows/Test%20package/badge.svg)](https://github.com/dxFeed/dxfeed-python-api/actions)



This package provides access to [dxFeed](https://www.dxfeed.com/) streaming data.
The library is build as a thin wrapper over [dxFeed C-API library](https://github.com/dxFeed/dxfeed-c-api).
We use [Cython](https://cython.org/) in this project as it combines flexibility, reliability and
usability in writing C extensions.

The design of the dxfeed package allows users to write any logic related to events in python as well as 
extending lower level Cython functionality. Moreover, one may start working with the API using the default 
values like function arguments or a default event handler.

Documentation: [dxfeed.readthedocs.io](https://dxfeed.readthedocs.io/en/latest/)

Package distribution: [pypi.org/project/dxfeed](https://pypi.org/project/dxfeed/)

## Installation

**Requirements:** python >= 3.6, pandas

```python
pip3 install pandas
```

Install package via PyPI

```python
pip3 install dxfeed
``` 

## Basic usage

Following steps should be performed:

* Import
* Create Endpoint
* Create Subscription
* Attach event handler
* Add tickers
* Finally close subscription and connection 

### Import package

```python
import dxfeed as dx
from datetime import datetime  # for timed subscription
```

### Configure and create connection with Endpoint class
Create instance of Endpoint class which will connect provided address. 


```python
endpoint = dx.Endpoint('demo.dxfeed.com:7300')
```

Endpoint instance contains information about the connection, e.g. connection address or status


```python
print(f'Connected address: {endpoint.address}')
print(f'Connection status: {endpoint.connection_status}')
```

```text
Connected address: demo.dxfeed.com:7300
Connection status: Connected and authorized
```

### Configure and create subscription
You should specify event type. For timed subscription (conflated stream) you should also provide time to start subscription from.


```python
trade_sub = endpoint.create_subscription('Trade')
```

**Attach default or custom event handler** - class that process incoming events. For details about custom
event handler look into `CustomHandlerExample.ipynb` jupyter notebook in `exapmles` folder of this repository.


```python
trade_handler = dx.DefaultHandler()
trade_sub = trade_sub.set_event_handler(trade_handler)
```

**Add tikers** you want to receive events for


```python
trade_sub = trade_sub.add_symbols(['C', 'AAPL'])
```

For timed subscription you may provide either datetime object or string. String might be incomplete, in 
this case you will get warning with how your provided date parsed automatically. 


```python
tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                  .add_symbols(['AMZN'])
```


```python
candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
candle_sub = candle_sub.add_symbols(['AAPL', 'MSFT'])
```

We didn't provide subscriptions with event handlers. In such a case DefaultHandler is initiated automatically.
One may get it with `get_event_handler` method.

```python
tns_handler = tns_sub.get_event_handler()
candle_handler = candle_sub.get_event_handler()
```

#### Subscription instance properties


```python
print(f'Subscription event type: {tns_sub.event_type}')
print(f'Subscription symbols: {candle_sub.symbols}')
```

```text
Subscription event type: TimeAndSale
Subscription symbols: ['AAPL', 'MSFT']
```

### Access data
In DefaultHandler the data is stored as deque. Its length may be configured, by default 100000 events.

```python
candle_handler.get_list()
```

### Close connection


```python
endpoint.close_connection()
print(f'Connection status: {endpoint.connection_status}')
```

```text
Connection status: Not connected
```

### Transform data to pandas DataFrame

DefaultHandler has `get_dataframe` method, which allows you to get pandas.DataFrame object with events as rows.

```python
trade_df = trade_handler.get_dataframe()
tns_df = tns_handler.get_dataframe()
candle_df = candle_handler.get_dataframe()
```
