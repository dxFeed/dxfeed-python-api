.. _custom_listener:

Custom listener
===============

This is the tutorial, how to write custom listener

Pipeline
--------

1. :ref:`cython-pack`
2. :ref:`Build <build>`
3. :ref:`Import <import>`

.. _cython-pack:

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

**Next create .pyx file with the whole logic**

Here we will write listener for Trade event type that will store only
price and ticker

.. code:: cython

    %%writefile cust.pyx
    from dxfeed.core.listeners.listener cimport *
    from dxfeed.core.utils.helpers cimport *

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

    !ls

-  Line 2 imports all type definitions and function wrapper from
   installed dxfeed package
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

**Create setup.py to build the binary file**

.. code:: cython

    %%writefile setup.py
    from Cython.Build import cythonize
    from setuptools import setup, Extension
    import dxfeed

    ext = Extension(name="cust",
                    sources=["cust.pyx"],
                    include_dirs=dxfeed.get_include()
                    )

    setup(
        ext_modules=cythonize([ext], language_level=3)
    )

-  Line 4 imports dxfeed to get access to ``get_include`` function,
   which provide paths to .pxd and .h header files

.. _build:

Build the binary file
---------------------

.. code:: ipython3

    !python setup.py build_ext --inplace

.. code:: ipython3

    !ls

.. _import:

Import
------

You can either import extension built on previous step or install your extension as a python package.

.. code:: ipython3

    import cust
    import dxfeed as dx

.. code:: ipython3

    con = dx.dxf_create_connection()
    sub = dx.dxf_create_subscription(con, 'Trade')

Attach custom listener, specifying the columns

.. code:: ipython3

    dx.dxf_attach_custom_listener(sub, cust.tc, ['Symbol', 'Price'])
    dx.dxf_add_symbols(sub, ['AAPL', 'MSFT'])

After some time you will get the data.

.. code:: ipython3

    sub.get_data()

.. code:: ipython3

    dx.dxf_detach_listener(sub)