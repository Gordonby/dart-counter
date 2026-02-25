# Dart Counter AI Skill

The DartCounter app is awesome for inputting scores, even better with the Omni auto scoring system. They don't however make it easy to get your data out of the app.
The purpose of this repo is to easily free your data, allowing you to save it safely and perform analysis of it.

## What can it do

- Login to the API
- Get your data
- Show an ascii dashboard of your stats

```output
   1     +--------------------------------------------------+
    2     |                DARTCOUNTER STATS                 |
    3     +--------------------------------------------------+
    4     | TOTAL GAMES:   68                                |
    5     | WIN RATE:      38.2%                             |
    6     | AVG 3-DART:    41.01                             |
    7     | BEST AVG:      60.12                             |
    8     +--------------------------------------------------+
    9     |           RECENT MATCH PERFORMANCE               |
   10     +--------------------------------------------------+
   11     | 2026-02-25 | WON  | 2-0   | AVG: 37.11      |    |
   12     | 2026-02-25 | LOSS | 0-1   | AVG: 40.42      | 🤖 |
   13     | 2026-02-25 | WON  | 1-0   | AVG: 48.48      | 🤖 |
   14     | 2026-02-25 | WON  | 1-0   | AVG: 57.81      | 🤖 |
   15     | 2026-02-25 | LOSS | 0-1   | AVG: 38.42      | 🤖 |
   16     +--------------------------------------------------+
```

## Getting started

### Install

The skill was built with gemini but you can install it on many AI cli's

## Origin story

Forked from https://github.com/Mark-McCracken/dart-counter-aggregator, as my only reference to the API (the OpenAPI spec has long since disappeared from the link).

I'm not a massive python file, and i'm quite into my AI CLI's at the moment - so i've turned this into an AI skill to capture the data which can then be visualised in a variety of ways.
