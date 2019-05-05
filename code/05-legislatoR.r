### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")

## overview of legislatoR package ---------------------------------

# GitHub page
browseURL("https://github.com/saschagobel/legislatoR")

# Installation
devtools::install_github("saschagobel/legislatoR")
library(legislatoR)

# call help file for legislatoR package to get an overview of the function calls
?legislatoR

# call help file for the 'History' dataset 
?get_history


## primer to the legislatoR package ----------------------------

# functionality
ls("package:legislatoR")
?get_core

# assign entire Core dataset for the German Bundestag into the environment
deu_politicians <- get_core(legislature = "deu")

# assign only data for the 8th legislative session into the environment
deu_politicians_subset <- semi_join(x = get_core(legislature = "deu"),
                                    y = filter(get_political(legislature = "deu"), session == 8), 
                                    by = "pageid")

# join deu_politicians_subset with respective History dataset
deu_history <- left_join(x = deu_politicians_subset, 
                         y = get_history(legislature = "deu"), 
                         by = "pageid")

# assign only birthdate for members of the political party 'SPD' into the environment
deu_birthdates_SPD <- semi_join(x = select(get_core(legislature = "deu"), pageid, birth),
                                y = filter(get_political(legislature = "deu"), party == "SPD"),
                                by = "pageid")$birth



## Get social media adoption rates --------------------------

# get data: Germany
dat_ger <- right_join(x = get_core(legislature = "deu"),
                      y = filter(get_political(legislature = "deu"), as.numeric(session) == max(as.numeric(session))), 
                      by = "pageid")
dat_ger <- left_join(x = dat_ger,
                     y = get_social(legislature = "deu"), 
                     by = "wikidataid")
dat_ger$legislature <- "Germany"
dat_ger_sum <- dat_ger %>% 
  dplyr::summarize(twitter = mean(not(is.na(twitter)), na.rm = TRUE), 
                   facebook = mean(not(is.na(facebook)), na.rm = TRUE), 
                   website = mean(not(is.na(website)), na.rm = TRUE), 
                   session_start = ymd(first(session_start)), 
                   session_end = ymd(first(session_end)),
                   legislature = first(legislature))


## Visualize gender balance across parliaments -----------------------------

# get data: Germany
dat_ger <- right_join(x = get_core(legislature = "deu"),
                      y = get_political(legislature = "deu"), 
                      by = "pageid")
dat_ger$legislature <- "Germany"
dat_ger_sessions <- group_by(dat_ger, session) %>% 
  mutate(female = (sex == "female")) %>% 
  summarize(female_ratio = mean(female, na.rm = TRUE), 
            session_start = ymd(first(session_start)), 
            session_end = ymd(first(session_end)),
            legislature = first(legislature))
dat_ger_sessions <- arrange(dat_ger_sessions, as.numeric(session))

# get data: Austria
dat_aut <- right_join(x = get_core(legislature = "aut"),
                      y = get_political(legislature = "aut"), 
                      by = "pageid")
dat_aut$legislature <- "Austria"
dat_aut_sessions <- group_by(dat_aut, session) %>% 
  mutate(female = (sex == "female")) %>% 
  summarize(female_ratio = mean(female, na.rm = TRUE), 
            session_start = ymd(first(session_start)), 
            session_end = ymd(first(session_end)),
            legislature = first(legislature))
dat_aut_sessions <- arrange(dat_aut_sessions, as.numeric(session))

# get data: US House
dat_usah <- right_join(x = get_core(legislature = "usa_house"),
                       y = get_political(legislature = "usa_house"), 
                       by = "pageid")
dat_usah$legislature <- "United States House"
dat_usah_sessions <- group_by(dat_usah, session) %>% 
  mutate(female = (sex == "female")) %>% 
  summarize(female_ratio = mean(female, na.rm = TRUE), 
            session_start = ymd(first(session_start)), 
            session_end = ymd(first(session_end)),
            legislature = first(legislature))
dat_usah_sessions <- arrange(dat_usah_sessions, as.numeric(session))
dat_usah_sessions$legislature <- "US House"

