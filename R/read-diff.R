#' Write or read a diff to or from a file
#'
#' The diff information is stored in the Coopy highlighter diff format:
#' \url{http://dataprotocols.org/tabular-diff-format/}
#'
#' Note that type information of the target data.frame is lost when writing a patch to disk.
#' Using a stored diff to patch a \code{data.frame} will use the column types of the source
#' \code{data.frame} to determine the target column types. New introduced columns may become \code{characters}.
#'
#' Names of the reference and comparison dataset are also lost when writing a patch to disk.
#'
#' @param diff generated with diff_data
#' @param file filename or connection
#' @export
#' @rdname readwrite
write_diff <- function(diff, file="diff.csv"){
  stopifnot(inherits(diff, "TableView"))
  cat(diff$to_csv(), file=file)
}

#' @return diff object that can be used in \code{\link{patch_data}}
#' @export
#' @rdname readwrite
read_diff <- function(file){
  ctx <- get_context()
  diff <- TableView(ctx)
  tab <- utils::read.csv(file, header=FALSE)
  diff$set_data(tab, FALSE)
  diff
}
