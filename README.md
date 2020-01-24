# dxpyfeed library

This library provides Python API to dxfeed via C API. The code is written in Python and Cython.

## Installation

Requirements: python >3.6, cython, pandas

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

**Import dxpyfeed library**:

```python
import dxpyfeed as dxp
``` 

**Create connection**:

```python
con = dxp.dxf_create_connection(address='demo.dxfeed.com:7300')
```

**Create one or several subscriptions of certain event types**:
```python
sub1 = dxp.dxf_create_subscription(con, 'Trade')
sub2 = dxp.dxf_create_subscription(con, 'Quote')
```
'Trade', 'Quote', 'Summary', 'Profile', 'Order', 'TimeAndSale', 'Candle', 'TradeETH', 'SpreadOrder',
'Greeks', 'TheoPrice', 'Underlying', 'Series', 'Configuration' event types are supported.

**Add tickers you want to get data for**:
```python
dxp.dxf_add_symbols(sub1, ['AAPL', 'MSFT'])
dxp.dxf_add_symbols(sub2, ['AAPL', 'C'])
```

**Attach listeners**:
```python
dxp.dxf_attach_listener(sub1)
dxp.dxf_attach_listener(sub2)
```

`dxpyfeed` has default listeners for each event type, but you are able to write 
your custom one. You can find how to do it at `example/Custom listener example.ipynb`.

**Look at the data**:
```python
sub1.data
sub2.data
```
The data is stored in Subscription class. You can also turn dict to pandas DataFrame simply calling
`sub1.to_dataframe()`.

**Detach the listener, if you want to stop recieving data**:
```python
dxp.dxf_detach_listener(sub1)
dxp.dxf_detach_listener(sub2)
```

**Finally, close your connection**:
```python
dxp.dxf_close_connection(con)
```

# For developers

## Cloning the repo:

```bash
git clone ssh://git@stash.in.devexperts.com:7999/~asalynskiy/dxfeed-python-api.git
cd dxfeed-python-api/
git submodule init
git submodule update
```

## Building the package

Additional requirements: poetry(https://github.com/sdispater/poetry)

```bash
poetry build
```

The built package is in `dist/` folder. 

## Generating html documentation with Sphinx

Additional requirements: sphinx, sphinx_rtd_theme

```bash
gen_docs.sh
```

Documentation can be found in `./docs/_build` folder.