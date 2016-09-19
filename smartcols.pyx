# smartcols.pyx
#
# Copyright © 2016 Igor Gnatenko <i.gnatenko.brain@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# cython: c_string_type=unicode, c_string_encoding=utf8, linetrace=True

from libc.stdlib cimport malloc, free
from libc.string cimport strcmp
from libc.stdint cimport uintptr_t
from cython cimport internal
from csmartcols cimport *

from warnings import warn
import weakref

# scols_* returns pointers to struct, we need to have way to return Python
# class instead, so we will store uintptr_t->object here. Always we should
# have our object here, if not there is a bug in our code.
cdef object __refs__ = weakref.WeakValueDictionary()
cdef bint DEBUG_INITIALIZED = False

cpdef void init_debug(int mask=0):
    """
    init_debug(mask=0)
    Initialize debugging features. If `mask` equals to 0, then this function
    reads the `LIBSMARTCOLS_DEBUG` environment variable to get mask.

    Don't call this function multiple times.

    :param int mask: Debug mask (0xffff to enable full debugging)
    """
    global DEBUG_INITIALIZED
    if DEBUG_INITIALIZED:
        warn("Calling smartcols.init_debug() multiple times has no effect. "
             "First call initializes debugging features.", RuntimeWarning)
    else:
        scols_init_debug(mask)
        DEBUG_INITIALIZED = True

cdef struct CmpPayload:
    void *data
    void *func

cpdef int cmpfunc_strcmp(basestring s1, basestring s2, object data=None):
    """
    cmpfunc_strcmp(s1, s2, data=None)
    Shorthand wrapper around strcmp(). `data` is ignored.

    :param str s1: First string
    :param str s2: Second string
    :param object data: (unused) Additional data
    """
    # Must be same as scols_cmpstr_cells().
    if not s1 and not s2:
        return 0
    if not s1:
        return -1
    if not s2:
        return 1
    return strcmp(s1.encode("UTF-8"), s2.encode("UTF-8"))

cdef int cmpfunc_wrapper(libscols_cell *a, libscols_cell *b, void *data):
    if a == b:
        return 0

    cdef const char *adata = scols_cell_get_data(a)
    cdef const char *bdata = scols_cell_get_data(b)
    cdef CmpPayload *payload = <CmpPayload *>data

    return (<object>payload.func)(adata, bdata, <object>payload.data)

@internal
cdef class Iterator:
    cdef libscols_iter *_itr

    def __cinit__(self):
        self._itr = scols_new_iter(SCOLS_ITER_FORWARD)
        if self._itr is NULL:
            raise MemoryError()
    def __dealloc__(self):
        if self._itr is not NULL:
            scols_free_iter(self._itr)

cdef class Cell:
    """
    Cell.

    There is no way to create cell, only way to get this object is from
    :class:`smartcols.Line`.
    """

    cdef object __weakref__
    cdef libscols_cell *_c_cell

    @staticmethod
    cdef Cell new(libscols_cell *cell):
        ce = Cell()
        ce._c_cell = cell
        __refs__[<uintptr_t>ce._c_cell] = ce
        return ce

    property data:
        """
        Text in cell.
        """
        def __get__(self):
            cdef const char *d = scols_cell_get_data(self._c_cell)
            return d if d is not NULL else None
        def __set__(self, basestring data):
            if data is not None:
                scols_cell_set_data(self._c_cell, data.encode("UTF-8"))
            else:
                scols_cell_set_data(self._c_cell, NULL)

    property color:
        """
        Color for text in cell.
        """
        def __get__(self):
            cdef const char *c = scols_cell_get_color(self._c_cell)
            return c if c is not NULL else None
        def __set__(self, basestring color):
            if color is not None:
                scols_cell_set_color(self._c_cell, color.encode("UTF-8"))
            else:
                scols_cell_set_color(self._c_cell, NULL)

cdef dict TitlePosition = {
    "left": SCOLS_CELL_FL_LEFT,
    "center": SCOLS_CELL_FL_CENTER,
    "right": SCOLS_CELL_FL_RIGHT}

cdef class Title(Cell):
    """
    Title.
    """

    @staticmethod
    cdef Title new(libscols_cell *cell):
        ce = Title()
        ce._c_cell = cell
        __refs__[<uintptr_t>ce._c_cell] = ce
        return ce

    property position:
        """
        Position. One of `left`, `center` or `right`.
        """
        def __get__(self):
            cdef int pos = scols_cell_get_flags(self._c_cell)
            return next(k for k, v in TitlePosition.items() if v == pos)
        def __set__(self, basestring position not None):
            scols_cell_set_flags(self._c_cell, TitlePosition[position])

