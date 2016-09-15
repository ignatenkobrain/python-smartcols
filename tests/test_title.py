import os

from . import D_EXPECTED
from . import title

def test_basic(capfd):
    title.main(["--width", "80"])
    out, err = capfd.readouterr()
    assert not err
    with open(os.path.join(D_EXPECTED, "title"), "r") as expected:
        assert out == expected.read()
