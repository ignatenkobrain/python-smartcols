python-smartcols
================

Python bindings for util-linux libsmartcols-library

Building
--------

```
$ python setup.py build_ext --inplace
```

Running tests with coverage
---------------------------

```
$ PYTHONPATH=. coverage tests/__init__.py
$ coverage html
```

Building documentation
----------------------

```
$ PYTHONPATH=. python setup.py build_sphinx
```

HTML documentation will be available in `doc/_build/html/`