# get data: US Senate
dat_usas <- right_join(x = get_core(legislature = "usa_senate"),
                       y = get_political(legislature = "usa_senate"), 
                       by = "pageid")
dat_usas$legislature <- "United States Senate"
dat_usas_sessions <- group_by(dat_usas, session) %>% 
  mutate(female = (sex == "female")) %>% 
  summarize(female_ratio = mean(female, na.rm = TRUE), 
            session_start = ymd(first(session_start)), 
            session_end = ymd(first(session_end)),
            legislature = first(legislature))
dat_usas_sessions <- arrange(dat_usas_sessions, as.numeric(session))
dat_usas_sessions$legislature <- "US Senate"


# combine data frames
dat_list <- list(dat_ger_sessions,
                 dat_aut_sessions,
                 dat_usah_sessions,
                 dat_usas_sessions)
col_countries <- sequential_hcl(length(dat_list), palette = "Viridis")

# plot
par(oma=c(0,0,.5,0))
par(mar=c(0,4,0,.5))
par(yaxs="i", xaxs="i", bty="n")
# page views time series
par(mar=c(2,4,0,.5))
# set up plot
country_labels_pos_data <- lapply(dat_list, '[', "female_ratio") %>% lapply(unlist) %>% lapply(last) %>% unlist
country_labels_pos_data_matched <- country_labels_pos_data + .015
# plot
plot(ymd(dat_list[[1]]$session_start), dat_list[[1]]$female_ratio, type = "o", ylim= yscale, xlim = c(ymd("1900-01-01"), ymd("2030-01-01")),  xaxt = "n", yaxt = "n", xlab = "", ylab = "Share of women in parliament", col = "white")
hlines <- seq(0.1, 1, .1)
# horizontal lines
for(i in 1:length(hlines)) {
  segments(x0 = ymd("1900-01-01"), x1 = ymd("2020-01-01"), y0 = hlines[i], col = "lightgrey")
}
# draw data
for(i in seq_along(dat_list)) {
  lines(ymd(dat_list[[i]]$session_start), dat_list[[i]]$female_ratio, type = "o", lwd = 1, col = col_countries[i], pch = 19, cex = .3)
}
# make axes
dates <- seq(ymd("1900-01-01"), ymd("2020-01-01"), by = 1)
dates <- dates[day(dates) == 1 & month(dates) == 1 & year(dates) %in% seq(1900,2020, 20)]
axis(1, dates, lwd = 1, lwd.ticks = 1, labels = year(dates))
# axis(1, dates, labels = as.character(dates), tick = F, lwd = 0)
axis(2, seq(0, 1, .1), labels = paste0(seq(0, 1, .1)*100, "%"), las = 2)
# add country labels
for(i in seq_along(dat_list)) {
  text(ymd("2016-01-01"), country_labels_pos_data_matched[i], dat_list[[i]]$legislature, cex = .8, pos = 4, col = col_countries[i]) 
}



## Visualize average pageviews data of German MPs -----------------------------

# get data
ger_traffic <- right_join(x = get_traffic(legislature = "deu"),
                          y = filter(get_political(legislature = "deu"), session_end >= as.Date("2015-07-01")), 
                          by = "pageid")
ger_traffic <- left_join(x = ger_traffic,
                         y = get_core(legislature = "deu"),
                         by = "pageid")
ger_traffic <- dplyr::select(ger_traffic, pageid, date, traffic, session, party, name)

# aggregate data
ger_traffic$date <- ymd(ger_traffic$date)
ger_traffic_date <- group_by(ger_traffic, date)
ger_traffic_legislators <- group_by(ger_traffic, pageid)
ger_traffic_sum <- summarize(ger_traffic_date, mean = mean(traffic, na.rm = TRUE))
ger_traffic_sum <- mutate(ger_traffic_sum, 
                          mean_l1 = lag(mean, 1), 
                          mean_f1 = lead(mean, 1),
                          peak = (mean >= 1.8*mean_l1 & mean > 180))

