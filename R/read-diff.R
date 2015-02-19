#' Write or read a diff to or from a file
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
  tab <- read.csv(file, header=FALSE)
  diff$set_data(tab, FALSE)
  diff
}
