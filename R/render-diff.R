#' Render a data diff  to html
#'
#' \code{render_diff} will show a diff in html. When \code{view} is \code{TRUE} \code{render_diff} will show
#' the result in a browser.
#'
#' @example ./examples/render-diff.R
#' @param diff object generated with \code{\link{diff_data}}
#' @param file to write to
#' @param view \code{TRUE} or \code{FALSE}, if \code{TRUE} render_diff will show the diff
#' in the browser (only if R is used interactively)
#' @param fragment if \code{FALSE} the generated HTML will be a valid HTML document, otherwise it is a HTML fragment
#' @param pretty if \code{TRUE} use fancy utf8 characters to make arrows prettier.
#' @return generated html
#'@export
render_diff <- function( diff
                         , file=tempfile(fileext = ".html")
                         , view=interactive()
                         , fragment=FALSE
                         , pretty=TRUE
                         , title=paste("Daff Comparison -",   Sys.time())
                         , ...
)
{
  ctx <- diff$ctx
  html <- ctx$call("render_diff", JS(diff$var_name), fragment, pretty)

  if(pretty)
  {
    # Replace 'pretty' \u2192 Unicode arrows with html arrows, since
    # the \u2192 Unicode character doesn't display in all browsers,
    # including Chrome on Mac OS X

    # At the start of the line, use double right arrow
    modified.line.pattern <- '<tr class=\"modify\"><td class=\"modify\">\u2192</td>'
    modified.line.replace <- paste0('<td class=\"modify\">&rArr;</td>')

    html <- gsub(modified.line.pattern,
                 modified.line.replace,
                 html,
                 fixed=TRUE)

    # Anywhere else, replace with space, single right arrow, space
    modified.cell.pattern <- '\u2192'
    modified.cell.replace <- ' &rarr; '

    html <- gsub(modified.cell.pattern,
                 modified.cell.replace,
                 html,
                 fixed=TRUE)
  }

  # Add title and header if provided
  if(!fragment && !missing(title))
    html <- gsub("</head>\\s*<body>",
                 paste0("<title>", title ,"</title>", "\n",
                        "</head>", "\n",
                        "<body>", "\n",
                        "<h1>", "<center>", title,      "</center>", "</h1>", "\n",
                        "<h3>", "<center>", Sys.time(), "</center>", "</h3>", "\n"
                        ),
                 html
    )

  cat(html, file = file)

  if (view && file != "" && interactive()){
    viewer <- getOption("viewer")
    if (!is.null(viewer) && is.function(viewer)){
      viewer(file)
    }else{
      utils::browseURL(file)
    }
  }
  invisible(html)
}

