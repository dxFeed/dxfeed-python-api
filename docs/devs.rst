.. _devs:

For developers
==============

Get the code
------------

After cloning repository remember to initialize submodule with c-api library

.. code-block:: bash

    git clone <repo>
    cd dxfeed-python-api/
    git submodule init
    git submodule update

Additional requirements
-----------------------

All the additional requirements are located in `pyproject.toml` file in
`[tool.poetry.dev-dependencies]` section. Here is a small description for key
additional packages:

* poetry - for building the project
* taskipy - to set small alias to long bash commands
* sphinx - for automatic documentation generation
* pytest - for testing purposes

.. note::
    All further commands should be execute from the root directory of the project

Build package
-------------

.. code-block:: bash

    task build

The upper command get the same arguments as `poetry build` command (e.g. -f sdist).
The built package is in `dist/` folder.

Testing tool
------------

.. code-block:: bash

    task test

The upper command starts pytest. All the arguments for `pytest` command are available (e.g. -v)

Documentation
-------------

.. code-block:: bash

    task html_docs

The upper command starts sphinx documentation building. The files can be found in
`docs/_build/html` folder. Automatically zip archive is created in `docs/_build/` folder.
