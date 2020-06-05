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

This package already contains basic C-API functions related to creating connections, subscriptions etc.
Moreover default listeners (functions responsible for event processing) are ready to use. The user is also able to
write his own custom listener in Cython

## Installation

**Requirements:** python >3.6, pandas

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
* Attach listener
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
trade_sub = endpoint.create_subscription('Trade', data_len=-1)
```

**Attach default listener** - function that process incoming events


```python
trade_sub = trade_sub.attach_listener()
```

**Add tikers** you want to recieve events for


```python
trade_sub = trade_sub.add_symbols(['C', 'TSLA'])
```

For timed subscription you may provide either datetime object or string. String might be incomlete, in this case you will get warning with how your provided date parsed automatically


```python
tns_sub = endpoint.create_subscription('TimeAndSale', date_time=datetime.now()) \
                  .attach_listener() \
                  .add_symbols(['AMZN'])
```


```python
candle_sub = endpoint.create_subscription('Candle', date_time='2020-04-16 13:05')
candle_sub = candle_sub.attach_listener()
candle_sub = candle_sub.add_symbols(['AAPL', 'MSFT'])
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
Data is stored as deque. Its length is configured with data_len parameter and by default is 100000. When you call method below you extracts all data recieved to the moment and clears the buffer in class.


```python
candle_sub.get_data()
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


```python
trade_df = trade_sub.get_dataframe()
```


```python
tns_df = tns_sub.get_dataframe()
```


```python
candle_df = candle_sub.get_dataframe()
```
