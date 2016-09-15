cdef extern from "libsmartcols.h":
    void                scols_init_debug                  (int                  mask)

    ctypedef int        (*cmpfunc)                        (libscols_cell       *a,
                                                           libscols_cell       *b,
                                                           void                *data)
    int                 scols_cmpstr_cells                (libscols_cell       *a,
                                                           libscols_cell       *b,
                                                           void                *data)

    enum:
        SCOLS_CELL_FL_LEFT
        SCOLS_CELL_FL_CENTER
        SCOLS_CELL_FL_RIGHT
    struct libscols_cell:
        pass
    const char         *scols_cell_get_data               (const libscols_cell *cell)
    int                 scols_cell_set_data               (libscols_cell       *cell,
                                                           const char          *data)
    const char         *scols_cell_get_color              (const libscols_cell *cell)
    int                 scols_cell_set_color              (libscols_cell       *cell,
                                                           const char          *color)
    int                 scols_cell_get_flags              (const libscols_cell *cell)
    int                 scols_cell_set_flags              (libscols_cell       *cell,
                                                           int                  flags)

    enum:
        SCOLS_FL_TRUNC
        SCOLS_FL_TREE
        SCOLS_FL_RIGHT
        SCOLS_FL_STRICTWIDTH
        SCOLS_FL_NOEXTREMES
        SCOLS_FL_HIDDEN
        SCOLS_FL_WRAP
        SCOLS_FL_WRAPNL
    struct libscols_column:
        pass
    libscols_column    *scols_new_column                  ()
    void                scols_unref_column                (libscols_column     *column)
    int                 scols_column_set_cmpfunc          (libscols_column     *column,
                                                           cmpfunc              func,
                                                           void                *data)
    int                 scols_column_get_flags            (libscols_column     *column)
    int                 scols_column_set_flags            (libscols_column     *column,
                                                           int                  flags)
    bint                scols_column_is_trunc             (libscols_column     *column)
    bint                scols_column_is_tree              (libscols_column     *column)
    bint                scols_column_is_right             (libscols_column     *column)
    bint                scols_column_is_strict_width      (libscols_column     *column)
    bint                scols_column_is_noextremes        (libscols_column     *column)
    bint                scols_column_is_hidden            (libscols_column     *column)
    bint                scols_column_is_wrap              (libscols_column     *column)
    bint                scols_column_is_wrapnl            (libscols_column     *column)
    libscols_cell      *scols_column_get_header           (libscols_column     *column)
    const char         *scols_column_get_color            (libscols_column     *column)
    int                 scols_column_set_color            (libscols_column     *column,
                                                           const char          *color)
    double              scols_column_get_whint            (libscols_column     *column)
    int                 scols_column_set_whint            (libscols_column     *column,
                                                           double               whint)

    struct libscols_line:
        pass
    libscols_line      *scols_new_line                    ()
    void                scols_unref_line                  (libscols_line       *line)
    int                 scols_line_add_child              (libscols_line       *line,
                                                           libscols_line       *child)
    libscols_cell      *scols_line_get_column_cell        (libscols_line       *line,
                                                           libscols_column     *column)
    int                 scols_line_set_column_data        (libscols_line       *line,
                                                           libscols_column     *column,
                                                           const char          *data)
    const char         *scols_line_get_color              (libscols_line       *line)
    int                 scols_line_set_color              (libscols_line       *line,
                                                           const char          *color)

    struct libscols_symbols:
        pass
    libscols_symbols   *scols_new_symbols                 ()
    void                scols_unref_symbols               (libscols_symbols    *symbols)
    int                 scols_symbols_set_branch          (libscols_symbols    *symbols,
                                                           const char          *s)
    int                 scols_symbols_set_right           (libscols_symbols    *symbols,
                                                           const char          *s)
    int                 scols_symbols_set_vertical        (libscols_symbols    *symbols,
                                                           const char          *s)
    int                 scols_symbols_set_title_padding   (libscols_symbols    *symbols,
                                                           const char          *s)
    int                 scols_symbols_set_cell_padding    (libscols_symbols    *symbols,
                                                           const char          *s)

    struct libscols_table:
        pass
    libscols_table     *scols_new_table                   ()
    void                scols_unref_table                 (libscols_table      *table)
    int                 scols_sort_table                  (libscols_table      *table,
                                                           libscols_column     *column)
    int                 scols_print_table_to_string       (libscols_table      *table,
                                                           char               **data)
    int                 scols_table_enable_nolinesep      (libscols_table      *table,
                                                           bint                 enable)
    int                 scols_table_print_range           (libscols_table      *table,
                                                           libscols_line       *start,
                                                           libscols_line       *end)
    int                 scols_table_print_range_to_string (libscols_table      *table,
                                                           libscols_line       *start,
                                                           libscols_line       *end,
                                                           char               **data)
    int                 scols_table_enable_json           (libscols_table      *table,
                                                           bint                 value)
    bint                scols_table_is_ascii              (libscols_table      *table)
    int                 scols_table_add_column            (libscols_table      *table,
                                                           libscols_column     *column)
    int                 scols_table_add_line              (libscols_table      *table,
                                                           libscols_line       *line)
    int                 scols_table_enable_ascii          (libscols_table      *table,
                                                           bint                 value)
    bint                scols_table_colors_wanted         (libscols_table      *table)
    int                 scols_table_enable_colors         (libscols_table      *table,
                                                           bint                 value)
    bint                scols_table_is_maxout             (libscols_table      *table)
    int                 scols_table_enable_maxout         (libscols_table      *table,
                                                           bint                 value)
    bint                scols_table_is_noheadings         (libscols_table      *table)
    int                 scols_table_enable_noheadings     (libscols_table      *table,
                                                           bint                 value)
    int                 scols_table_set_symbols           (libscols_table      *table,
                                                           libscols_symbols    *symbols)
    char               *scols_table_get_column_separator  (libscols_table      *table)
    int                 scols_table_set_column_separator  (libscols_table      *table,
                                                           const char          *separator)
    char               *scols_table_get_line_separator    (libscols_table      *table)
    int                 scols_table_set_line_separator    (libscols_table      *table,
                                                           const char          *separator)
    libscols_cell      *scols_table_get_title             (libscols_table      *table)

    enum:
        SCOLS_TERMFORCE_AUTO
        SCOLS_TERMFORCE_NEVER
        SCOLS_TERMFORCE_ALWAYS
    int                 scols_table_get_termforce         (libscols_table      *table)
    int                 scols_table_set_termforce         (libscols_table      *table,
                                                           int                  force)
    size_t              scols_table_get_termwidth         (libscols_table      *table)
    int                 scols_table_set_termwidth         (libscols_table      *table,
                                                           size_t               width)
