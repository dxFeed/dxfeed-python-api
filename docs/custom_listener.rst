.. _custom_listener:

Custom listener
===============

Since dxfeed v0.4.0, there is another way to implement the logic for
processing incoming events (see Custom Event Handler example).

This tutorial is for cases that are not covered by previous tutorials.

Pipeline
~~~~~~~~

1. Create cython package
2. Build
3. Install
4. Import
5. Use!

Create cython package
~~~~~~~~~~~~~~~~~~~~~

**First of all let’s create special directory for custom listener
package**

.. code:: bash

    %%bash
    rm custom_listener -rf
    mkdir custom_listener

.. code:: python3

    %cd custom_listener


.. code:: text

    C:\python-api\examples\Low_level_API\custom_listener
    

Create .pyx file with the whole logic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here we will write listener for Trade event type that will store only
price and ticker

.. code:: python3

    %%writefile cust.pyx
    from dxfeed.core.listeners.listener cimport *
    from dxfeed.core.utils.helpers cimport unicode_from_dxf_const_string_t
    from dxfeed.core.utils.handler cimport EventHandler
    
    cdef void trade_custom_listener(int event_type,
                                     dxf_const_string_t symbol_name,
                                     const dxf_event_data_t*data,
                                     int data_count, void*user_data) nogil:
        cdef dxf_trade_t*trades = <dxf_trade_t*> data
        with gil:
            py_data = <EventHandler> user_data
    
            for i in range(data_count):
                py_data.__update([unicode_from_dxf_const_string_t(symbol_name),
                                  trades[i].price])
    
    tc = FuncWrapper.make_from_ptr(trade_custom_listener)


.. code:: text

    Writing cust.pyx
    

.. code:: ipython3

    !ls


.. code:: text

    cust.pyx
    

-  Line 2 imports all type definitions and function wrapper from
   installed dxfeed package
-  Line 3 imports helper function ``unicode_from_dxf_const_string_t``
-  Line 4 import EventHandler class
-  Lines 6-16 stand for listener logic
-  nogil and with gil in lines 9 and 11 are important to prevent data
   corruption. More details
   `stackoverflow <https://stackoverflow.com/questions/57805481/>`__
-  Line 10 converts the data to trades data structure. **It is important
   to know what data structure has each event. This information can be
   found in EventData.pxd in the dxfeed package folder**
-  Line 12 stands for casting user data which is provided by
   subscription
-  Lines 14-16 we just append price and symbol to subscription dict
-  Line 18, here we wrap function to have access to it from python

Create setup.py to build the binary file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: python3

    %%writefile setup.py
    from Cython.Build import cythonize
    from setuptools import setup, Extension
    from dxfeed.core.utils.helpers import get_include
    
    ext = Extension(name="cust",
                    sources=["cust.pyx"],
                    include_dirs=get_include()
                    )
    
    setup(
        ext_modules=cythonize([ext], language_level=3)
    )


.. code:: text

    Writing setup.py
    

-  Line 4 imports dxfeed to get access to ``get_include`` function,
   which provide paths to .pxd and .h header files

Build the binary file
^^^^^^^^^^^^^^^^^^^^^

.. code:: ipython3

    !python setup.py build_ext --inplace


.. code:: text

    Compiling cust.pyx because it changed.
    [1/1] Cythonizing cust.pyx
    running build_ext
    building 'cust' extension
    creating build
    ...
    Generating code
    Finished generating code
    copying build\lib.win-amd64-3.7\cust.cp37-win_amd64.pyd -> 
    

.. code:: ipython3

    !ls


.. code:: text

    build
    cust.c
    cust.cp37-win_amd64.pyd
    cust.pyx
    setup.py
    

Import necessary modules
~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python3

    import cust
    from dxfeed.core import DXFeedPy as dxc
    from dxfeed.core.utils.handler import EventHandler

Create Custom Event Handler
~~~~~~~~~~~~~~~~~~~~~~~~~~~

See Custom Event Handler tutorial for more details

.. code:: python3

    class CustomHandler(EventHandler):
        def __init__(self):
            self.data = list()
            
        def update(self, event):
            self.data.append(event)
            
        def get_data(self):
            return self.data

.. code:: python3

    con = dxc.dxf_create_connection()
    sub = dxc.dxf_create_subscription(con, 'Trade')

Attach custom handler

.. code:: python3

    handler = CustomHandler()
    sub.set_event_handler(handler)

Attach custom listener

.. code:: python3

    dxc.dxf_attach_custom_listener(sub, cust.tc, ['Symbol', 'Price'])
    dxc.dxf_add_symbols(sub, ['AAPL', 'MSFT'])

Get data

.. code:: python3

    handler.get_data()[-5:]




.. code:: text

    [['AAPL', 335.23],
     ['AAPL', 335.23],
     ['AAPL', 335.23],
     ['MSFT', 186.71],
     ['MSFT', 186.71]]



.. code:: python3

    dxc.dxf_detach_listener(sub)
