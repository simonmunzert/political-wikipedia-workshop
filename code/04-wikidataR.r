### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------

## peparations -------------------

source("packages.r")


## on Wikidata ---------------------------------

# a free and open knowledge base
# "Wikipedias database" with over 56 million entries (May 2019)
# everyone can add and edit data
# no dedicated language editions, but individual entries can have values in different languages
# Wikidata can help you answer questions such as
  # What is the capital city of every member of the European Union and how many inhabitants live there?
  # How many states a particular US state borders?
  # Which airports are within 100km of Berlin?
# database can be queried interactively at
browseURL("https://query.wikidata.org/")
# Wikidata can be queried using SPARQL, a query language for data stored in the Resource Description Framework (RDF) format
# data is not stored in relational databases (-> SQL), so items are not part of tables
# instead, they are linked with each other like a graph or network

# brief intro to Wikidata
browseURL("https://towardsdatascience.com/a-brief-introduction-to-wikidata-bb4e66395eb1?gi=dc5c39831b5e")

# more info about data access / the API
browseURL("https://www.wikidata.org/wiki/Wikidata:Data_access")


## how Wikidata works --------------------------

# fundamental logic:
  # basic objects are stored as items with a unique item number, starting with "Q". 
    # examples: 
      # Douglas Adams --> Q42
      browseURL("https://www.wikidata.org/wiki/Q42")
      # United States House of Representatives --> Q11701
      
  # objects are described using statements, which detail certain properties, starting with "P"
    # examples: 
      # "educated at" --> P69
      browseURL("https://www.wikidata.org/wiki/Property:P69")
      # "official website" --> P856
      # "number of seats" --> P1342

  # properties themselves have values, which are again items
    # examples: 
      # "St. John's College" --> Q691283

# access to data on WikiData:
  # via WikiData API (see later)
  # via SPARQL query interface at
browseURL("https://query.wikidata.org/")
  # via Reasonator (slightly more comfortable view on the data)
browseURL("https://tools.wmflabs.org/reasonator/?q=Q42")


## primer to the WikidataR package ----------------------------

# The WikidataR package
browseURL("https://cran.r-project.org/web/packages/WikidataR/vignettes/Introduction.html")

# functionality
ls("package:WikidataR")

# find item
wd_item <- find_item("Brandenburger Tor", language = "en")
wd_item
str(wd_item)
wd_item[[1]]$id
browseURL("https://www.wikidata.org/wiki/Q82425")

# get item based on item id
tor_item <- get_item("82425")
str(tor_item)

# extract claims ("properties") for particular items
country_property <- find_property("Country", language = "en")
country_property[[1]] %>% as.data.frame

tor_country <- extract_claims(tor_item, "P17")
tor_country[[1]][[1]]$mainsnak$datavalue$value$id
get_item("Q183")
get_item("Q1206012")


### run SPARQL queries  ----------------------------

# recommendation: build SPARQL query first, manually download data, then import into R
# example: data/wikidata/wikidata-sparql-query-us-politicians.txt
# run on https://query.wikidata.org/
# store results as "../data/wikidataQueryPoliticiansUSA.csv"