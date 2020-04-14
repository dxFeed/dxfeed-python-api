# dxfeed package

This library provides Python API to dxfeed via C API. The code is written in Python and Cython.

## Installation

**Requirements:** python >3.6, cython, pandas

```python
pip3 install cython pandas
```

Install package itself

```python
pip3 install dxpyfeed-x.x.x.tar.gz
``` 

## Basic usage

All the functions in C API have similar ones in Python with the same name. Not all arguments are
supported by now, this work is in progress.

**Import dxfeed library**:

```python
import dxfeed as dx
``` 

**Create connection**:

```python
con = dx.dxf_create_connection(address='demo.dxfeed.com:7300')
```

**Create one or several subscriptions of certain event types**:
```python
sub1 = dx.dxf_create_subscription(con, 'Trade')
sub2 = dx.dxf_create_subscription(con, 'Quote')
```
'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' event types are supported.

**Attach listeners**:
```python
dx.dxf_attach_listener(sub1)
dx.dxf_attach_listener(sub2)
```

**Add tickers you want to get data for**:
```python
dx.dxf_add_symbols(sub1, ['AAPL', 'MSFT'])
dx.dxf_add_symbols(sub2, ['AAPL', 'C'])
```

`dxfeed` has default listeners for each event type, but you are able to write 
your custom one. You can find how to do it at `example/Custom listener example.ipynb`.

**Look at the data**:
```python
sub1.get_data()
sub2.get_data()
```
The data is stored in Subscription class. You can also turn dict to pandas DataFrame simply calling
`sub1.to_dataframe()`.

**Detach the listener, if you want to stop recieving data**:
```python
dx.dxf_detach_listener(sub1)
dx.dxf_detach_listener(sub2)
```

**Finally, close your connection**:
```python
dx.dxf_close_connection(con)
```
