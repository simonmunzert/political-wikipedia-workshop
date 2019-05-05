
# install packages from CRAN
p_needed <- c("igraph", # network graphs
              "tidyverse", # the tidyverse
              "rvest", # scraping suite
              "devtools", # developer tools
              "magrittr", # piping
              "RColorBrewer", # nice colors
              "colorspace", # more nice colors
              "lubridate", # dates and times
              "networkD3", # make D3 JS network graphs
              "pageviews", # Wikipedia pageviews data
              "wikipediatrend", # Wikipedia pageviews data, old and new
              "WikipediR", # Wikipedia API
              "WikidataR" # Wikidata API
)
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}
lapply(p_needed, require, character.only = TRUE)



find_matches <- function(x, y) {
  if(length(x) > length(y)) stop("x must not be longer than y.")
  dist_mat <- sapply(x, function(xx) abs(y - xx))
  rank_mat <- sapply(x, function(xx) rank(abs(y - xx)))
  closest_matches <- numeric()
  for(i in 1:ncol(dist_mat)){
    min_rank <- order(rank_mat[,i])[1]
    closest_matches[i] <- y[min_rank]
    rank_mat <- rank_mat[-min_rank,]
    dist_mat <- dist_mat[-min_rank,]
  }
  return(closest_matches)
}
