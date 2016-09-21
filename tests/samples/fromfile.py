from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import argparse
import locale
import os
import sys

import smartcols

class PositiveArg(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if values < 0:
            arg = "/".join(self.option_strings)
            type = getattr(self.type, "__name__", repr(self.type))
            parser.error("argument {0}: minimum {1!s} value: {2!r} < 0".format(
                arg, type, values))

        setattr(namespace, self.dest, values)

def main(args=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--maxout", action="store_true",
                        help="fill all terminal width")
    parser.add_argument("-c", "--column", metavar="FILE", action="append",
                        default=[], help="column definition")
    parser.add_argument("-n", "--nlines", metavar="NUM", required=True,
                        type=int, action=PositiveArg,
                        help="number of lines")
    outfmt = parser.add_mutually_exclusive_group()
    outfmt.add_argument("-J", "--json", action="store_true",
                        help="JSON output format")
    outfmt.add_argument("-r", "--raw", action="store_true",
                        help="RAW output format")
    outfmt.add_argument("-E", "--export", action="store_true",
                        help="use key=\"value\" output format")
    parser.add_argument("-C", "--colsep", metavar="STR",
                        help="set columns separator")
    parser.add_argument("-w", "--width", type=int,
                        help="hardcode terminal width")
    parser.add_argument("-p", "--tree-parent-column", metavar="N", type=int,
                        help="parent column")
    parser.add_argument("-i", "--tree-id-column", metavar="N", type=int,
                        help="id column")
    parser.add_argument("column_data_files", metavar="column-data-file",
                        nargs="+")
    args = parser.parse_args(args)

    tb = smartcols.Table()
    tb.colors = os.isatty(sys.stdout.fileno())
    if args.maxout:
        tb.maxout = args.maxout
    if args.width:
        tb.termforce = "always"
        tb.termwidth = args.width
    if args.json:
        raise NotImplementedError()
    if args.raw:
        raise NotImplementedError()
    if args.export:
        raise NotImplementedError()
    if args.colsep:
        tb.column_separator = args.colsep

    for col in args.column:
        cl = None
        with open(col, "r") as fobj:
            for nlines, line in enumerate(fobj):
                if line.endswith("\n"):
                    line = line[:-1]
                if nlines == 0:
                    # NAME
                    cl = smartcols.Column(line)
                elif nlines == 1:
                    # WIDTH-HINT
                    cl.whint = float(line)
                elif nlines == 2:
                    # FLAGS
                    if line == "none":
                        continue
                    flags = line.split(",")
                    for flag in flags:
                        setattr(cl, flag, True)
                elif nlines == 3:
                    # COLOR
                    cl.color = line
                else:
                    break
        tb.add_column(cl)

    for n in range(args.nlines):
        tb.new_line()

    lines = tb.lines()
    columns = tb.columns()
    for i, cl_data_file in enumerate(args.column_data_files):
        with open(cl_data_file, "r") as fobj:
            for n, data in enumerate(fobj):
                if data.endswith("\n"):
                    data = data[:-1]
                data = data.replace("\\n", "\n")
                data = data.rstrip()
                ln = lines[n]
                cl = columns[i]
                ln[cl] = data

    if tb.tree and args.tree_parent_column >= 0 and args.tree_id_column >= 0:
        columns = tb.columns()
        parent_col = columns[args.tree_parent_column]
        col = columns[args.tree_id_column]
        for ln in tb.lines():
            data = ln[parent_col].data
            if data is not None:
                try:
                    parent = next(l for l in tb.lines() if l[col].data == data)
                except StopIteration:
                    pass
                else:
                    ln.parent = parent

    print(tb)

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, "")
    smartcols.init_debug()
    main()
