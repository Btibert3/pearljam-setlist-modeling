// import shows: will re-map the properties of the node from the row variable
LOAD CSV WITH HEADERS FROM 'file:///Users/brock/github/pearljam-setlist-modeling/data/setlists.csv' as row
WITH row
MATCH (song:Song {song_id:row.song_id})
MATCH (show:Show {show_id:row.show_id})
CREATE (song)-[:PLAYED_AT {rank:row.rank}]->(show);