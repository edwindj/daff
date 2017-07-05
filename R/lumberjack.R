# A logger for the 'lumberjack' package.



#' Automatically derive daffs with the lumberjack package
#'
#' The lbj_daff logger creates a \code{daff} and writes it to \code{daff<n>.csv}
#' in a directory of choice.
#'
#' @import R6
#'
#' @section Creating a logger:
#'
#' \code{filedump$new(dir=file.path(tempdir(),"daff")
#'    , prefix="step\%03d.csv", verbose=TRUE, ...)}
#' \tabular{ll}{
#'   \code{dir}\tab Where to write the daff files.\cr
#'   \code{filename}\tab filename template, used with \code{\link{sprintf}}
#'      to create a file name.\cr
#'   \code{verbose}\tab toggle verbosity\cr
#'   \code{...}\tab Extra arguments, passed to \code{diff_data} each time.
#' }
#'
#' @section Dump options:
#'
#' \code{$dump(...)}
#' \tabular{ll}{
#'   \code{...}\tab Currently unused.\cr
#' }
#'
#' @section Retrieve log data:
#'
#' \code{$logdata(simplify=TRUE)} returns a list of data frames, sorted in the
#'   order returned by \code{base::dir()}
#' \code{$diffs(simplify=TRUE)} returns a list of \code{daff} objects, sorted
#'   in the order returned by \code{base::dir()}
#'
#' \tabular{ll}{
#' \code{simplify}\tab Simplify lists of length 1 to data.frame?
#' }
#'
#' @section Details:
#'
#' If \code{dir} does not exist it is created. If
#'
#'
#' @docType class
#' @format An \code{R6} class object.
#'
#' @examples
#' \dontrun{
#'  library(lumberjack)
#'  logger <- lbj_daff$new()
#'  women %>>%
#'    start_log(logger) %>>%
#'    head() %>>%
#'    {. * 2} %>>%
#'    dump_log()
#'  L <- logger$logdata()
#'  L[[2]]
#'  L <- logger$diffs()
#'  L[[1]]
#' }
#'
#' @family loggers
#' @export
lbj_daff <- R6Class("lpj_daff"
  , public=list(
    n = NULL
    , dir = NULL
    , verbose = NULL
    , filename = NULL
    , daff_args = NULL
    , initialize = function(dir = file.path(tempdir(), "daff")
       , filename="daff%03d.csv", verbose = TRUE,...){
      self$n <- 0
      self$dir <- dir
      if (!dir.exists(dir)){
        dir.create(dir,recursive = TRUE)
        if (verbose){
          msgf("Created %s", normalizePath(dir))
        }
      }
      self$verbose <- verbose
      self$filename <- filename
      self$daff_args <- list(...)
    }
    , add = function(meta, input, output){
        outname <- file.path(self$dir,sprintf(self$filename,self$n))
        self$n <- self$n + 1
        outname <- file.path(self$dir, sprintf(self$filename,self$n))
        arglist <- c(list(data_ref=input, data=output), self$daff_args)
        output <- do.call("diff_data", arglist)
        write_diff(output, file=outname)
    }
    , dump = function(...){
        if ( self$verbose ){
          msgf("daffs were written to %s", normalizePath(self$dir))
        }
    }
   , logdata = function(simplify=TRUE){
      fl <- dir(self$dir,full.names = TRUE)
      L <- lapply(fl, function(x) read_diff(x)$get_data())
      if (simplify && length(L) == 1L) L[[1]] else L
   }
   , diffs = function(simplify=TRUE){
      fl <- dir(self$dir, full.names=TRUE)
      L <- lapply(fl, read_diff)
      if (simplify && length(L) == 1L) L[[1]] else L
   }
))

# msgf: the reasonable messenger :^)
msgf <- function(fmt,...) message(sprintf(fmt,...))
