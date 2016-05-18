# About

Crawl song and setlist data from pearl jam's website, model and throw the data into `Neo4j`, and see if it's possible to fit a model that will predict the songs played a given show.  Ideal would be to predict order, but given the variation from show to show, what sort of modeling is possible?

## Metric

Simple.  Just the % of songs correct, but will need to think about the fact that each show may have a different number of songs played.

## Resources

[songs](http://pearljam.com/music)
[setlists](http://www.pearljam.com/setlists)

## Process

1.  Crawl the data from R into Neo4j  
2.  Ask questions  
3.  Use graphlab to fit a model

## Status

-  The crawler works as of May 2016, and import into Neo4j
-  The data model could be expanded to blow out venues, dates, etc.