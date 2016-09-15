python-smartcols
================

Python bindings for util-linux libsmartcols-library.

Building
--------

```
$ python setup.py build
```

Running tests
-------------

```
$ git submodule init
$ git submodule update
$ python setup.py test
```

Running tests with coverage
---------------------------

```
$ py.test --cov --cov-report=html
```

Building documentation
----------------------

```
$ python setup.py build_sphinx
```

HTML documentation will be available in `doc/_build/html/`