# identify peaks
ger_traffic_peaks <- filter(ger_traffic_sum, peak == TRUE)
ger_traffic_peaks_df <- filter(ger_traffic, date %in% ger_traffic_peaks$date)
ger_traffic_peaks_group <- group_by(ger_traffic_peaks_df, date) %>% dplyr::arrange(desc(traffic)) %>% filter(row_number()==1)
ger_traffic_peaks_group <- arrange(ger_traffic_peaks_group, date)
events_vec <- c("deceased", "drug affair", "bullying affair", "candidacy for presidency", "deceased", "???", "chancellorchip announcement", "elected president", "???", "policy success", "TV debate", "general election", "threat to resign", "elected speaker of parliament")

# plot
par(oma=c(0,0,0,0))
par(mar=c(0,4,0,.5))
par(yaxs="i", xaxs="i", bty="n")
layout(matrix(c(1,1,3,2,2,3), 2, 3, byrow = TRUE), heights = c(1,2,3), widths = c(5, 5, 1.8))
# names labels
plot(ymd(ger_traffic_sum$date), rep(0, length(ger_traffic_sum$date)), xlim = c(ymd("2015-07-01"), ymd("2018-01-01")), xaxt = "n", ylim = c(0, 10), yaxt = "n", xlab = "", ylab = "", cex = 0)
text(ger_traffic_peaks_group$date, 0, ger_traffic_peaks_group$name, cex = .75, srt = 90, adj = c(0, 0))
# page views time series
par(mar=c(2,4,0,.5))
plot(ymd(ger_traffic_sum$date), ger_traffic_sum$mean, type = "l", ylim= c(0, 1.25*max(ger_traffic_sum$mean)), xlim = c(ymd("2015-07-01"), ymd("2018-01-01")),  xaxt = "n", yaxt = "n", xlab = "", ylab = "mean(page views)", col = "white")
#abline(v = dates[day(dates) == 1 & month(dates) %in% c(1)], col = "lightgrey")
abline(h = seq(0, 1.5*max(ger_traffic_sum$mean), 250), col = "lightgrey")
lines(ymd(ger_traffic_sum$date), ger_traffic_sum$mean, lwd = .5)
dates <- seq(ymd("2015-07-01"), ymd("2018-01-01"), by = 1)
axis(1, dates[day(dates) == 1 & month(dates) %in% c(1,4,7,10)], labels = FALSE)
axis(1, dates[day(dates) == 1 & month(dates) %in% c(1)], lwd = 0, lwd.ticks = 3, labels = FALSE)
axis(1, dates[day(dates) == 1 & month(dates) %in% c(7)], labels = as.character(year(dates[day(dates) == 15 & month(dates) %in% c(7)])), tick = F, lwd = 0)
axis(2, seq(0, 1.5*max(ger_traffic_sum$mean), 250), las = 2)
# events labels in time series
for(i in seq_along(events_vec)) {
  text(ger_traffic_peaks_group$date[i], ger_traffic_sum$mean[ger_traffic_sum$peak == TRUE][i] + 80, i, cex = .8) 
  points(ger_traffic_peaks_group$date[i], ger_traffic_sum$mean[ger_traffic_sum$peak == TRUE][i] + 80, pch=1, cex = 2.2)  
}
# election date
# abline(v = ymd("2017-09-24"), lty = 2, col = "darkgrey")
# events labels explained
par(mar=c(0,0,0,0))
plot(0, 0, xlim = c(0, 5), ylim = c(0, 10), xaxt = "n", yaxt = "n", xlab = "", ylab = "", cex = 0)
positions <- data.frame(events_xpos = 0.45, events_ypos = seq(8.5, (8.5 - .5*length(events_vec)), -.5), text_xpos = .5)
text(0, 9, "Events", pos = 4, cex = .75)
for(i in seq_along(events_vec)) {
  text(positions$events_xpos[i], positions$events_ypos[i], i, cex = .8) 
  points(positions$events_xpos[i], positions$events_ypos[i], pch = 1, cex = 2.2)
  text(positions$text_xpos[i], positions$events_ypos[i], events_vec[i], pos = 4, cex = .75)
}
