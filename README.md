# dxfeed package

[![PyPI](https://img.shields.io/pypi/v/dxfeed)](https://pypi.org/project/dxfeed/)
[![Documentation Status](https://readthedocs.org/projects/dxfeed/badge/?version=latest)](https://dxfeed.readthedocs.io/en/latest/?badge=latest)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/dxfeed)](https://pypi.org/project/dxfeed/)
![Platform](https://img.shields.io/badge/platform-win--x64%20%7C%20linux--x64%20%7C%20osx--x64-lightgrey)
[![PyPI - Wheel](https://img.shields.io/pypi/wheel/dxfeed)](https://pypi.org/project/dxfeed/)
[![PyPI - License](https://img.shields.io/pypi/l/dxfeed)](https://github.com/dxFeed/dxfeed-python-api/blob/master/LICENSE)
[![Test workflow](https://github.com/dxFeed/dxfeed-python-api/workflows/Test%20package/badge.svg)](https://github.com/dxFeed/dxfeed-python-api/actions)

:warning:
This library will be superseded by the Graal Python API based on [GraalVM](https://www.graalvm.org/latest/reference-manual/native-image/) 
(similar to [Graal .NET API](https://github.com/dxFeed/dxfeed-graal-net-api#readme)).\
The current implementation has a number of architectural limitations that will be fixed in the new one.\
Please note that feature development has been completely halted in this version.

</br>

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

**Requirements:** python >= 3.6

On Linux, WSL and macOS, we recommend installing python via [pyenv](https://github.com/pyenv/pyenv):

An example of how to install python on Ubuntu 20.04:

```bash
# Update the package index files on the system
sudo apt-get update

# Install pyenv dependencies
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Run automatic pyenv installer
curl https://pyenv.run | bash

# Configure bash shell
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Restart bash shell
bash

# Install python 3.9.16
pyenv install 3.9.16

# Set python 3.9.16 as global
pyenv global 3.9.16

# Check python version
python --version
#>>> Python 3.9.16

```

Install package via PyPI:

```python
python -m pip install dxfeed
``` 

## Installation from sources

To install dxfeed from source you need Poetry. It provides a custom installer.
This is the recommended way of installing poetry according to [documentation](https://python-poetry.org/docs/)

For macOS / Linux / Windows (WSL):

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

For Windows (Powershell):
```powershell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
```

In the project root directory (same one where you found this file after
cloning the git repo), execute:

```bash
poetry install 
```

By default package is installed in 
[development mode](https://pip.pypa.io/en/latest/reference/pip_install.html#editable-installs). To rebuild 
C extensions, after editing .pyx files:

```bash
poetry run task build_inplace  # build c extensions
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
