#!/bin/sh

# Drop node3
psql bdrdb -c "select bdr.part_node('node2');"
psql bdrdb -c "select bdr.drop_node('node2');"
