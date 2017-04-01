#' Render a data_diff to html
#'
#' Converts a diff_data object to HTML code, and opens the resulting HTML code
#' in a browser window if \code{view==TRUE} and R is running interactively.
#'
#' @example ./examples/render-diff.R
#' @param diff     \code{diff_data object} generated with \code{\link{diff_data}}
#' @param file     \code{character}        target file (optional)
#' @param view     \code{logical}          Open the generated HTML in a browser
#'                                         if R is being used interactively
#' @param fragment \code{logical}          If \code{TRUE} generate (just) an
#'                                         HTML table, otherwise
#'                                         generate a valid HTML document.
#' @param pretty   \code{logical}          Use HTML arrow characters instead of '-->'.
#' @param title    \code{character}        title text. Defaults to the quoted
#'                                         names of the data objects compared,
#'                                         separated by 'vs.'
#' @param summary  \code{logical}          Should a summary of changes be shown above
#'                                         the HTML table?
#' @param use.DataTables \code{logical}    Include jQuery DataTables plugin and enable:
#'                                         - pagination (10,25,50,100,All)
#'                                         - searching
#'                                         - filtering
#'                                         - column visibility (individually enable/disable)
#'                                         - copy/csv/excel/pdf export buttons
#'                                         - column reorder (drag and drop)
#'                                         - row reorder (drag and drop)
#'                                         - row/multirow select
#'
#' @return generated html
#'
#' @seealso data_diff
#'
#' @export
render_diff <- function(  diff
                        , file=tempfile(fileext = ".html")
                        , view=interactive()
                        , fragment=FALSE
                        , pretty=TRUE
                        , title
                        , summary=!fragment
                        , use.DataTables=!fragment
)
{
  # get summary information
  s <- summary(diff)

  # construct the title string
  if(missing(title))
  {
    data_names <- attr(diff, "data_names")
    title <- paste(sQuote(s$source_name), "vs.", sQuote(s$target_name))
  }

  # render to HTML
  ctx <- diff$ctx
  html <- ctx$call("render_diff", JS(diff$var_name), fragment, pretty)

  # add id to main table so we can target it in JavaScript
  html <- gsub("<table>",
               "<table id='main' class='dataTable'>",
               html
               )

  if(pretty)
  {
    # Replace \u2192 Unicode arrows with html arrows, since it doesn't display
    # correctly (or at all) in some browsers, notably Chrome version 50-55 on
    # some platforms.
    #
    # **These changes should be propogated back into the underlying daff source code.**\

    # BONUS: At the start of the line, use double right arrow, allowing searches
    # to distinguish between "line contains changes" (double right) and
    # "this cell has changed" (single right)
    modified.line.pattern <- '<tr class="modify">(<td class="index">[0-9:]+</td>)?<td class="modify">\u2192</td>'
    modified.line.replace <- '<tr class="modify">\\1<td class=\"modify\">&rArr;</td>'

    html <- gsub(modified.line.pattern,
                 modified.line.replace,
                 html,
                 perl=TRUE)

    # Anywhere else, replace with single right arrow bounded by spaces. The spaces
    # makes the arrow easier to distinguies visually as wells as allowing browsers
    # to split cells containing long strings before/and/or after the arrow.
    modified.cell.pattern <- '\u2192'
    modified.cell.replace <- ' &rarr; '

    html <- gsub(modified.cell.pattern,
                 modified.cell.replace,
                 html,
                 fixed=TRUE)
  }

  # Add title in header and body, as well as date and time
  if(!fragment)
    html <- gsub("</head>\\s*<body>",
                 paste0("<title>", title ,"</title>", "\n",
                        "</head>", "\n",
                        "<body>", "\n",
                        "<h1 style='text-align: center;'>", title,      "</h1>", "\n",
                        "<h3 style='text-align: center;'>", Sys.time(), "</h3>", "\n"
                        ),
                 html
    )


  if(summary)
  {
    row_count_change_text <- s$row_count_change_text
    col_count_change_text <- s$col_count_change_text

    if(pretty)
    {
      row_count_change_text <- gsub("-->", "&rarr;", row_count_change_text)
      col_count_change_text <- gsub("-->", "&rarr;", col_count_change_text)
    }

    html <- gsub("<div class='highlighter'>",
                 paste("",
                       "<div class='highlighter' style='align:center;'>",
                       "<table style='margin: 0px auto; margin-bottom: 2em; text-align: right'>",
                       "   <thead>",
                       "       <tr class='header' style='text-align: center'>",
                       "           <th></th>",
                       "           <th>#</th>",
                       "           <th class='modify'>Modified</th>",
                       "           <th               >Reordered</th>",
                       "           <th class='remove'>Deleted</th>",
                       "           <th class='add'>Added</th>",
                       "   </thead>",
                       "   <tbody>",
                       "       <tr>",
                       "           <td style='font-weight:bold;'>Rows</td>",
                       "           <td>",                row_count_change_text,   "</td>",
                       "           <td class='modify'>", s$row_updates,           "</td>",
                       "           <td               >", s$row_reorders,          "</td>",
                       "           <td class='remove'>", s$row_deletes,           "</td>",
                       "           <td class='add'>"   , s$row_inserts,           "</td>",
                       "       </tr>",
                       "       <tr>",
                       "           <td style='font-weight:bold;'>Columns</td>",
                       "           <td>",                col_count_change_text, "</td>",
                       "           <td class='modify'>", s$col_updates,           "</td>",
                       "           <td               >", s$col_reorders,          "</td>",
                       "           <td class='remove'>", s$col_deletes,           "</td>",
                       "           <td class='add'>"   , s$col_inserts,           "</td>",
                       "        </tr>",
                       "    </tbody>",
                       "</table>",
                       "</div>",
                       "<div class='highlighter'>",
                       sep="\n"
                       ),
                 html
                 )
  }

  if(use.DataTables && !fragment)
  {
    html <- gsub("</style>",
                 paste(
                   '',
                   'table.dataTable, table.dataTable th, table.dataTable td { ',
                   '    -webkit-box-sizing: content-box;                      ',
                   '    -moz-box-sizing: content-box;                         ',
                   '    box-sizing: content-box;                              ',
                   '}',
                   '</style>',
                   '',
                   '<script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.2.1.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.2.4/css/buttons.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/dataTables.buttons.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.flash.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/2.5.0/jszip.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.rawgit.com/bpampuch/pdfmake/0.1.24/build/pdfmake.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.rawgit.com/bpampuch/pdfmake/0.1.24/build/vfs_fonts.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.html5.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.print.min.js"></script>',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.2.4/js/buttons.colVis.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.3.2/css/colReorder.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/colreorder/1.3.2/js/dataTables.colReorder.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedcolumns/3.2.2/css/fixedColumns.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/fixedcolumns/3.2.2/js/dataTables.fixedColumns.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.2/css/fixedHeader.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/fixedcolumns/3.2.2/js/dataTables.fixedColumns.min.js"></script>',
                   '',
                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/1.2.1/css/select.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/select/1.2.1/js/dataTables.select.min.js"></script>',

                   '<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/rowreorder/1.2.0/css/rowReorder.dataTables.min.css">',
                   '<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/rowreorder/1.2.0/js/dataTables.rowReorder.min.js"></script>',
                   '',
                   '<script type="text/javascript">',
                   '$(document).ready( function() {',
                   '    $("#main").DataTable( {          ',
                   '         buttons: [                  ',
                   '                       "colvis",     ',
                   '                       "copy",       ',
                   '                       "csv",        ',
                   '                       "excel",      ',
                   '                       "pdf",        ',
                   '                  ],                 ',
                   '         colReorder:   true,         ',
                   '         dom:          "Blfrtip",    ',
                   '         fixedHeader:  true,         ',
                   '         keys:         true,         ',
                   '         lengthMenu:   [              ',
                   '                        [  ',
                   '                           10,         ',
                   '                           25,         ',
                   '                           50,         ',
                   '                           100,        ',
                   '                           -1          ',
                   ',                       ],             ',
                   '                        [  ',
                   '                           10,         ',
                   '                           25,         ',
                   '                           50,         ',
                   '                           100,        ',
                   '                           "All"       ',
                   '                        ]              ',
                   '                      ],               ',
                   '         pageLength:   -1,           ',
                   '         paging:       true,         ',
                   '         rowReorder:   true,         ',
                   '         select:       true,         ',
                   '    } );                             ',
                   '});',
                   '</script>',
                   sep="\n"
                 ),
                 html
                 )
  }


  # Write to the specified file
  cat(html, file = file)

  # Display in a browser window
  if (view && file != "" && interactive()){
    viewer <- getOption("viewer")
    if (!is.null(viewer) && is.function(viewer)){
      viewer(file)
    }else{
      utils::browseURL(file)
    }
  }

  # return the rendered HTML code
  invisible(html)
}

