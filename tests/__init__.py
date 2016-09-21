import os

import smartcols

smartcols.init_debug()

TESTS_DIR = os.path.join(os.path.dirname(__file__), "..",
                         "util-linux", "tests")

def data(fname):
    return os.path.join(TESTS_DIR, "ts", "libsmartcols", "files", fname)

def expected(fname):
    return os.path.join(TESTS_DIR, "expected", "libsmartcols", fname)
