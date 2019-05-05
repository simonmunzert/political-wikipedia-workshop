### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")


## on Wikipedia page views ---------------------------------

# interactive tool available at
browseURL("https://tools.wmflabs.org/pageviews/")

# Wikimedia REST API
browseURL("https://wikimedia.org/api/rest_v1/#/Pageviews%20data")

# old page view dumps (until August 2016)
browseURL("https://dumps.wikimedia.org/other/pagecounts-raw/")

# new page view dumps (from May 2015)
browseURL("https://dumps.wikimedia.org/other/pageviews/")

# even more info adding to the mess
browseURL("https://dumps.wikimedia.org/other/pagecounts-ez/")
  

## the pageviews package ---------------------------

# no data available prior to July 2015!

# functionality
ls("package:pageviews")

# get pageviews
trump_views <- article_pageviews(project = "en.wikipedia", article = "Donald Trump", user_type = "user", start = "2015070100", end = "2017050100")
head(trump_views)
clinton_views <- article_pageviews(project = "en.wikipedia", article = "Hillary Clinton", user_type = "user", start = "2015070100", end = "2017050100")

plot(ymd(trump_views$date), trump_views$views, col = "red", type = "l")
lines(ymd(clinton_views$date), clinton_views$views, col = "blue")


## the wikipediatrend package ---------------------------

# get the latest development version from GitHub
# devtools::install_github("petermeissner/wikipediatrend")

# no data available prior to December 2007!

ls("package:wikipediatrend")

trend_data <- 
  wp_trend(
    page = c("Der_Spiegel", "Die_Zeit"), 
    lang = c("de"), 
    from = "2007-01-01",
    to   = Sys.Date()
  )

zeit <- filter(trend_data, article == "die_zeit")
spiegel <-  filter(trend_data, article == "der_spiegel")
plot(ymd(zeit$date), zeit$views, col = "red", type = "l")
lines(ymd(spiegel$date), spiegel$views, col = "blue")

wp_linked_pages("Angela Merkel", "de")




## examples ---------------------------

# get pageviews on "Elster" article
dat <- wp_trend(page = "Elster", lang = "de", from = "2007-01-01", to = Sys.Date())
dat <- filter(dat, dat$views != 0, dat$views < 4000) 

# plot
par(oma=c(0,0,0,0))
par(mar=c(0,4,0,.5))
# page views time series
par(mar=c(2,4,1,.5))
plot(ymd(dat$date), dat$views, type = "l", xlab = "", ylab = "Page views", col = "white")
abline(h = seq(0, max(dat$views), 500), col = "lightgrey")
abline(v = ymd(paste0(2008:2019, "-05-31")), col = "red", lty = 2)

lines(ymd(dat$date), dat$views, lwd = .5)


