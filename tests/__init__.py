import os

import smartcols

smartcols.init_debug()

D_UTIL_LINUX = os.path.join(os.path.dirname(__file__), "..", "util-linux")
D_EXPECTED = os.path.join(D_UTIL_LINUX, "tests", "expected", "libsmartcols")
D_FILES = os.path.join(D_UTIL_LINUX, "tests", "ts", "libsmartcols", "files")
