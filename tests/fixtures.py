import locale

import pytest

@pytest.yield_fixture
def posix_locale():
    locale.setlocale(locale.LC_ALL, "POSIX")
    yield
    locale.resetlocale(locale.LC_ALL)
