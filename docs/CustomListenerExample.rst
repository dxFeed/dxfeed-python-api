Custom listener
===============

This is the tutorial, how to write custom listener

Pipeline
--------

1. Create cython package
2. Build
3. Install
4. Import
5. Use!

Create cython package
---------------------

**First of all let’s create special directory for custom listener
package**

.. code:: bash

    %%bash
    rm custom_listener -r
    rm ../custom_listener -r
    mkdir custom_listener

.. code:: ipython3

    %cd custom_listener

Create .pyx file with the whole logic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here we will write listener for Trade event type that will store only
price and ticker

%%writefile cust.pyx
from dxpyfeed.wrapper.listeners.listener cimport *
from dxpyfeed.wrapper.utils.helpers cimport *

cdef void trade_custom_listener(int event_type, dxf_const_string_t symbol_name,
                                const dxf_event_data_t* data, int data_count, void* user_data) nogil:

    cdef dxf_trade_t* trades = <dxf_trade_t*>data
    with gil:
        py_data = <dict>user_data

        for i in range(data_count):
            py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                    trades[i].price
                                   ]
                                   )

tc = FuncWrapper.make_from_ptr(trade_custom_listener)

.. code:: ipython3

    %%writefile cust.pyx
    from dxpyfeed.wrapper.listeners.listener cimport *
    from dxpyfeed.wrapper.utils.helpers cimport *
    
    cdef void trade_custom_listener(int event_type, dxf_const_string_t symbol_name,
                                    const dxf_event_data_t* data, int data_count, void* user_data) nogil:
    
        cdef dxf_quote_t* quotes = <dxf_quote_t*>data
        with gil:
            py_data = <dict>user_data
    
            for i in range(data_count):
                py_data['data'].append([unicode_from_dxf_const_string_t(symbol_name),
                                        quotes[i].bid_price * 10
                                       ]
                                       )
    
    tc = FuncWrapper.make_from_ptr(trade_custom_listener)

.. code:: ipython3

    !ls

-  Line 2 imports all type definitions and function wrapper from
   installed dxpyfeed package
-  Line 3 imports helper functions like
   ``unicode_from_dxf_const_string_t`` in this example
-  Lines 5-15 stand for listener logic
-  nogil and with gil in lines 6 and 9 are important to prevent data
   corruption. More details
   `stackoverflow <https://stackoverflow.com/questions/57805481/>`__
-  Line 8 converts the data to trades data structure. **It is important
   to know what data structure has each event. This information can be
   found in EventData.pxd in the dxpyfeed package folder**
-  Line 10 stands for casting user data which is provided by
   subscription
-  Lines 12-16 we just append price and symbol to subscription dict
-  Line 18, here we wrap function to have access to it from python

Create setup.py to build the binary file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: ipython3

    %%writefile setup.py
    from Cython.Build import cythonize
    from setuptools import setup, Extension
    import dxpyfeed
    
    ext = Extension(name="cust",
                    sources=["cust.pyx"],
                    include_dirs=dxpyfeed.get_include()
                    )
    
    setup(
        ext_modules=cythonize([ext], language_level=3)
    )

-  Line 4 imports dxpyfeed to get access to ``get_include`` function,
   which provide paths to .pxd and .h header files

Build the binary file
^^^^^^^^^^^^^^^^^^^^^

.. code:: ipython3

    !python setup.py build_ext --inplace

.. code:: ipython3

    !ls

Import
------

We will skip installation part

.. code:: ipython3

    import cust
    import dxpyfeed as dxp

.. code:: ipython3

    con = dxp.dxf_create_connection()
    sub = dxp.dxf_create_subscription(con, 'Quote')
    dxp.dxf_add_symbols(sub, ['AAPL', 'MSFT', 'EUR/USD'])

Attach custom listener

.. code:: ipython3

    dxp.dxf_attach_custom_listener(sub, cust.tc, ['Symbol', 'Price'])

.. code:: ipython3

    sub.data

.. code:: ipython3

    dxp.dxf_detach_listener(sub)
