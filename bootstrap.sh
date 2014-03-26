#!/bin/bash
rm -rf .bundle/
mkdir .bundle/
bundle install --path .bundle/

rm -rf neo4j-community-2.0.1-unix
curl -O http://dist.neo4j.org/neo4j-community-2.0.1-unix.tar.gz
tar xf neo4j-community-2.0.1-unix.tar.gz
rm neo4j-community-2.0.1-unix.tar.gz

gzcat data/FEC_Contributions_2012.csv.gz > data/FEC_Contributions_2012.csv
