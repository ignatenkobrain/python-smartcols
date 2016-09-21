smartcols API Reference
=======================

.. note::

   **str** represents both the types **str** and **unicode**. It is not
   compatible with the **bytes** type.

.. warning::

   Don't try to use :func:`copy.copy` or :func:`copy.deepcopy`, it's not
   implemented and can break things.

Cell
----

.. autoclass:: smartcols.Cell

Title
-----

.. autoclass:: smartcols.Title

Column
------

.. autoclass:: smartcols.Column

Line
----

.. autoclass:: smartcols.Line

Symbols
-------

.. autoclass:: smartcols.Symbols

Table
-----

.. autoclass:: smartcols.Table

Useful Functions
----------------

.. autofunction:: smartcols.init_debug

.. autofunction:: smartcols.cmpstr_cells

Enumerations used by functions
------------------------------

.. class:: smartcols.CellPosition

   Cell position. Currently used only in :class:`smartcols.Title`.

   .. attribute:: left
      Align text to the left.

   .. attribute:: center
      Align text to the center.

   .. attribute:: right
      Align text to the right.

.. class:: smartcols.TermForce

   Control terminal output usage.

   .. attribute:: auto
      Automatically detect if terminal or non-terminal output.

   .. attribute:: never
      Force to use stdout as non-terminal output.

   .. attribute:: always
      Force to use stdout as terminal output.

