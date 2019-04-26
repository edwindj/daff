library(daff)
# set.seed(42)
#
# df.orig <- data.frame(letters=letters,
#                      ints=1:26,
#                      doubles=(1:26)+0.5,
#                      factors=factor(LETTERS),
#                      LETTERS=LETTERS,
#                      lL=paste (letters, LETTERS),
#                      stringsAsFactors = FALSE,
#                      unchanged=paste0(letters, LETTERS)
#                      )
# saveRDS(df.orig, file="tests/more_tests.Rds")
# print(getwd())
df.orig <- readRDS("more_tests.Rds")
df.ref <- df.orig
df     <- df.orig

df$letters <- as.character(df$letters)
df[ 3, "letters"] <- NA
df[ 4, "letters"] <- ""
df[ 5, "letters"] <- LETTERS[5]
df[ 6, "letters"] <- paste0(letters[6], letters[7])

# df[ 8, "ints"   ] <- NA
# df[ 9, "ints"   ] <- 0
# df[10, "ints"   ] <- -1

df[13, "doubles"] <- NA
df[14, "doubles"] <- 0.1
df[15, "doubles"] <- -1.1

df[18, "factors"] <- NA
df[19, "factors"] <- LETTERS[26]

levels(df$factors) <- c(levels(df$factors), letters, "")
df[20, "factors"] <- letters[20]
df[21, "factors"] <- ""

#df$lL[6:10]  <- gsub("^\\s*",   "",           df.ref$lL[ 6:10])
df$lL[11:15] <- paste0(" ",   df.ref$lL[11:15]     )
df$lL[16:20] <- paste0(       df.ref$lL[16:20], " ")
df$lL[21:26] <- paste0(" ",   df.ref$lL[21:26], " ")
df.changed <- df


### test

# test some diff flags
do <- function(x=df.ref, y=df, ..., print=!interactive(), render=interactive())
{
  diff <- diff_data(df.ref, df, ...)
  if(print )  print(diff)
  if(render)  render_diff(diff)
  invisible(diff)
}

# data changes
df <- df.changed
do(df.ref, df)

# permute rows!
df <- df.orig[sample(nrow(df)),]
do(df.ref, df)

# permute cols!
df <- df.orig[, sample(ncol(df))]
do(df.ref, df)

# add a row
df <- rbind(df.orig, df.orig[14,])
df[nrow(df), "ints"] <- 75
do(df.ref, df)

# remove a row
df <- df.orig[-21, ]
do(df.ref, df)

# add a column
df <- cbind(df.orig, addded=1:nrow(df.orig))
do(df.ref, df)

# remove a column
df <- df.orig[, -3]
do(df.ref, df)

df <- df.changed
# cute use of binary operator!
"%~%" <- function(...) { render_diff(diff_data(...))}
df.ref %~% df.changed

df.ref <- df.orig
df     <- df.changed
do(df.ref, df, always_show_header=TRUE)
do(df.ref, df, always_show_header=FALSE)


df.ref <- df.orig
df     <- df.changed
do(always_show_order=FALSE)
do(always_show_order=TRUE)

df.ref <- df.orig
df <- df.changed
do(columns_to_ignore=NULL)
do(columns_to_ignore=c())
do(columns_to_ignore=c("ints", "letters"))
do(columns_to_ignore=c("letters"))


df.ref <- df.orig
df <- df.changed
do(count_like_a_spreadsheet=NULL,  always_show_order=TRUE)
do(count_like_a_spreadsheet=TRUE,  always_show_order=TRUE)
do(count_like_a_spreadsheet=FALSE, always_show_order=TRUE)


df.ref <- df.orig
df <- df.changed
df$unchanged <- rev(df$unchanged)
df$ints <- sample(nrow(df), 26, replace=TRUE)
do(ids=NULL)
do(ids=c("ints", "letters"))
do(ids=c(""))

df.ref <- df.orig
df <- df.changed
do()
do(ignore_whitespace=NULL)
do(ignore_whitespace=FALSE)
do(ignore_whitespace=TRUE)

df.ref <- df.orig
df <- df.changed
do()
do(never_show_order=NULL)
do(never_show_order=FALSE)
do(never_show_order=TRUE)

tmp <- df.changed
tmp <- tmp[sample(nrow(tmp)), ]
do(y=tmp)
do(y=tmp, ordered=NULL)
do(y=tmp, ordered=TRUE)
do(y=tmp, ordered=FALSE)

df.ref <- df.orig
df     <- rbind(df.ref[1:20,], df.changed[21:26,])
do(padding_strategy="auto"  )
do(padding_strategy="smart" )
do(padding_strategy="dense" )
do(padding_strategy="sparse")

df.ref <- df.orig
df     <- rbind(df.ref[1:20,], df.changed)
do(show_unchanged=TRUE)
do(show_unchanged=FALSE)


df <- df.orig
df <- cbind(df.changed[,1:2], df.orig[, -c(1:2)])
do(show_unchanged_columns=TRUE)
do(show_unchanged_columns=FALSE)

# Test 'meta' changes in column type
df     <- cbind(df.changed, df.orig)
df$letters  <- factor(df$letters)
df$letters
df$ints     <- as.character(df$ints)
df$ints
df$factors  <- df$factors

diff_data(as.data.frame(sapply(df.ref, class)),
          as.data.frame(sapply(df,     class))
          )

do(df.ref, show_unchanged_meta=TRUE)   #! doesn't seem to be working!!
do(show_unchanged_meta=FALSE)


# Test context vars
df.ref <- df.orig
df     <- df.changed

do(unchanged_column_context=0)
do(unchanged_column_context=5)

do(unchanged_context=0)
do(unchanged_context=5)


# add and reorder column
df <- df.orig[, c(1:2, 4, 3, 5:7)]
df <- cbind(df, added1=1:nrow(df.orig), added2=1:nrow(df.orig))
do(df.ref, df)


# test columns with duplicate names
df.ref <- cbind(df.orig)
df     <- cbind(df, df.orig)
do()

# test columns with duplicate names v2
df.ref <- cbind(df.orig, df.orig)
df     <- cbind(df,      df.orig)
do()
