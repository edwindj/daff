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
                 paste0("",
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
                        "           <td>",                s$row_count_change_text, "</td>",
                        "           <td class='modify'>", s$row_updates,           "</td>",
                        "           <td               >", s$row_reorders,          "</td>",
                        "           <td class='remove'>", s$row_deletes,           "</td>",
                        "           <td class='add'>"   , s$row_inserts,           "</td>",
                        "       </tr>",
                        "       <tr>",
                        "           <td style='font-weight:bold;'>Columns</td>",
                        "           <td>",                s$col_count_change_text, "</td>",
                        "           <td class='modify'>", s$col_updates,           "</td>",
                        "           <td               >", s$col_reorders,          "</td>",
                        "           <td class='remove'>", s$col_deletes,           "</td>",
                        "           <td class='add'>"   , s$col_inserts,           "</td>",
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

