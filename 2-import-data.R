options(stringsAsFactors = FALSE)

## load the libraries
library(RNeo4j)

## connect to Neo4j
graph = startGraph("http://localhost:7474/db/data/",
                   username = "neo4j",
                   password = "password")

## clear out the graph
clear(graph, input = FALSE)

## helper function to use neo-shell from R for fast(er) imports using cypher
build_import = function(neo_shell = "~/neo4j-community-3.0.0/bin/neo4j-shell", 
                        cypher_file) {
  cmd = sprintf("%s -file %s", neo_shell, cypher_file)
  system(cmd)
}

## add constraints
addConstraint(graph, "Song", "song_id")
addConstraint(graph, "Show", "show_id")

## import songs
build_import(cypher_file="cql/import-songs.cql")
build_import(cypher_file="cql/import-shows.cql")
build_import(cypher_file="cql/import-setlists.cql")


## could blow out data model for venues, dates, etc.