cdef class Column:
    """
    __init__(self, name=None)
    Column.

    :param name: Column name
    :type name: str
    """

    cdef object __weakref__
    cdef libscols_column *_c_column
    cdef Cell _header
    cdef CmpPayload *_cmp_payload
    cdef object _cmpdata

    def __cinit__(self, basestring name=None):
        self._c_column = scols_new_column()
        if self._c_column is NULL:
            raise MemoryError()
        __refs__[<uintptr_t>self._c_column] = self
        self._header = Cell.new(scols_column_get_header(self._c_column))
        if name is not None:
            self.name = name
    def __dealloc__(self):
        scols_unref_column(self._c_column)
        free(self._cmp_payload)

    property header:
        """
        The header of column. Used in table's header.

        :getter: Returns header
        :type: weakproxy(smartcols.Cell)
        """
        def __get__(self):
            return weakref.proxy(self._header)

    property name:
        """
        The title of column. Shortcut for getting/setting data for
        :attr:`smartcols.Column.header`.

        :getter: Returns title
        :setter: Sets title
        :type: str
        """
        def __get__(self):
            return self._header.data
        def __set__(self, basestring name):
            self._header.data = name

    def set_cmpfunc(self, object func not None, object data=None):
        """
        set_cmpfunc(self, func, data=None)
        Set sorting function for the column. If `func` is None then default
        (strcmp-based) comparator will be used.

        :param function func: Comparison function (s1, s2, data)
        :param object data: Additional data for function
        """
        if self._cmp_payload is not NULL:
            free(self._cmp_payload)
        self._cmpdata = data
        if func == cmpfunc_strcmp:
            scols_column_set_cmpfunc(self._c_column, scols_cmpstr_cells, NULL)
        else:
            self._cmp_payload = <CmpPayload *>malloc(sizeof(CmpPayload))
            if not self._cmp_payload:
                raise MemoryError()
            self._cmp_payload.data = <void *>self._cmpdata
            self._cmp_payload.func = <void *>func
            scols_column_set_cmpfunc(self._c_column, cmpfunc_wrapper, <void *>self._cmp_payload)

    cdef set_flag(self, int flag, bint v):
        cdef int flags = scols_column_get_flags(self._c_column)
        cdef bint current = flags & flag
        if not current and v:
            scols_column_set_flags(self._c_column, flags | flag)
        elif current and not v:
            scols_column_set_flags(self._c_column, flags ^ flag)

    property trunc:
        """
        Truncate text in cells if necessary.
        """
        def __get__(self):
            return scols_column_is_trunc(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_TRUNC, value)

    property tree:
        """
        Use tree "ASCII Art".
        """
        def __get__(self):
            return scols_column_is_tree(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_TREE, value)

    property right:
        """
        Align text in cells to the right.
        """
        def __get__(self):
            return scols_column_is_right(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_RIGHT, value)

    property strict_width:
        """
        Do not reduce width if column is empty.
        """
        def __get__(self):
            return scols_column_is_strict_width(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_STRICTWIDTH, value)

    property noextremes:
        def __get__(self):
            return scols_column_is_noextremes(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_NOEXTREMES, value)

    property hidden:
        """
        Make column hidden for user.
        """
        def __get__(self):
            return scols_column_is_hidden(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_HIDDEN, value)

    property wrap:
        """
        Wrap long lines to multi-line cells.
        """
        def __get__(self):
            return scols_column_is_wrap(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_WRAP, value)

    property wrapnl:
        """
        Wrap long lines to multi-line cells based on newline (``\n``).
        """
        def __get__(self):
            return scols_column_is_wrapnl(self._c_column)
        def __set__(self, bint value):
            self.set_flag(SCOLS_FL_WRAPNL, value)

    property color:
        """
        The default color for data cells in column and column header.
        """
        def __get__(self):
            cdef const char *c = scols_column_get_color(self._c_column)
            return c if c is not NULL else None
        def __set__(self, basestring color):
            if color is not None:
                scols_column_set_color(self._c_column, color.encode("UTF-8"))
            else:
                scols_column_set_color(self._c_column, NULL)

    property whint:
        """
        Width hint of column.
        """
        def __get__(self):
            return scols_column_get_whint(self._c_column)
        def __set__(self, double whint):
            scols_column_set_whint(self._c_column, whint)

