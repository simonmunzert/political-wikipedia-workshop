source("packages.r")

### algorithm:
# 1. search for search term; collect pages (with a certain minimum word count)
# 2. look for frequent categories within the collected pages
# 3. collect all pages within these categories


## define seed keywords --------
climate_keywords <- c("climate", "warming", "ipcc", "green house", "greenhouse")


## functions to automate collection of wikipedia articles --------

# search Wikipedia with search term
searchWikiFun <- function(term = NULL, limit = 100, title.only = TRUE, wordcount.min = 500, language = "en") {
  # API doc at https://www.mediawiki.org/wiki/API:Search
  term <- URLencode(term)
  url <- sprintf(paste0("https://", language, ".wikipedia.org/w/api.php?action=query&list=search&srsearch=%s&srlimit=%d&format=json"), term, limit)
  wiki_search_parsed <- jsonlite::fromJSON(url)$query$search
  wiki_search_parsed <- dplyr::filter(wiki_search_parsed, wordcount >= wordcount.min)
  if(title.only == FALSE) {
    return(wiki_search_parsed)
  } else{
    return(wiki_search_parsed$title)
  }
}

# search for categories and pages within these categories
searchWikiCatsFun <- function(pages = NULL, categories = NULL, language = "en", project = "wikipedia", limit = 100, output = c("pages", "cats"), subcats = FALSE, max.numcats = 5) {
  if(!is.null(pages)) {
  # search categories
  cats <- lapply(pages, function(x) { try(categories_in_page(language, project, pages = x, clean_response = TRUE, limit = limit)[[1]]$categories$title, silent = TRUE)   }) %>% unlist %>% table %>% sort(decreasing = TRUE) %>% extract(1:max.numcats) %>% names() %>%  unique %>% extract(str_detect(., "^Category")) %>% str_replace("Category:", "")
  # identify subcategories in categories
  if(subcats == TRUE){
  subcats <- lapply(cats, function(x) { try(pages_in_category(language, project, categories = x, type = "subcat", limit = limit, clean_response = TRUE)$title, silent = TRUE)   }) %>% unlist %>% unique
  subcats <- subcats[str_detect(subcats, "^Category")] %>% str_replace("Category:", "")
  # combine categories
  cats_all <- c(cats, subcats) %>% unique
  }else{
    cats_all <- cats
  }
  }else{
    cats_all <- categories
  }
  # find pages in all categories
  pages_in_cats <- lapply(cats_all, function(x) { try(pages_in_category(language, project, categories = x, type = "page", limit = limit, clean_response = TRUE)$title, silent = TRUE)   }) %>% unlist %>% unique
  # return output
  if(output == "pages") {
    return(pages_in_cats)
  }else{
    return(cats_all)
  }
}

# quick selection of pages with minimum recent daily pageviews
pagesMinPageviews <- function(pages = NULL, start = "2016090100", end = "2016093000", min.dailyviewsavg = 50, project = "en.wikipedia") {
  pageviews_list <- list()
  pageviews_mean <- numeric()
  for (i in seq_along(pages)) {
    pageviews_list[[i]] <- try(article_pageviews(project = project, article = URLencode(str_replace_all(pages[i], " ", "_")), start = start, end = end, reformat = TRUE))
    pageviews_mean[i] <- try(mean(pageviews_list[[i]]$views, na.rm = TRUE))
  }
  pageviews_mean_df <- data.frame(page = pages, pageviews_mean = as.numeric(pageviews_mean), stringsAsFactors = FALSE)
  pages_minviews <- dplyr::filter(pageviews_mean_df, pageviews_mean >= min.dailyviewsavg) %>% extract2("page")
  return(pages_minviews)
}
  
# download pageview statistics with wikipediatrend package
pageviewsDownload <- function(package = "pageviews", pages = NULL, folder = "~", from = "2008-01-01", to = "2013-12-31", language = "en") {
  pageviews_list <- list()
  pageviews_filenames_raw <- vector()
  for (i in seq_along(pages)) {
    filename_cleaned <- pages[i] %>% str_replace_all("_", "")  %>% str_replace_all("/", "-")
    filename <- paste0(filename_cleaned, ".csv")
    if (!file.exists(paste0(folder, filename))) {
      if(package == "wikipediatrend"){
        pageviews_list[[i]] <- try(wp_trend(URLencode(pages[i]), from = from, to = to, lang = language))
      }
      if(package == "pageviews"){
        pageviews_list[[i]] <- try(article_pageviews(project = paste0(language, ".wikipedia"), article = URLencode(str_replace_all(pages[i], " ", "_")), start = str_replace_all(paste0(from, "00"), "-", ""), end = str_replace_all(paste0(to, "00"), "-", ""), reformat = TRUE))
        
      }
      if(!(package %in% c("wikipediatrend", "pageviews"))){
        stop("Argument 'package' incorrectly specified.")
      }
      try(write.csv(pageviews_list[[i]], file = paste0(folder, filename), row.names = FALSE))
    }
    pageviews_filenames_raw[i] <- filename
  } 
}


## collect pages -------------------------------

## procedure
# search for pages using search term
# search for categories using pages
# collect pages for manually selected categories
# combine initially found pages and additional pages
# assess current mean daily pageviews
# select pages with >= 20 avg. views per day # maybe relax that function: either fairly high average views OR significant spike at least once. But the latter one would have to be over a longer period
# download page view statistics for articles 


## CLIMATE CHANGE
pages_search_list <- lapply(climate_keywords, searchWikiFun, limit = 100, wordcount.min = 500)
pages_search <- pages_search_list %>% unlist %>% unique()
cats_search <- searchWikiCatsFun(pages =  pages_search, output = "cats", subcats = TRUE, max.numcats = 20)
cats_subset <- str_subset(cats_search,regex(paste0(climate_keywords, collapse = "|"), ignore_case = TRUE))
save(cats_subset, file = "../data/case_study_climate_change/categories_climate.RData")
pages_cats_search <- searchWikiCatsFun(categories = cats_subset, output = "pages")
pages_cats_search <- str_subset(pages_cats_search, regex(paste0(climate_keywords, collapse = "|"), ignore_case = TRUE))
pagenames_climate <- pagesMinPageviews(pages = pages_cats_search, start = "2017010100", end = "2019010100", min.dailyviewsavg = 20) 
save(pagenames_climate, file = "../data/case_study_climate_change/pagenames_climate.RData")
pageviewsDownload(pages = pagenames_climate, folder = "../data/case_study_climate_change/pageviews/", from = "2016-01-01", to = "2019-01-01", language = "en", package = "pageviews")



