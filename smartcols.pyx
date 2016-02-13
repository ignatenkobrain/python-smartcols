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

cimport csmartcols
from libc.stdlib cimport free

cdef class Cell:

    cdef csmartcols.libscols_cell* _c_cell

    property data:
        def __get__(self):
            cdef const char* d = csmartcols.scols_cell_get_data(self._c_cell)
            return d if d is not NULL else None
        def __set__(self, unicode data):
            if data is not None:
                csmartcols.scols_cell_set_data(self._c_cell, data.encode("UTF-8"))
            else:
                csmartcols.scols_cell_set_data(self._c_cell, NULL)

    property color:
        def __get__(self):
            cdef const char* c = csmartcols.scols_cell_get_color(self._c_cell)
            return c if c is not NULL else None
        def __set__(self, unicode color):
            if color is not None:
                csmartcols.scols_cell_set_color(self._c_cell, color.encode("UTF-8"))
            else:
                csmartcols.scols_cell_set_color(self._c_cell, NULL)

cdef dict TitlePosition = {
    "left": csmartcols.SCOLS_CELL_FL_LEFT,
    "center": csmartcols.SCOLS_CELL_FL_CENTER,
    "right": csmartcols.SCOLS_CELL_FL_RIGHT}

cdef class Title(Cell):

    property position:
        def __get__(self):
            cdef int pos = csmartcols.scols_cell_get_flags(self._c_cell)
            return next(k for k, v in TitlePosition.items() if v == pos)
        def __set__(self, unicode position not None):
            pos = TitlePosition.get(position)
            if pos is not None:
                csmartcols.scols_cell_set_flags(self._c_cell, pos)
            else:
                raise KeyError("Position {} is not valid".format(position))

cdef class Column:

    cdef csmartcols.libscols_column* _c_column

    def __cinit__(self, unicode name=None):
        self._c_column = csmartcols.scols_new_column()
        if self._c_column is NULL:
            raise MemoryError()
        if name is not None:
            self.name = name
    def __dealloc__(self):
        if self._c_column is not NULL:
            csmartcols.scols_unref_column(self._c_column)

    cdef set_flag(self, int flag, bint v):
        cdef int flags = csmartcols.scols_column_get_flags(self._c_column)
        cdef bint current = flags & flag
        if not current and v:
            csmartcols.scols_column_set_flags(self._c_column, flags | flag)
        elif current and not v:
            csmartcols.scols_column_set_flags(self._c_column, flags ^ flag)

    property trunc:
        def __get__(self):
            return csmartcols.scols_column_is_trunc(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_TRUNC, value)

    property tree:
        def __get__(self):
            return csmartcols.scols_column_is_tree(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_TREE, value)

    property right:
        def __get__(self):
            return csmartcols.scols_column_is_right(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_RIGHT, value)

    property strict_width:
        def __get__(self):
            return csmartcols.scols_column_is_strict_width(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_STRICTWIDTH, value)

    property noextremes:
        def __get__(self):
            return csmartcols.scols_column_is_noextremes(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_NOEXTREMES, value)

    property hidden:
        def __get__(self):
            return csmartcols.scols_column_is_hidden(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_HIDDEN, value)

    property wrap:
        def __get__(self):
            return csmartcols.scols_column_is_wrap(self._c_column)
        def __set__(self, bint value):
            self.set_flag(csmartcols.SCOLS_FL_WRAP, value)

    property name:
        def __get__(self):
            cdef Cell cell = Cell()
            cell._c_cell = csmartcols.scols_column_get_header(self._c_column)
            return cell.data
        def __set__(self, unicode name):
            cdef Cell cell = Cell()
            cell._c_cell = csmartcols.scols_column_get_header(self._c_column)
            cell.data = name

    property color:
        def __get__(self):
            cdef const char* c = csmartcols.scols_column_get_color(self._c_column)
            return c if c is not NULL else None
        def __set__(self, unicode color):
            if color is not None:
                csmartcols.scols_column_set_color(self._c_column, color.encode("UTF-8"))
            else:
                csmartcols.scols_column_set_color(self._c_column, NULL)

    property whint:
        def __get__(self):
            return csmartcols.scols_column_get_whint(self._c_column)
        def __set__(self, double whint):
            csmartcols.scols_column_set_whint(self._c_column, whint)

cdef class Line:

    cdef csmartcols.libscols_line* _c_line

    def __cinit__(self, Line parent=None):
        self._c_line = csmartcols.scols_new_line()
        if self._c_line is NULL:
            raise MemoryError()
        if parent is not None:
            csmartcols.scols_line_add_child(parent._c_line, self._c_line)
    def __dealloc__(self):
        if self._c_line is not NULL:
            csmartcols.scols_unref_line(self._c_line)

    def __getitem__(self, Column column not None):
        cdef Cell cell = Cell()
        cell._c_cell = csmartcols.scols_line_get_column_cell(self._c_line, column._c_column)
        return cell
    def __setitem__(self, Column column not None, unicode data):
        csmartcols.scols_line_set_column_data(self._c_line, column._c_column, data.encode("UTF-8"))

    property color:
        def __get__(self):
            cdef const char* c = csmartcols.scols_line_get_color(self._c_line)
            return c if c is not NULL else None
        def __set__(self, unicode color):
            if color is not None:
                csmartcols.scols_line_set_color(self._c_line, color.encode("UTF-8"))
            else:
                csmartcols.scols_line_set_color(self._c_line, NULL)

