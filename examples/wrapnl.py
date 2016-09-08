from __future__ import division, print_function, unicode_literals
import argparse
import locale
import random

import smartcols

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, "")

    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--random", action="store_true")
    parser.add_argument("-m", "--maxout", action="store_true")
    args = parser.parse_args()

    tb = smartcols.Table()
    tb.colors = True
    tb.maxout = args.maxout

    cl_name = tb.new_column("NAME")
    cl_name.tree = True
    cl_data1 = tb.new_column("DATA1")
    cl_data1.wrapnl = True
    cl_like = tb.new_column("LIKE")
    cl_like.right = True
    cl_data2 = tb.new_column("DATA2")
    cl_data2.wrapnl = True

    def add_line(prefix, parent=None):
        def gen_text(sub_prefix, size, newline=False):
            tmp = "{!s}-{!s}-".format(prefix, sub_prefix)
            next_nl = -1
            for i in range(size - 1 - len(tmp)):
                char = "\n" if next_nl == 0 else prefix[0]
                tmp = "{!s}{!s}".format(tmp, char)
                if newline:
                    next_nl -= 1
                    if next_nl < 0:
                        if args.random:
                            next_nl = random.randint(1, size // 2)
                        else:
                            next_nl = size // 3
            return "{!s}x".format(tmp)
        ln = tb.new_line(parent)
        ln[cl_name] = gen_text("N", 15)
        ln[cl_data1] = gen_text("D", 40, True)
        ln[cl_like] = "1"
        ln[cl_data2] = gen_text("E", 40, True)
        return ln

    ln = add_line("A")
    add_line("aa", ln)
    add_line("ab", ln)

    ln = add_line("B")
    xln = add_line("ba", ln)
    add_line("baa", xln)
    add_line("bab", xln)
    add_line("bb", ln)

    print(tb)
