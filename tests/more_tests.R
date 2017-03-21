df.ref <- data.frame(letters=letters,
                     ints=1:26,
                     doubles=(1:26)+0.5,
                     factors=factor(LETTERS)
                     )
df     <- df.ref

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

# test
render_diff(diff_data(df.ref, df))

# permute rows!
df <- df[sample(nrow(df)),]
render_diff(diff_data(df.ref, df))

# permute cols!
df <- df[, sample(ncol(df))]
render_diff(diff_data(df.ref, df))

# add a row
df <- rbind(df, df[14,])
df[nrow(df), "ints"] <- 75
render_diff(diff_data(df.ref, df))

# remove a row
df <- df[-21, ]
render_diff(diff_data(df.ref, df))

# remove a column
df <- df[, -3]
render_diff(diff_data(df.ref, df))
