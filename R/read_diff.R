#' write a diff to a file
#'
#' @param diff generated with diff_data
#' @param file filename or connection
#' @export
write_diff <- function(diff, file="diff.csv"){
  stopifnot(inherits(diff, "TableView"))
  cat(diff$to_csv(), file=file)
}

#' Read a diff from a file
#'
#' @param file filename or connection
#' @return diff object that can be used in \code{\link{patch_data}}
#' @export
read_diff <- function(file){
  ctx <- get_context()
  diff <- TableView(ctx)
  tab <- read.csv(file, header=FALSE)
  diff$set_data(tab, FALSE)
  diff
}
