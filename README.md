# EventSource

Example of an event sourcing application.

## Architecture

The application is separated into three main components:

1. The store
2. The command process
3. The query process

## The store

The store is utilises ETS to write facts (commands) to disc
