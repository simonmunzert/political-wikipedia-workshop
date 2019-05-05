### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")


## on Wikipedia clickstream data ------------------------

# general information at
browseURL("https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream")

# raw data (huge!) at
browseURL("https://dumps.wikimedia.org/other/clickstream/")

# clickstream data currently available in:
c("English", "German", "Spanish", "Farsi", "French", "Italian", "Japanese", "Polish", "Portugese", "Russian", "Chinese")


## import clickstream data ----------------------------

# get raw data (not shown, file too big)
dat <- read.table("../data/clickstream/clickstream-enwiki-2018-12.tsv", header = FALSE, col.names = c("prev", "curr", "type", "n"), fill = TRUE, stringsAsFactors = FALSE)
dat$n <- as.integer(dat$n)

# export to compressed RDa (not shown)
saveRDS(dat, file = "../data/clickstream/clickstream-enwiki-2018-12.RDa")

# filter data
dat <- readRDS("../data/clickstream/clickstream-enwiki-2018-12.RDa")
dat_sub <- filter(dat, str_detect(prev, regex("global_warming", ignore_case = TRUE)) |
                    str_detect(curr, regex("global_warming", ignore_case = TRUE)))
View(dat_sub)



## work with clickstream data ------------------

# import clickstream subset from the English Wikipedia (focus on health and climate change articles)
cs_df <- readRDS("../data/clickstream/clickstream_subset.RDa")
head(cs_df)
cs_df$date <- as.Date(paste0(as.character(cs_df$time), "-01"))
cs_df <- filter(cs_df, year(date) == 2018)

# import page names
load("../data/clickstream/pagenames_health_climate.RData")

# focus on links between health and climate change articles
cs_health_climate_df <- filter(cs_df, 
                               (prev %in% c(pagenames_climate_full) & curr %in% c(pagenames_health_full)) |
                                 (prev %in% c(pagenames_health_full) & curr %in% c(pagenames_climate_full))  )
cs_health_climate_df$health_to_climate <- cs_health_climate_df$prev %in% pagenames_health_full

# summarize data
cs_health_climate_df_sum <- 
  cs_health_climate_df %>% 
  group_by(time) %>%
  summarize(n_views = sum(n),
            n_views_health_to_climate = sum(n[health_to_climate == TRUE]),
            n_views_climate_to_health = sum(n[health_to_climate == FALSE]))
cs_health_climate_df_sum$date <- as.Date(paste0(as.character(cs_health_climate_df_sum$time), "-01"))
cs_health_climate_df_sum$date_num <- as.numeric(cs_health_climate_df_sum$date)
cs_health_climate_df_sum <- filter(cs_health_climate_df_sum, year(date) == 2018 )

# plot data
p <- ggplot(cs_health_climate_df_sum, aes(y = n_views, x = date)) +
  geom_line(color = "#00AFBB", size = 1) + 
  geom_vline(xintercept = cs_health_climate_df_sum$date_num, col = "darkgrey") + 
  scale_x_date(breaks = "1 months", date_labels = "%b") + 
  scale_y_continuous(limits = c(0, max(cs_health_climate_df_sum$n_views) + 20)) + 
  xlab("2018") + ylab("Monthly co-views") + 
  theme(panel.grid.minor.y =   element_blank(),
        panel.grid.minor.x =   element_blank(),
        panel.grid.major.x =   element_line(colour = "darkgrey",size=.5),
        panel.grid.major.y =   element_line(colour = "darkgrey",size=.5),
        plot.margin=unit(c(.2,.2,.2,.2),"cm")) + 
  geom_line(color = "#00AFBB", size = 1) + 
  geom_line(data = cs_health_climate_df_sum, aes(y = n_views_health_to_climate, x = date), color = "red", size = 1) + 
  geom_line(data = cs_health_climate_df_sum, aes(y = n_views_climate_to_health, x = date), color = "blue", size = 1) + 
  annotate("text", x = cs_health_climate_df_sum$date[11] + days(15), y = cs_health_climate_df_sum$n_views[12] + 20, label = "health %<->% climate", size = 3, color = "#00AFBB", parse = TRUE) +
  annotate("text", x = cs_health_climate_df_sum$date[11] + days(15), y = cs_health_climate_df_sum$n_views_health_to_climate[12] + 50, label = "health %->% climate", size = 3, color = "red", parse = TRUE) +
  annotate("text", x = cs_health_climate_df_sum$date[11] + days(15), y = cs_health_climate_df_sum$n_views_climate_to_health[12] + 20, label = "climate %->% health", size = 3, color = "blue", parse = TRUE)
