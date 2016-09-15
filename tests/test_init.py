import pytest

import smartcols

def test_multiple_init_debug(recwarn):
    """
    Ensure that warn is there for multiple init_debug() invocation. We already
    do init_debug() in __init__.py for testing purposes.
    """
    smartcols.init_debug()
    assert len(recwarn) == 1
    w = recwarn.pop(RuntimeWarning)
    assert issubclass(w.category, RuntimeWarning)
    assert str(w.message) == "Calling smartcols.init_debug() multiple times has no effect. First call initializes debugging features."
    assert w.filename
    assert w.lineno
