# Studying politics on and with Wikipedia

## General information

**Summary**

The online encyclopedia Wikipedia, together with its sibling, the collaboratively edited knowledge base Wikidata, provide incredibly rich yet largely untapped sources for political research. In this hands-on workshop, I will show how these platforms can inform research on public attention dynamics, policies, political and other events, political elites, and parties, among other things. To that end, we will work with the packages `WikipediR`, `WikidataR`, `pageviews`, and `wikipediatrend` to connect with APIs from the Wikimedia foundation and efficiently access and parse content. Furthermore, I will provide an overview of the `legislatoR` package, a fully relational individual-level data package that comprises political, sociodemographic, and Wikipedia-related data on elected politicians across the globe. Please bring your laptops with a current version of R installed!

**Event**

Social Science Data Lab, MZES Mannheim

**Date and Venue**

Monday, May 6, 2019, MZES A Building, Room A-231

**Instructor** 

Simon Munzert ([website](https://simonmunzert.github.io), [Twitter](https://twitter.com/simonsaysnothin))

**Requirements**

Working knowledge of R is a necessary prerequisite. You're assumed to be familiar with base R as well as the tidyverse. 

Are you prepared for taking this course? Take a look at the basic R vocabulary listed [here](http://adv-r.had.co.nz/Vocabulary.html). Are you aware of at least 60% to 80% of the functions? Then you're prepared. 

**Technical setup**

Please make sure that the current version of R is installed. If not, update from here: [https://cran.r-project.org/](https://cran.r-project.org/)

Obviously, feel free to choose the coding environment you feel most comfortable with. I'll use RStudio in the course. You might want to use it, too: [https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/)

We are going to need a couple of packages from CRAN: You can install them all by running the R source file `packages.r` which you can find in the code folder.

## Online resources

| Topic | URL | Short description |
|---------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| APIs | [https://wikimedia.org/api/rest_v1/](https://wikimedia.org/api/rest_v1/) | **Wikimedia REST API** -- Access to data on pageviews, editors, edits counts, bytes difference, and more   |
| | [https://www.mediawiki.org/wiki/API:Main_page](https://www.mediawiki.org/wiki/API:Main_page) | **Wikimedia Action API** -- Interact with the Wikipedia, i.e. login, post changes, etc.   |
| | [https://www.wikidata.org/wiki/Wikidata:Data_access](https://www.wikidata.org/wiki/Wikidata:Data_access) | **Wikidata API** -- Interact with Wikidata   |
| Data dumps | [https://dumps.wikimedia.org/other/pagecounts-ez/](https://dumps.wikimedia.org/other/pagecounts-ez/) | **Pageviews dumps** -- general info |
|  | [https://dumps.wikimedia.org/other/pagecounts-raw/](https://dumps.wikimedia.org/other/pagecounts-raw/) | **Pageviews dumps** -- old, until August 2016 |
|  | [https://dumps.wikimedia.org/other/pageviews/)](https://dumps.wikimedia.org/other/pageviews/) | **Pageviews dumps** -- new, from May 2015 |
|  | [https://dumps.wikimedia.org/other/clickstream/](https://dumps.wikimedia.org/other/clickstream/) | **Clickstream dumps** -- from November 2017 |
| R packages | [https://cran.rstudio.com/web/packages/pageviews/index.html](https://cran.rstudio.com/web/packages/pageviews/index.html) | `pageviews` -- access to pageviews data (from July 2015) |
|  | [https://cran.rstudio.com/web/packages/wikipediatrend/index.html](https://cran.rstudio.com/web/packages/wikipediatrend/index.html) | `wikipediatrend` -- access to pageviews data (from February 2007); be sure to [check out latest GitHub version](https://github.com/petermeissner/wikipediatrend)! |
|  | [https://cran.r-project.org/web/packages/WikipediR/index.html](https://cran.r-project.org/web/packages/WikipediR/index.html) | `WikipediR` -- access to Wikipedia article content data via the MediaWiki API |
|  | [https://cran.r-project.org/web/packages/WikidataR/index.html](https://cran.r-project.org/web/packages/WikidataR/index.html) | `WikidataR ` -- access to Wikidata content |
| Other | [https://tools.wmflabs.org/pageviews/](https://tools.wmflabs.org/pageviews/) | Interactive tool to explore page views data |
| | [https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream](https://meta.wikimedia.org/wiki/Research:Wikipedia_clickstream) | General information about clickstream data |
| | [https://towardsdatascience.com/a-brief-introduction-to-wikidata-bb4e66395eb1?gi=dc5c39831b5e](https://towardsdatascience.com/a-brief-introduction-to-wikidata-bb4e66395eb1?gi=dc5c39831b5e) | Short Wikidata tutorial by Björn Hartmann |
| | [https://query.wikidata.org/](https://query.wikidata.org/) | SPARQL query interface to Wikidata |
| | [https://tools.wmflabs.org/reasonator/](https://tools.wmflabs.org/reasonator/) | Reasonator, offering visually more appealing access to Wikidata |



