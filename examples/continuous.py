#!/usr/bin/env python

from __future__ import division, print_function, unicode_literals
import locale
import time

import smartcols

TIME_PERIOD = 3.0

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, '')

    tb = smartcols.Table()
    tb.maxout = True
    cl_num = tb.new_column("#NUM")
    cl_num.whint = 0.1
    cl_num.right = True
    cl_data = tb.new_column("DATA")
    cl_data.whint = 0.7
    cl_time = tb.new_column("TIME")
    cl_time.whint = 0.2

    last = time.time()
    for i in range(10):
        ln = tb.new_line()
        ln[cl_num] = str(i)
        ln[cl_data] = "data-{:0>2d}-{:0>2d}-{:0>2d}-end".format(i + 1, i + 2, i + 3)

        done = False
        while not done:
            now = time.time()
            diff = now - last
            if (now - last) >= TIME_PERIOD:
                done = True
            else:
                time.sleep(0.1)

            ln[cl_time] = "{:f} [{: >3d}%]".format(diff, int(diff / (TIME_PERIOD / 100)))

            s = tb.str_line(ln)
            if not done:
                print("{}\r".format(s), end='')
            else:
                print(s)

        last = now
