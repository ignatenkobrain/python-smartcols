from __future__ import print_function, unicode_literals
import locale

import smartcols

if __name__ == "__main__":
    locale.setlocale(locale.LC_ALL, '')

    tb = smartcols.Table()
    tb.colors = True

    cl_name = tb.new_column("NAME")
    cl_name.tree = True
    cl_desc = tb.new_column("DESC")
    cl_foo = tb.new_column("FOO")
    cl_foo.wrap = True
    cl_like = tb.new_column("LIKE")
    cl_like.right = True
    cl_text = tb.new_column("TEXT")
    cl_text.wrap = True

    def add_line(prefix, parent=None):
        def gen_text(sub_prefix, size):
            tmp = "{!s}-{!s}-".format(prefix, sub_prefix)
            return "{}{}x".format(tmp, prefix[0] * (size - 1 - len(tmp)))
        ln = tb.new_line(parent)
        ln[cl_name] = gen_text("N", 15)
        ln[cl_desc] = gen_text("D", 10)
        ln[cl_foo] = gen_text("U", 55)
        ln[cl_like] = "1"
        ln[cl_text] = gen_text("T", 50)
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
