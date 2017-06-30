library(readr)
library(dplyr)

args = commandArgs(trailingOnly = TRUE)
infile = args[1]
outpath = args[2]

message("reading file ", infile)
ratings = read_csv(infile, col_names=c("userkey", "asin", "rating", "timestamp"), col_types="ccni",
                   progress=TRUE)

message("extracting users")
users = ratings %>%
    group_by(userkey) %>%
    summarize(nratings = n()) %>%
    ungroup() %>%
    filter(nratings >= 5) %>%
    mutate(user=1:n()) %>%
    select(user, userkey, nratings)
summary(users$nratings)

message("extracting items")
items = ratings %>%
    group_by(asin) %>%
    summarize(nratings = n()) %>%
    ungroup() %>%
    mutate(item = 1:n()) %>%
    select(item, asin, nratings)
summary(items$nratings)

message("joining ratings")
ratings.lk = ratings %>%
    inner_join(users %>% select(-nratings)) %>%
    inner_join(items %>% select(-nratings)) %>%
    select(user, item, rating)

message("writing output")
dir.create(outpath, showWarnings = FALSE)
write_csv(ratings.lk, paste(outpath, "ratings.csv", sep="/"))
write_csv(users, paste(outpath, "users.csv", sep="/"))
write_csv(items, paste(outpath, "items.csv", sep="/"))