p


## plot network graph ------------------

# load data
cs_health_climate_df <- filter(cs_df, 
                               (prev %in% c(pagenames_climate_full) & curr %in% c(pagenames_health_full)) |
                                 (prev %in% c(pagenames_health_full) & curr %in% c(pagenames_climate_full)) |
                                 (prev %in% c(pagenames_health_full) & curr %in% c(pagenames_health_full)) |
                                 (prev %in% c(pagenames_climate_full) & curr %in% c(pagenames_climate_full)) 
)  


# construct edges
cs_health_climate_df_edge <- 
  cs_health_climate_df %>% 
  filter(year(date) == 2018) %>%
  group_by(prev, curr, year(date), health, climate) %>%
  dplyr::summarise(weight=sum(n)) %>%
  arrange(curr)

# get list of unique articles to construct as nodes 
cs_health_climate_df_node <- 
  gather(cs_health_climate_df_edge, `prev`, `curr`, key="where", value="article") %>%
  distinct(article)
cs_health_climate_df_node <- cs_health_climate_df_node$article
cs_health_climate_df_node <- data.frame(cs_health_climate_df_node) %>%
  distinct(cs_health_climate_df_node)
names(cs_health_climate_df_node)[names(cs_health_climate_df_node) == "cs_health_climate_df_node"] <- "node"
cs_health_climate_df_node$category <- NA

## categorise nodes as either climate or health articles
cs_health_climate_df_node$category[cs_health_climate_df_node$node %in% pagenames_climate_full] <- "climate"
cs_health_climate_df_node$category[cs_health_climate_df_node$node %in% pagenames_health_full] <- "health"

# minimum 3 links
tab_freq <- table(c(cs_health_climate_df_edge$prev, cs_health_climate_df_edge$curr)) %>% as.data.frame()
tab_freq <- filter(tab_freq, Freq >=3)

cs_health_climate_df_node_ss <- cs_health_climate_df_node[cs_health_climate_df_node$node %in% tab_freq$Var1, ]
cs_health_climate_df_edge_ss <- cs_health_climate_df_edge[cs_health_climate_df_edge$prev %in% tab_freq$Var1 & cs_health_climate_df_edge$curr %in% tab_freq$Var1, ]

# generate graph
set.seed(3)
cs_net <- graph_from_data_frame(cs_health_climate_df_edge_ss, vertices = cs_health_climate_df_node_ss, directed=F) 
cs_net <- igraph::simplify(cs_net, remove.multiple = T, remove.loops = T) 

# generate colors based on category
colrs <- brewer.pal(3, "Set1") 
V(cs_net)$color <- colrs[as.numeric(as.factor(V(cs_net)$category))]

# compute node degrees (#links) and use that to set node size
deg <- degree(cs_net, mode="all")
V(cs_net)$size <- deg/10

# set labels
V(cs_net)$label <- NA
V(cs_net)$label.cex = 0.5
V(cs_net)$label = ifelse(degree(cs_net) >5, V(cs_net)$label, NA)
cs_hc_labels <- as.vector(cs_health_climate_df_node$node)

# set edge width based on weight
E(cs_net)$width <- log(E(cs_net)$weight)/5
E(cs_net)$edge.color <- "gray80"

# plot
plot(cs_net, vertex.label = ifelse(V(cs_net)$name %in% cs_hc_labels_ss, V(cs_net)$name, NA), layout=layout_with_fr) 








