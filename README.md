# Pearl Jam Setlists

The first time I saw Pearl Jam live was on September 16th, 1998, and they opened with my favorite song, `Release`. It was the perfect opening song, and ever since, I always hope they will open with it every time I get a chance to see them live.  With them coming to Fenway Park on August 5th, I find myself wondering about the chances of the song being played first.  Instead of guessing, why not scrape data available on the interwebs and look at the patterns?

This repo scrapes information about Pearl Jam concerts, including the setlists for those shows, and puts the data into `Neo4j` using `R`.  As of July 31, 2016, the code works

## Requirements

1.  `R`  
2.  Neo4j.  This post uses version `3.0.2 Community Edition`

## Cypher queries 

After grabbing the data, we can answer some cool questions.  First, let's check to see how things look.  What are the last 5 shows they have played (as of July 31st, 2016).

```
MATCH (song:Song)-[p:PLAYED_AT]->(show:Show {year:'2016'})
WITH show.date as date, p
RETURN date, COUNT(p) as songs_played
ORDER BY date DESC
LIMIT 5
```

returns

```
╒══════════╤════════════╕
│date      │songs_played│
╞══════════╪════════════╡
│07-17-2016│27          │
├──────────┼────────────┤
│07-09-2016│30          │
├──────────┼────────────┤
│06-11-2016│22          │
├──────────┼────────────┤
│06-09-2016│11          │
├──────────┼────────────┤
│05-12-2016│32          │
└──────────┴────────────┘
```

