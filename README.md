# Getting started with Go, Docker, Redis on Giant Swarm

This is a simple example to write Golang applications and deploy them on [Giant Swarm]((https://giantswarm.io/)). It pings an external API and caches the data in an Redis cache.

## Prerequisites

* Have a Giant Swarm account and the [swarm cli](http://docs.giantswarm.io/installation/gettingstarted/#installing-the-cli) running. [Request a free invite](https://giantswarm.io/).
* Have [Docker](https://docs.docker.com/installation/) and [Fig](http://www.fig.sh/) running and be familiar with the basic Docker and Fig commands and Makefiles.

## Edit source

The application logic is implemented in [main.go](main.go). It starts a webserver and on root request pings the [openweather API](http://api.openweathermap.org/data/2.5/weather?q=Cologne) caches the result in Redis and extracts and returns the current weather for Cologne.

## Run in locally
To run it locally you just have to do a `make fig-up. This:
* builds the Go project into a linux binary
* creates a custom Docker image with the linux binary
* starts both the custom Docker container and a Redis container.

To test it on a Mac run something like: `curl $(boot2docker ip):8080` 

## Run in on Giant Swarm
To deploy it on Giant Swarm you just have to do a 'make swarm-up'. This:
* builds appropriate Docker images
* uploads them to the Giant Swarm registry
* uploads the `swarm.json` and starts the application.

To test it run something like: `curl currentweather-YOURUSERNAME.gigantic.io` and replace YOURUSERNAME with your Giant Swarm username.

For all build and deploy details see the [Makefile](Makefile).