python-smartcols
================

Python bindings for util-linux libsmartcols-library

Building
--------

```
$ python setup.py build_ext --inplace
```

Running tests
-------------

```
$ python setup.py test
```

Running tests with coverage
---------------------------

```
$ PYTHONPATH=. coverage run tests.py
$ coverage html
```

Building documentation
----------------------

```
$ PYTHONPATH=. python setup.py build_sphinx
```

HTML documentation will be available in `doc/_build/html/`
