from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import argparse
import locale
import os
import sys

import smartcols

def main(args=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--maxout", action="store_true")
    parser.add_argument("-w", "--width", type=int)
    args = parser.parse_args(args)

    tb = smartcols.Table()
    tb.colors = os.isatty(sys.stdout.fileno())
    if args.maxout:
        tb.maxout = args.maxout
    if args.width:
        tb.termforce = "always"
        tb.termwidth = args.width

    cl_name = tb.new_column("NAME")
    cl_data = tb.new_column("DATA")

    def add_line(name, data):
        ln = tb.new_line()
        ln[cl_name] = name
        ln[cl_data] = data
        return ln

    add_line("foo", "bla bla bla")
    add_line("bar", "alb alb alb")
    title = tb.title

    # right
    title.data = "This is right title"
    title.color = "red"
    title.position = "right"
    print(tb)

    # center
    sm = smartcols.Symbols()
    sm.title_padding = "="
    tb.symbols = sm
    title.data = "This is center title (with padding)"
    title.color = "green"
    title.position = "center"
    print(tb)

    # left
    sm.title_padding = "-"
    title.data = "This is left title (with padding)"
    title.color = "blue"
    title.position = "left"
    print(tb)

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, "")
    smartcols.init_debug()
    main()
