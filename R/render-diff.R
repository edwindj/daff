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
)
{
  # construct the title string
  if(missing(title))
  {
    data_names <- attr(diff, "data_names")
    title <- paste(sQuote(data_names$data_ref), "vs.", sQuote(data_names$data))
  }

  # render to HTML
  ctx <- diff$ctx
  html <- ctx$call("render_diff", JS(diff$var_name), fragment, pretty)

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
    s <- summary(diff)

    if(s$rows_before == s$rows_after)
      rows_before_after <- s$rows_before
    else
      rows_before_after <- paste0(s$rows_before, " &rarr; ", s$rows_after)

    if(s$cols_before == s$cols_after)
      cols_before_after <- s$cols_before
    else
      cols_before_after <- paste0(s$cols_before, " &rarr; ", s$cols_after)

    html <- gsub("<div class='highlighter'>",
                 paste0("",
                        "<div class='highlighter' style='align:center;'>",
                        "<table style='margin: 0px auto; margin-bottom: 2em; text-align: right'>",
                        "   <thead>",
                        "       <tr class='header' style='text-align: center'>",
                        "           <th></th>",
                        "           <th>#</th>",
                        "           <th class='modify'>Modified</th>",
                        "           <th class='remove'>Removed</th>",
                        "           <th class='add'>Added</th>",
                        "   </thead>",
                        "   <tbody>",
                        "       <tr>",
                        "           <td style='font-weight:bold;'>Rows</td>",
                        "           <td>",                rows_before_after, "</td>",
                        "           <td class='modify'>", s$rows_changed,    "</td>",
                        "           <td class='remove'>", s$rows_removed,    "</td>",
                        "           <td class='add'>"   , s$rows_added,      "</td>",
                        "       </tr>",
                        "       <tr>",
                        "           <td style='font-weight:bold;'>Columns</td>",
                        "           <td>",                cols_before_after, "</td>",
                        "           <td class='modify'>", s$cols_changed,    "</td>",
                        "           <td class='remove'>", s$cols_removed,    "</td>",
                        "           <td class='add'>"   , s$cols_added,      "</td>",
                        "        </tr>",
                        "    </tbody>",
                        "</table>",
                        "</div>",
                        "<div class='highlighter'>"
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

