#!/usr/bin/env python

from __future__ import print_function, unicode_literals
import locale

import smartcols

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, '')

    tb = smartcols.Table()
    tb.colors = True

    cl_name = tb.new_column("NAME")
    cl_data = tb.new_column("DATA")

    def add_line(name, data):
        ln = tb.new_line()
        ln[cl_name] = name
        ln[cl_data] = data

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
