.. _devs:

For developers
==============

To clone the repository:

.. code-block:: bash

    git clone ssh://git@stash.in.devexperts.com:7999/~asalynskiy/dxfeed-python-api.git
    cd dxfeed-python-api/
    git submodule init
    git submodule update

To build the package you will have to install poetry(https://github.com/sdispater/poetry)

Additional requirements: poetry(https://github.com/sdispater/poetry)

.. code-block:: bash

    poetry build

The built package is in `dist/` folder.

To create html documentation run

.. code-block:: bash

    ./gen_docs.sh