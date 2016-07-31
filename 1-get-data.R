options(stringsAsFactors=FALSE)

## load the packages
library(rvest)
library(dplyr)
library(stringr)
library(uuid)
library(readr)


############################################################## parse out the songs

## get the song page
URL = "http://pearljam.com/music"
song_page = URL %>% read_html()

## parse out the pieces of information, could parse first/last and # of plays
song_names = song_page %>% 
  html_nodes(".music_songs td:nth-child(1) a") %>% 
  html_text() %>% 
  str_trim(side = "both")
song_links = song_page %>% 
  html_nodes(".music_songs td:nth-child(1) a") %>% 
  html_attr("href") %>% 
  str_trim(side="both")
song_type = song_page %>% 
  html_nodes(".music_songs td:nth-child(2)") %>% 
  html_text() %>% 
  str_trim(side = "both")
song_release = song_page %>% 
  html_nodes("td:nth-child(6) a") %>% 
  html_text() %>% 
  str_trim(side = "both")

## put into a dataframe
songs = data.frame(link = song_links, 
                   name = song_names,
                   type = song_type,
                   release = song_release)

## give each song a unique id
song_id = sapply(1:nrow(songs), function(x) UUIDgenerate())
songs$song_id = song_id

## write the data
write_csv(songs, "data/song-data.csv")

## cleanup
rm(list=ls())

############################################################## pull out list of all shows

## URL
URL = "http://www.pearljam.com/setlists"
show_links = URL %>% read_html()

## pull out the show years
year_links = show_links %>% 
  html_nodes("#sub_sub_nav a") %>% 
  html_attr("href") %>% 
  str_trim(side = "both")

## for every year, get the shows
show_data = data.frame()
for (year in year_links) {
  ## get the 
  year_page = read_html(year)
  show_page_link = year_page %>% 
    html_nodes("#slider_showdates a") %>% 
    html_attr("href") %>% 
    str_trim(side = "both")
  show_page_name = year_page %>% 
    html_nodes("#slider_showdates a") %>% 
    html_text() %>% 
    str_trim(side = "both")
  ## bind
  show_data = bind_rows(show_data, data.frame(year_page = year, 
                                              show_link=show_page_link, 
                                              show_name=show_page_name))
  rm(year, year_page, show_page_link, show_page_name)
}

## cleaup the show data
show_data = transform(show_data, year=as.numeric(str_sub(year_page, -4, -1)))
show_data = transform(show_data, date=str_sub(show_name, str_length(show_name)-9, -1))
show_data = transform(show_data, location=str_sub(show_name, 1, str_length(show_name)-9))                    
venues = str_split(show_data$show_link, "/")
venues = sapply(venues, function(x) x[length(x)])
show_data$venues = venues

## each show gets a unique id
show_id = sapply(1:nrow(show_data), function(x) UUIDgenerate())
show_data$show_id = show_id

## write the data
write_csv(show_data, "data/show-data.csv")

## cleanup execpt for show data
rm(list=setdiff(ls(), "show_data"))


############################################################## for each show, get the songs

## testing:  parse a show
# show_link = show_data$show_link[1]
# tmp_show = read_html(show_link)
# song_list_text = tmp_show %>% html_nodes(".song_list a") %>% html_text()
# song_list_links = tmp_show %>% html_nodes(".song_list a") %>% html_attr("href")
# show_songs = data.frame(show = show_link,
#                         songs = song_list_text,
#                         song_links = song_list_links)
# show_songs$rank = 1:nrow(show_songs)
# 
# ## look at think about how the data will be related
# head(show_songs); head(show_data)

## build out function to parse the show
## funtion to create nodes and build relationships


## for each show, get the songs played
setlists = data.frame()
for (i in 1:nrow(show_data)) {
  ## isolate the row
  tmp = show_data[i,]
  ## get the URL
  tmp_show = read_html(tmp$show_link)
  ## parse out the data
  song_list_text = tmp_show %>% 
    html_nodes(".song_list a") %>% 
    html_text() %>% 
    str_trim(side = "both")
  song_list_links = tmp_show %>% 
    html_nodes(".song_list a") %>% 
    html_attr("href") %>% 
    str_trim(side = "both")
  ## if no songs, skip
  if (length(song_list_text) == 0) {
    cat("skipping ", tmp$show_id, "\n")
    next
  }
  ## make a dataframe
  show_songs = data.frame(show_id = tmp$show_id,
                          songs = song_list_text,
                          song_links = song_list_links)
  show_songs$rank = 1:nrow(show_songs)
  ## add to the setlists
  setlists = bind_rows(setlists, show_songs)
  ## cleanup
  rm(tmp_show, song_list_text, song_list_links, show_songs)
  ## message
  cat("completed ", tmp$show_id, "\n")
}

## reload the song data and keep the columns
songs = read_csv("data/song-data.csv") %>% select(song_id, link)
songs = rename(songs, song_links = link)

## clean up the song urls
songs$song_links = str_replace_all(songs$song_links, "http://pearljam.com/music/lyrics/all/all", "")
setlists$song_links = str_replace_all(setlists$song_links, "http://www.pearljam.com/music/lyrics/all/all", "")
setlists = left_join(setlists, songs)

## save the data
write_csv(setlists, "data/setlists.csv")