cdef class Line:
    """
    __init__(self, parent=None)
    Line.

    :param parent: Parent line (used if table has column with tree-output)
    :type parent: smartcols.Line

    Get cell

        >>> table = smartcols.Table()
        >>> column = table.new_column("FOO")
        >>> line = table.new_line()
        >>> line[column]
        <smartcols.Cell object at 0x7f8fb6cc9900>

    Set text to cell

        >>> table = smartcols.Table()
        >>> column = table.new_column("FOO")
        >>> line = table.new_line()
        >>> line[column] = "bar"
    """

    cdef object __weakref__
    cdef libscols_line *_c_line
    # Cells are automatically allocated by libsmartcols, but we want to return
    # Python objects, so we will create cells as libsmartcols does internally
    # and put them into set, once cell is removed in libsmartcols, we will
    # drop it as well.
    cdef set __cells__
    cdef set __childs__
    cdef Line _parent

    def __cinit__(self, Line parent=None):
        self._c_line = scols_new_line()
        if self._c_line is NULL:
            raise MemoryError()
        __refs__[<uintptr_t>self._c_line] = self
        self.__cells__ = set()
        self.__childs__ = set()
        if parent is not None:
            scols_line_add_child(parent._c_line, self._c_line)
            parent.__childs__.add(self)
            self._parent = parent
    def __dealloc__(self):
        scols_unref_line(self._c_line)

    def __getitem__(self, Column column not None):
        cdef libscols_cell *ce = scols_line_get_column_cell(self._c_line, column._c_column)
        return __refs__[<uintptr_t>ce]
    def __setitem__(self, Column column not None, basestring data):
        scols_line_set_column_data(self._c_line, column._c_column, data.encode("UTF-8"))

    property parent:
        """
        Parent line.

        :getter: Returns parent line
        :type: smartcols.Line
        """
        def __get__(self):
            return self._parent

    property color:
        """
        The color for data cells in line.
        """
        def __get__(self):
            cdef const char *c = scols_line_get_color(self._c_line)
            return c if c is not NULL else None
        def __set__(self, basestring color):
            if color is not None:
                scols_line_set_color(self._c_line, color.encode("UTF-8"))
            else:
                scols_line_set_color(self._c_line, NULL)

cdef class Symbols:
    """
    __init__(self)
    Symbols.
    """

    cdef libscols_symbols *_c_symbols
    cdef basestring __branch
    cdef basestring __right
    cdef basestring __vertical
    cdef basestring __title_padding
    cdef basestring __cell_padding

    def __cinit__(self):
        self._c_symbols = scols_new_symbols()
        if self._c_symbols is NULL:
            raise MemoryError()
    def __dealloc__(self):
        scols_unref_symbols(self._c_symbols)

    property branch:
        """
        String which represents the branch part of a tree output.
        """
        def __get__(self):
            return self.__branch
        def __set__(self, basestring value):
            if value is not None:
                scols_symbols_set_branch(self._c_symbols, value.encode("UTF-8"))
            else:
                scols_symbols_set_branch(self._c_symbols, NULL)
            self.__branch = value

    property right:
        """
        Right part of a tree output.
        """
        def __get__(self):
            return self.__right
        def __set__(self, basestring value):
            if value is not None:
                scols_symbols_set_right(self._c_symbols, value.encode("UTF-8"))
            else:
                scols_symbols_set_right(self._c_symbols, NULL)
            self.__right = value

    property vertical:
        """
        Vertical part of a tree output.
        """
        def __get__(self):
            return self.__vertical
        def __set__(self, basestring value):
            if value is not None:
                scols_symbols_set_vertical(self._c_symbols, value.encode("UTF-8"))
            else:
                scols_symbols_set_vertical(self._c_symbols, NULL)
            self.__vertical = value

    property title_padding:
        """
        Padding of a table's title.
        """
        def __get__(self):
            return self.__title_padding
        def __set__(self, basestring value):
            if value is not None:
                scols_symbols_set_title_padding(self._c_symbols, value.encode("UTF-8"))
            else:
                scols_symbols_set_title_padding(self._c_symbols, NULL)
            self.__title_padding = value

    property cell_padding:
        """
        Padding of a table's cells.
        """
        def __get__(self):
            return self.__cell_padding
        def __set__(self, basestring value):
            if value is not None:
                scols_symbols_set_cell_padding(self._c_symbols, value.encode("UTF-8"))
            else:
                scols_symbols_set_cell_padding(self._c_symbols, NULL)
            self.__cell_padding = value

