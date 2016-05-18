// import shows: will re-map the properties of the node from the row variable
LOAD CSV WITH HEADERS FROM 'file:///Users/brock/github/pearljam-setlist-modeling/data/show-data.csv' as row
WITH row
CREATE (s:Show)
SET s = row;