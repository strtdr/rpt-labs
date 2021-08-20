# RTP

## Description

The app fetches 2 endpoints and thru __Router__ redirect them to __Analyzers__ of sentiments & engagement ratings in parallel. After that computed information in directed to __Aggregator__ in which it's miles blended via way of means of specific tweet ID and stored in __Database__ and sending tweets to __Message Broker__ on subject matter _tweeter_

## Start

1. `$ docker-compose up -d`
1. Connect to message broker through _netcat_ on port 6666
1. Subscribe to topic _tweeter_ to receive tweets from __Analyzer__