@internal
cdef class TableView(Iterator):
    cdef Table _tb

    def __cinit__(self, Table table not None):
        self._tb = table

    def __iter__(self):
        return self

cdef class ColumnsView(TableView):
    def __len__(self):
        return scols_table_get_ncols(self._tb._c_table)

    def __next__(self):
        cdef libscols_column *cl
        while scols_table_next_column(self._tb._c_table, self._itr, &cl) == 0:
            return __refs__[<uintptr_t>cl]
        else:
            raise StopIteration()

    def __getitem__(self, int n):
        cdef libscols_column *cl = scols_table_get_column(self._tb._c_table, n if n >= 0 else len(self) + n)
        if cl is NULL:
            raise IndexError("Column {:d} is out of range".format(n))
        return __refs__[<uintptr_t>cl]

cdef class LinesView(TableView):
    def __len__(self):
        return scols_table_get_nlines(self._tb._c_table)

    def __next__(self):
        cdef libscols_line *ln
        while scols_table_next_line(self._tb._c_table, self._itr, &ln) == 0:
            return __refs__[<uintptr_t>ln]
        else:
            raise StopIteration()

    def __getitem__(self, int n):
        cdef libscols_line *ln = scols_table_get_line(self._tb._c_table, n if n >= 0 else len(self) + n)
        if ln is NULL:
            raise IndexError("Line {:d} is out of range".format(n))
        return __refs__[<uintptr_t>ln]

cdef dict TableTermForce = {
    "auto": SCOLS_TERMFORCE_AUTO,
    "never": SCOLS_TERMFORCE_NEVER,
    "always": SCOLS_TERMFORCE_ALWAYS}

