from libc.stdio cimport FILE

cdef extern from "libsmartcols.h":
    void              scols_init_debug                  (int                     mask)

    int               scols_parese_version_string       (const char             *ver_string)
    int               scols_get_library_version         (const char            **ver_string)

    enum:
        SCOLS_ITER_FORWARD
        SCOLS_ITER_BACKWARD
    struct libscols_iter:
        pass
    libscols_iter    *scols_new_iter                    (int                     direction)
    void              scols_free_iter                   (libscols_iter          *itr)
    void              scols_reset_iter                  (libscols_iter          *itr,
                                                         int                     direction)
    int               scols_iter_get_direction          (const libscols_iter    *itr)

    struct libscols_symbols:
        pass
    libscols_symbols *scols_new_symbols                 ()
    void              scols_ref_symbols                 (libscols_symbols       *sy)
    void              scols_unref_symbols               (libscols_symbols       *sy)
    libscols_symbols *scols_copy_symbols                (const libscols_symbols *sy)
    int               scols_symbols_set_branch          (libscols_symbols       *sy,
                                                         const char             *str)
    int               scols_symbols_set_vertical        (libscols_symbols       *sy,
                                                         const char             *str)
    int               scols_symbols_set_right           (libscols_symbols       *sy,
                                                         const char             *str)
    int               scols_symbols_set_title_padding   (libscols_symbols       *sy,
                                                         const char             *str)
    int               scols_symbols_set_cell_padding    (libscols_symbols       *sy,
                                                         const char             *str)

    enum:
        SCOLS_CELL_FL_LEFT
        SCOLS_CELL_FL_CENTER
        SCOLS_CELL_FL_RIGHT
    struct libscols_cell:
        pass
    int               scols_reset_cell                  (libscols_cell          *ce)
    int               scols_cell_copy_content           (libscols_cell          *dest,
                                                         const libscols_cell    *src)
    int               scols_cell_set_data               (libscols_cell          *ce,
                                                         const char             *data)
    int               scols_cell_refer_data             (libscols_cell          *ce,
                                                         char                   *data)
    const char       *scols_cell_get_data               (const libscols_cell    *ce)
    int               scols_cell_set_userdata           (libscols_cell          *ce,
                                                         void                   *data)
    void             *scols_cell_get_userdata           (libscols_cell          *ce)
    int               scols_cell_set_color              (libscols_cell          *ce,
                                                         const char             *color)
    const char       *scols_cell_get_color              (const libscols_cell    *ce)
    int               scols_cell_set_flags              (libscols_cell          *ce,
                                                         int                     flags)
    int               scols_cell_get_flags              (const libscols_cell    *ce)
    int               scols_cmpstr_cells                (libscols_cell          *a,
                                                         libscols_cell          *b,
                                                         void                   *data)

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
    libscols_column  *scols_new_column                  ()
    void              scols_ref_column                  (libscols_column        *cl)
    void              scols_unref_column                (libscols_column        *cl)
    libscols_column  *scols_copy_column                 (const libscols_column  *cl)
    libscols_cell    *scols_column_get_header           (libscols_column        *cl)
    int               scols_column_set_whint            (libscols_column        *cl,
                                                         double                  whint)
    double            scols_column_get_whint            (const libscols_column  *cl)
    int               scols_column_set_color            (libscols_column        *cl,
                                                         const char             *color)
    const char       *scols_column_get_color            (const libscols_column  *cl)
    int               scols_column_set_flags            (libscols_column        *cl,
                                                         int                     flags)
    int               scols_column_get_flags            (const libscols_column  *cl)
    bint              scols_column_is_trunc             (const libscols_column  *cl)
    bint              scols_column_is_tree              (const libscols_column  *cl)
    bint              scols_column_is_right             (const libscols_column  *cl)
    bint              scols_column_is_strict_width      (const libscols_column  *cl)
    bint              scols_column_is_hidden            (const libscols_column  *cl)
    bint              scols_column_is_noextremes        (const libscols_column  *cl)
    bint              scols_column_is_wrap              (const libscols_column  *cl)
    bint              scols_column_is_wrapnl            (const libscols_column  *cl)
    int               scols_column_set_cmpfunc          (libscols_column        *cl,
                                                         int (*cmp) (libscols_cell *a,
                                                                     libscols_cell *b,
                                                                     void          *),
                                                         void                   *data)

    struct libscols_line:
        pass
    libscols_line    *scols_new_line                    ()
    void              scols_ref_line                    (libscols_line          *ln)
    void              scols_unref_line                  (libscols_line          *ln)
    libscols_line    *scols_copy_line                   (const libscols_line    *ln)
    int               scols_line_alloc_cells            (libscols_line          *ln,
                                                         size_t                  n)
    void              scols_line_free_cells             (libscols_line          *ln)
    size_t            scols_line_get_ncells             (const libscols_line    *ln)
    int               scols_line_add_child              (libscols_line          *ln,
                                                         libscols_line          *child)
    int               scols_line_remove_child           (libscols_line          *ln,
                                                         libscols_line          *child)
    int               scols_line_has_children           (libscols_line          *ln)
    int               scols_line_next_child             (libscols_line          *ln,
                                                         libscols_iter          *itr,
                                                         libscols_line         **child)
    libscols_line    *scols_line_get_parent             (const libscols_line    *ln)
    int               scols_line_set_userdata           (libscols_line          *ln,
                                                         void                   *data)
    void             *scols_line_get_userdata           (libscols_line          *ln)
    int               scols_line_set_color              (libscols_line          *ln,
                                                         const char             *color)
    const char       *scols_line_get_color              (const libscols_line    *ln)
    libscols_cell    *scols_line_get_cell               (libscols_line          *ln,
                                                         size_t                  n)
    libscols_cell    *scols_line_get_column_cell        (libscols_line          *ln,
                                                         libscols_column        *cl)
    int               scols_line_set_data               (libscols_line          *ln,
                                                         size_t                  n,
                                                         const char             *data)
    int               scols_line_refer_data             (libscols_line          *ln,
                                                         size_t                  n,
                                                         char                   *data)
    int               scols_line_set_column_data        (libscols_line          *ln,
                                                         libscols_column        *cl,
                                                         const char             *data)
    int               scols_line_refer_column_data      (libscols_line          *ln,
                                                         libscols_column        *cl,
                                                         char                   *data)

    enum:
        SCOLS_TERMFORCE_AUTO
        SCOLS_TERMFORCE_NEVER
        SCOLS_TERMFORCE_ALWAYS
    struct libscols_table:
        pass
    libscols_table   *scols_new_table                   ()
    void              scols_ref_table                   (libscols_table         *tb)
    void              scols_unref_table                 (libscols_table         *tb)
    libscols_table   *scols_copy_table                  (libscols_table         *tb)
    int               scols_sort_table                  (libscols_table         *tb,
                                                         libscols_column        *cl)
    int               scols_table_set_name              (libscols_table         *tb,
                                                         const char             *name)
    const char       *scols_table_get_name              (const libscols_table   *tb)
    bint              scols_table_is_empty              (const libscols_table   *tb)
    bint              scols_table_is_tree               (const libscols_table   *tb)
    int               scols_table_reduce_termwidth      (libscols_table         *tb,
                                                         size_t                  reduce)
    libscols_cell    *scols_table_get_title             (libscols_table         *tb)
    int               scols_table_enable_colors         (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_colors_wanted         (const libscols_table   *tb)
    int               scols_table_enable_raw            (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_raw                (const libscols_table   *tb)
    int               scols_table_enable_ascii          (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_ascii              (const libscols_table   *tb)
    int               scols_table_enable_json           (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_json               (const libscols_table   *tb)
    int               scols_table_enable_noheadings     (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_noheadings         (const libscols_table   *tb)
    int               scols_table_enable_export         (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_export             (const libscols_table   *tb)
    int               scols_table_enable_maxout         (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_maxout             (const libscols_table   *tb)
    int               scols_table_enable_nowrap         (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_nowrap             (const libscols_table   *tb)
    int               scols_table_enable_nolinesep      (libscols_table         *tb,
                                                         bint                    enable)
    bint              scols_table_is_nolinesep          (const libscols_table   *tb)
    libscols_column  *scols_table_new_column            (libscols_table         *tb,
                                                         char                   *name,
                                                         double                  whint,
                                                         int                     flags)
    int               scols_table_add_column            (libscols_table         *tb,
                                                         libscols_column        *cl)
    int               scols_table_remove_column         (libscols_table         *tb,
                                                         libscols_column        *cl)
    int               scols_table_remove_columns        (libscols_table         *tb)
    size_t            scols_table_get_ncols             (const libscols_table   *tb)
    libscols_column  *scols_table_get_column            (libscols_table         *tb,
                                                         size_t                  n)
    int               scols_table_next_column           (libscols_table         *tb,
                                                         libscols_iter          *itr,
                                                         libscols_column       **cl)
    int               scols_table_set_column_separator  (libscols_table         *tb,
                                                         const char             *sep)
    const char       *scols_table_get_column_separator  (const libscols_table   *tb)
    libscols_line    *scols_table_new_line              (libscols_table         *tb,
                                                         libscols_line          *parent)
    int               scols_table_add_line              (libscols_table         *tb,
                                                         libscols_line          *ln)
    int               scols_table_remove_line           (libscols_table         *tb,
                                                         libscols_line          *ln)
    int               scols_table_remove_lines          (libscols_table         *tb)
    size_t            scols_table_get_nlines            (const libscols_table   *tb)
    libscols_line    *scols_table_get_line              (libscols_table         *tb,
                                                         size_t                  n)
    int               scols_table_next_line             (libscols_table         *tb,
                                                         libscols_iter          *itr,
                                                         libscols_line         **ln)
    int               scols_table_set_line_separator    (libscols_table         *tb,
                                                         const char             *sep)
    const char       *scols_table_get_line_separator    (const libscols_table   *tb)
    int               scols_table_set_symbols           (libscols_table         *tb,
                                                         libscols_symbols       *sy)
    int               scols_table_set_default_symvols   (libscols_table         *tb)
    libscols_symbols *scols_table_get_symbols           (const libscols_table   *tb)
    int               scols_table_set_stream            (libscols_table         *tb,
                                                         FILE                   *stream)
    FILE             *scols_table_get_stream            (const libscols_table   *tb)
    int               scols_table_set_termforce         (libscols_table         *tb,
                                                         int                     force)
    int               scols_table_get_termforce         (const libscols_table   *tb)
    int               scols_table_set_termwidth         (libscols_table         *tb,
                                                         size_t                  width)
    size_t            scols_table_get_termwidth         (const libscols_table   *tb)
    int               scols_print_table                 (libscols_table         *tb)
    int               scols_print_table_to_string       (libscols_table         *tb,
                                                         char                  **data)
    int               scols_table_print_range           (libscols_table         *tb,
                                                         libscols_line          *start,
                                                         libscols_line          *end)
    int               scols_table_print_range_to_string (libscols_table         *tb,
                                                         libscols_line          *start,
                                                         libscols_line          *end,
                                                         char                  **data)
