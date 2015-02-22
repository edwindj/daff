#' Data diff, patch and merge for R
#'
#' Daff calculates differences between two \code{data.frame}s. This difference can be stored and later used to
#' patch the original data. Differences can also be made visual by using \code{render_diff} showing what changed.
#'
#' Storing the difference between data sets allows for tracking or incorporating manual changes to data sets.
#' Ideally changes to data should be scripted to be reproducable, but there are situations or scenario's where
#' this is not possible or happens out of your control. \code{daff} can help track these changes.
#'
#' @section actions:
#' \tabular{ll}{
#'    \code{\link{diff_data}} \tab Find differences in values between \code{data.frame}s\cr
#'    \code{\link{patch_data}} \tab Apply a patch generated with \code{\link{diff_data}} to a \code{data.frame}\cr
#'    \code{\link{merge_data}} \tab Merge two diverged \code{data.frame}s orginating from a same parent
#' }
#'
#' @section daff.js:
#' Daff wraps the daff.js library which offers more functionality.
#'
#' @name daff
#' @docType package
NULL
