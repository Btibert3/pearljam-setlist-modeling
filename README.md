# Pearl Jam Setlists

The first time I saw Pearl Jam live was on September 16th, 1998, and they opened with my favorite song, `Release`. It was the perfect opening song, and ever since, I always hope they will open with it every time I get a chance to see them live.  With them coming to Fenway Park on August 5th, I find myself wondering about the chances of the song being played first.  Instead of guessing, why not scrape data available on the interwebs and look at the patterns?

This repo scrapes information about Pearl Jam concerts, including the setlists for those shows, and puts the data into `Neo4j` using `R`.  As of July 31, 2016, the code works

## Requirements

1.  `R`  
2.  Neo4j.  This post uses version `3.0.2 Community Edition`

## Cypher queries 

After grabbing the data, we can answer some cool questions.  First, let's check to see how things look.  What are the last 5 shows they have played in 2016 (as of July 31st, 2016).

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

How many songs are they playing, on average, for the 2016 shows?

```
MATCH (song:Song)-[p:PLAYED_AT]->(show:Show {year:'2016'})
WITH show.date as date, COUNT(p) as plays
RETURN AVG(plays) as songs_played
```
tells us that they are playing just above 30 songs per show.

Because I am hoping that they open with `Release`, let's identify all of the shows where they opened with the song.

```
MATCH (song:Song)-[p:PLAYED_AT]->(show:Show {year:'2016'})
WHERE p.rank = '1' AND song.name = 'Release'
WITH song.name as song, show.date as date, show.show_name as name
RETURN date, name,  song
ORDER BY date DESC
```
which returns

```
╒══════════╤════════════════════════╤═══════╕
│date      │name                    │song   │
╞══════════╪════════════════════════╪═══════╡
│07-17-2016│Pemberton, BC 07-17-2016│Release│
└──────────┴────────────────────────┴───────┘
```

Unfortatenelyl for me, they have only opened with the song once, and it was at their last show.  Yikes.

For sake of argument, which songs are being played the most as the opening song?

```
MATCH (song:Song)-[p:PLAYED_AT]->(show:Show {year:'2016'})
WHERE p.rank = '1'
WITH song.name as song, COUNT(*) as plays
RETURN song, plays
ORDER BY plays DESC
LIMIT 10
```

returns

```
╒══════════════════════════════╤═════╕
│song                          │plays│
╞══════════════════════════════╪═════╡
│Corduroy                      │3    │
├──────────────────────────────┼─────┤
│Go                            │3    │
├──────────────────────────────┼─────┤
│Why Go                        │3    │
├──────────────────────────────┼─────┤
│Lightning Bolt                │2    │
├──────────────────────────────┼─────┤
│Elderly Woman Behind The Count│1    │
│er In A Small Town            │     │
├──────────────────────────────┼─────┤
│Porch                         │1    │
├──────────────────────────────┼─────┤
│Nothingman                    │1    │
├──────────────────────────────┼─────┤
│State Of Love And Trust       │1    │
├──────────────────────────────┼─────┤
│Once                          │1    │
├──────────────────────────────┼─────┤
│Of The Girl                   │1    │
├──────────────────────────────┼─────┤
│Release                       │1    │
├──────────────────────────────┼─────┤
│Interstellar Overdrive        │1    │
├──────────────────────────────┼─────┤
│Oceans                        │1    │
├──────────────────────────────┼─────┤
│Rearviewmirror                │1    │
└──────────────────────────────┴─────┘
```

As a band that prides itself on creating setlists on a show-by-show basis, the diverity in the opening songs makes sense, although there are a few that they have opened with more than once.  
