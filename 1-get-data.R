options(stringsAsFactors=FALSE)

## load the packages
library(RNeo4j)
library(rvest)
library(dplyr)

## connect to Neo4j
graph = startGraph("http://localhost:7474/db/data/",
                   username = "neo4j",
                   password = "password")

## clear out the graph
clear(graph, input = FALSE)

############################################################## parse out the songs

## get the song page
URL = "http://pearljam.com/music"
song_page = URL %>% read_html()

## parse out the pieces of information, could parse first/last and # of plays
song_names = song_page %>% html_nodes(".music_songs td:nth-child(1) a") %>% html_text()
song_links = song_page %>% html_nodes(".music_songs td:nth-child(1) a") %>% html_attr("href")
song_type = song_page %>% html_nodes(".music_songs td:nth-child(2)") %>% html_text()
song_release = song_page %>% html_nodes("td:nth-child(6) a") %>% html_text()

## put into a dataframe
songs = data.frame(link = song_links, 
                   name = song_names,
                   type = song_type,
                   release = song_release)

## add the constraint for the song link
addConstraint(graph, "Song", "link")

## put into a list
song_list <- setNames(split(songs, seq(nrow(songs))), rownames(songs))

## iterate over list and throw into neo4j
lapply(song_list, function(x) createNode(graph, "Song", x))

############################################################## pull out list of all shows

## URL
URL = "http://www.pearljam.com/setlists"
show_links = URL %>% read_html()

## pull out the show years
year_links = show_links %>% html_nodes("#sub_sub_nav a") %>% html_attr("href")

## STARTER CODE:  pull out the show links
URL = year_links[1]
show_pages = URL %>% read_html()
show_page_link = show_pages %>% html_nodes("#slider_showdates a") %>% html_attr("href")
show_page_name = show_pages %>% html_nodes("#slider_showdates a") %>% html_text()

## TODO:  parse out location and date from the show_page_name
## TODO:  loop all years and get show pages and parse

