import pytest

import smartcols

def test_column_header():
    cl = smartcols.Column()
    hdr = cl.header
    assert isinstance(hdr, smartcols.Cell)
    del cl
    with pytest.raises(ReferenceError):
        assert not hdr

def test_table_title():
    tb = smartcols.Table()
    title = tb.title
    assert isinstance(title, smartcols.Title)
    del tb
    with pytest.raises(ReferenceError):
        assert not title