cdef class Symbols:

    cdef csmartcols.libscols_symbols* _c_symbols
    cdef object __branch
    cdef object __right
    cdef object __vertical
    cdef object __title_padding

    def __cinit__(self):
        self._c_symbols = csmartcols.scols_new_symbols()
        if self._c_symbols is NULL:
            raise MemoryError()
    def __dealloc__(self):
        if self._c_symbols is not NULL:
            csmartcols.scols_unref_symbols(self._c_symbols)

    property branch:
        def __get__(self):
            return self.__branch
        def __set__(self, unicode value):
            if value is not None:
                csmartcols.scols_symbols_set_branch(self._c_symbols, value.encode("UTF-8"))
            else:
                csmartcols.scols_symbols_set_branch(self._c_symbols, NULL)
            self.__branch = value

    property right:
        def __get__(self):
            return self.__right
        def __set__(self, unicode value):
            if value is not None:
                csmartcols.scols_symbols_set_right(self._c_symbols, value.encode("UTF-8"))
            else:
                csmartcols.scols_symbols_set_right(self._c_symbols, NULL)
            self.__right = value

    property vertical:
        def __get__(self):
            return self.__vertical
        def __set__(self, unicode value):
            if value is not None:
                csmartcols.scols_symbols_set_vertical(self._c_symbols, value.encode("UTF-8"))
            else:
                csmartcols.scols_symbols_set_vertical(self._c_symbols, NULL)
            self.__vertical = value

    property title_padding:
        def __get__(self):
            return self.__title_padding
        def __set__(self, unicode value):
            if value is not None:
                csmartcols.scols_symbols_set_title_padding(self._c_symbols, value.encode("UTF-8"))
            else:
                csmartcols.scols_symbols_set_title_padding(self._c_symbols, NULL)
            self.__title_padding = value

cdef class Table:

    cdef csmartcols.libscols_table* _c_table

    def __cinit__(self):
        self._c_table = csmartcols.scols_new_table()
        if self._c_table is NULL:
            raise MemoryError()
    def __dealloc__(self):
        if self._c_table is not NULL:
            csmartcols.scols_unref_table(self._c_table)

    def __str__(self):
        cdef char* data = NULL;
        csmartcols.scols_print_table_to_string(self._c_table, &data)
        cdef unicode ret = data
        free(data)
        return ret

    def json(self):
        csmartcols.scols_table_enable_json(self._c_table, True)
        from json import loads
        cdef dict ret = loads(self.__str__())
        csmartcols.scols_table_enable_json(self._c_table, False)
        return ret

    def add_column(self, Column column not None):
        csmartcols.scols_table_add_column(self._c_table, column._c_column)
    def new_column(self, *args, **kwargs):
        cdef Column column = Column(*args, **kwargs)
        self.add_column(column)
        return column

    def add_line(self, Line line not None):
        csmartcols.scols_table_add_line(self._c_table, line._c_line)
    def new_line(self, *args, **kwargs):
        cdef Line line = Line(*args, **kwargs)
        self.add_line(line)
        return line

    property ascii:
        def __get__(self):
            return csmartcols.scols_table_is_ascii(self._c_table)
        def __set__(self, bint value):
            csmartcols.scols_table_enable_ascii(self._c_table, value)

    property colors:
        def __get__(self):
            return csmartcols.scols_table_colors_wanted(self._c_table)
        def __set__(self, bint value):
            csmartcols.scols_table_enable_colors(self._c_table, value)

    property maxout:
        def __get__(self):
            return csmartcols.scols_table_is_maxout(self._c_table)
        def __set__(self, bint value):
            csmartcols.scols_table_enable_maxout(self._c_table, value)

    property noheadings:
        def __get__(self):
            return csmartcols.scols_table_is_noheadings(self._c_table)
        def __set__(self, bint value):
            csmartcols.scols_table_enable_noheadings(self._c_table, value)

    property column_separator:
        def __get__(self):
            cdef const char* sep = csmartcols.scols_table_get_column_separator(self._c_table)
            return sep if sep is not NULL else None
        def __set__(self, separator):
            csmartcols.scols_table_set_column_separator(self._c_table, separator)
            if separator is not None:
                csmartcols.scols_table_set_column_separator(self._c_table, separator)
            else:
                csmartcols.scols_table_set_column_separator(self._c_table, NULL)

    property line_separator:
        def __get__(self):
            cdef const char* sep = csmartcols.scols_table_get_line_separator(self._c_table)
            return sep if sep is not NULL else None
        def __set__(self, separator):
            csmartcols.scols_table_set_line_separator(self._c_table, separator)
            if separator is not None:
                csmartcols.scols_table_set_line_separator(self._c_table, separator)
            else:
                csmartcols.scols_table_set_line_separator(self._c_table, NULL)

    property title:
        def __get__(self):
            cdef Title title = Title()
            title._c_cell = csmartcols.scols_table_get_title(self._c_table)
            return title
        def __set__(self, unicode title):
            self.title.data = title
