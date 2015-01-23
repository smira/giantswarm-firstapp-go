package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/garyburd/redigo/redis"
)

var redisCon redis.Conn

type WeatherReport struct {
	Main WeatherMain `json:main`
}

type WeatherMain struct {
	Temeperature float64 `json:temp`
}

func (wm WeatherMain) TemeperatureCelsius() float64 {
	return wm.Temeperature
}

func main() {
	fmt.Println("Establishing connection to Redis")
	_, err := redis.Dial("tcp", redisAddress())
	if err != nil {
		log.Fatalf("Could not connect to Redis with error: %s", err)
	}

	http.HandleFunc("/", currentWeatherHandler)

	fmt.Println("Starting Helloworld server")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func currentWeatherHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello world again\n")

	report, err := getWeatherReport()
	if err != nil {
		fmt.Fprintf(w, "Cannot get weather data\n")
	} else {
		fmt.Fprintf(w, "Current temperature is %f °C\n", report.Main.TemeperatureCelsius())
	}
}

func getWeatherReport() (WeatherReport, error) {
	var report WeatherReport

	resp, err := http.Get("http://api.openweathermap.org/data/2.5/weather?q=Cologne")
	if err != nil {
		return report, err
	}
	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return report, err
	}

	if json.Unmarshal(data, &report); err != nil {
		return report, err
	}

	return report, nil
}

func redisAddress() string {
	addr := os.Getenv("REDIS_PORT_6379_TCP_ADDR")
	port := os.Getenv("REDIS_PORT_6379_TCP_PORT")
	return net.JoinHostPort(addr, port)
}