cdef class Table:
    """
    __init__(self)
    Table.

    Create and print table

        >>> table = smartcols.Table()
        >>> column_name = table.new_column("NAME")
        >>> column_age = table.new_column("AGE")
        >>> column_age.right = True
        >>> ln = table.new_line()
        >>> ln[column_name] = "Igor Gnatenko"
        >>> ln[column_age] = "18"
        >>> print(table)
        NAME          AGE
        Igor Gnatenko  18
    """

    cdef libscols_table *_c_table
    cdef Symbols _symbols
    cdef Cell _title
    cdef set __columns__
    cdef set __lines__

    def __cinit__(self):
        self._c_table = scols_new_table()
        if self._c_table is NULL:
            raise MemoryError()
        self.__columns__ = set()
        self.__lines__ = set()
        self._title = Title.new(scols_table_get_title(self._c_table))
    def __dealloc__(self):
        scols_unref_table(self._c_table)

    def lines(self):
        """
        lines(self)

        :return: Lines view
        :rtype: smartcols.LinesView
        """
        return LinesView(self)

    def columns(self):
        """
        columns(self)

        :return: Columns view
        :rtype: smartcols.ColumnsView
        """
        return ColumnsView(self)

    def sort(self, Column column not None):
        scols_sort_table(self._c_table, column._c_column)

    def __str__(self):
        """
        __str__(self)
        Print table to string.

        :return: Table
        :rtype: string
        """
        cdef char *data = NULL
        scols_print_table_to_string(self._c_table, &data)
        cdef str ret = data
        free(data)
        return ret

    def str_line(self, Line start=None, Line end=None):
        """
        str_line(self, start=None, end=None)
        Print range of lines of the table to string including header.

        :param start: First printed line or None to print from begin of the table
        :type start: smartcols.Line
        :param end: Last printed line or None to print all lines from `start`
        :type end: smartcols.Line
        :return: Lines
        :rtype: str
        """
        cdef char *data = NULL
        scols_table_enable_nolinesep(self._c_table, True)
        scols_table_print_range_to_string(self._c_table, start._c_line if start is not None else NULL, end._c_line if end is not None else NULL, &data)
        scols_table_enable_nolinesep(self._c_table, False)
        cdef str ret = data
        free(data)
        return ret

    def json(self):
        """
        json(self)

        :return: JSON dictionary
        :rtype: dict
        """
        scols_table_enable_json(self._c_table, True)
        from json import loads
        cdef dict ret = loads(self.__str__())
        scols_table_enable_json(self._c_table, False)
        return ret

    def add_column(self, Column column not None):
        """
        add_column(self, column)
        Add column to the table.

        :param column: Column
        :type column: smartcols.Column
        """
        scols_table_add_column(self._c_table, column._c_column)
        self.__columns__.add(column)
    def new_column(self, *args, **kwargs):
        """
        new_column(self, *args, **kwargs)
        Create and add column to the table.

        The arguments are the same as for the :class:`smartcols.Column`
        constructor.

        :return: Column
        :rtype: smartcols.Column
        """
        cdef Column column = Column(*args, **kwargs)
        self.add_column(column)
        return column

    def add_line(self, Line line not None):
        """
        add_line(self, line)
        Add line to the table.

        :param line: Line
        :type line: smartcols.Line
        """
        scols_table_add_line(self._c_table, line._c_line)
        self.__lines__.add(line)
        for n in range(scols_line_get_ncells(line._c_line)):
            line.__cells__.add(Cell.new(scols_line_get_cell(line._c_line, n)))
    def new_line(self, *args, **kwargs):
        """
        new_line(self, *args, **kwargs)
        Create and add line to the table.

        The arguments are the same as for the :class:`smartcols.Line`
        constructor.

        :return: Line
        :rtype: smartcols.Line
        """
        cdef Line line = Line(*args, **kwargs)
        self.add_line(line)
        return line

    property title:
        """
        Title of the table. Printed before table.

        :getter: Get title object
        :setter: Set title text (shortcut for :attr:`smartcols.Title.data`)
        :type: weakproxy(smartcols.Title)
        """
        def __get__(self):
            return weakref.proxy(self._title)
        def __set__(self, basestring title):
            self._title.data = title

    property ascii:
        """
        Force the library to use ASCII chars for the :class:`smartcols.Column`
        with :attr:`smartcols.Column.tree` activated.
        """
        def __get__(self):
            return scols_table_is_ascii(self._c_table)
        def __set__(self, bint value):
            scols_table_enable_ascii(self._c_table, value)

    property colors:
        """
        Enable/Disable colors.
        """
        def __get__(self):
            return scols_table_colors_wanted(self._c_table)
        def __set__(self, bint value):
            scols_table_enable_colors(self._c_table, value)

    property maxout:
        """
        The extra space after last column is ignored by default. The output
        maximization use the extra space for all columns. In short words - use
        full width of terminal.
        """
        def __get__(self):
            return scols_table_is_maxout(self._c_table)
        def __set__(self, bint value):
            scols_table_enable_maxout(self._c_table, value)

    property noheadings:
        """
        Do not print header.
        """
        def __get__(self):
            return scols_table_is_noheadings(self._c_table)
        def __set__(self, bint value):
            scols_table_enable_noheadings(self._c_table, value)

    property symbols:
        """
        Used symbols. See :class:`smartcols.Symbols`.
        """
        def __get__(self):
            return self._symbols
        def __set__(self, Symbols symbols):
            if symbols is not None:
                scols_table_set_symbols(self._c_table, symbols._c_symbols)
            else:
                scols_table_set_symbols(self._c_table, NULL)
            self._symbols = symbols

    property column_separator:
        """
        Column separator.
        """
        def __get__(self):
            cdef const char *sep = scols_table_get_column_separator(self._c_table)
            return sep if sep is not NULL else None
        def __set__(self, basestring separator):
            if separator is not None:
                scols_table_set_column_separator(self._c_table, separator.encode("UTF-8"))
            else:
                scols_table_set_column_separator(self._c_table, NULL)

    property line_separator:
        """
        Line separator.
        """
        def __get__(self):
            cdef const char *sep = scols_table_get_line_separator(self._c_table)
            return sep if sep is not NULL else None
        def __set__(self, basestring separator):
            if separator is not None:
                scols_table_set_line_separator(self._c_table, separator.encode("UTF-8"))
            else:
                scols_table_set_line_separator(self._c_table, NULL)

    property termforce:
        """
        Force terminal output. One of `auto`, `never`, `always`.
        """
        def __get__(self):
            cdef int force = scols_table_get_termforce(self._c_table)
            return next(k for k, v in TableTermForce.items() if v == force)
        def __set__(self, basestring force not None):
            scols_table_set_termforce(self._c_table, TableTermForce[force])

    property termwidth:
        """
        Terminal width. The library automatically detects terminal, in case of
        failure it uses 80 characters. You can override terminal width here.
        """
        def __get__(self):
            return scols_table_get_termwidth(self._c_table)
        def __set__(self, size_t width):
            scols_table_set_termwidth(self._c_table, width)
