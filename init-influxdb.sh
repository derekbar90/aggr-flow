#!/bin/bash
set -e

influx -host influx -execute "CREATE DATABASE IF NOT EXISTS significant_trades"
influx -host influx -execute "CREATE RETENTION POLICY \"one_day\" ON \"significant_trades\" DURATION 24h REPLICATION 1 DEFAULT" 