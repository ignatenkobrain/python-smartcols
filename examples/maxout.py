from __future__ import print_function, unicode_literals
import locale

import smartcols

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, "")

    tb = smartcols.Table()
    tb.maxout = True

    cl_left = tb.new_column("LEFT")
    cl_foo = tb.new_column("FOO")
    cl_right = tb.new_column("RIGHT")
    cl_right.right = True

    for _ in reversed(range(3)):
        ln = tb.new_line()
        ln[cl_left] = "A"
        ln[cl_foo] = "B"
        ln[cl_right] = "C"

    print(tb)
