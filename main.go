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
	Main struct {
		Temperature float64 `json:"temp"`
	}
}

func main() {
	var err error
	fmt.Println("Establishing connection to Redis")
	redisCon, err = redis.Dial("tcp", redisAddress())
	if err != nil {
		log.Fatalf("Could not connect to Redis with error: %s", err)
	}
	defer redisCon.Close()

	http.HandleFunc("/", currentWeatherHandler)

	fmt.Println("Starting current weather server")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func currentWeatherHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello world again\n")

	report, err := getWeatherReport()
	if err != nil {
		fmt.Fprintf(w, "Cannot get weather data: %s\n", err)
	} else {
		celsius := report.Main.Temperature - 273
		fmt.Fprintf(w, "Current temperature is %.2f °C\n", celsius)
	}
}

func getWeatherReport() (WeatherReport, error) {
	var report WeatherReport

	data, err := cacheReport(getWeatherReportData)
	if err != nil {
		return report, err
	}

	if json.Unmarshal(data, &report); err != nil {
		return report, err
	}

	return report, nil
}

func getWeatherReportData() ([]byte, error) {
	var data []byte
	resp, err := http.Get("http://api.openweathermap.org/data/2.5/weather?q=Cologne")
	if err != nil {
		return data, err
	}
	defer resp.Body.Close()

	data, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		return data, err
	}
	return data, nil
}

func cacheReport(f func() ([]byte, error)) ([]byte, error) {
	data, _ := redis.Bytes(redisCon.Do("GET", "report"))
	if len(data) == 0 {
		res, err := f()
		if err != nil {
			return nil, err
		}
		redisCon.Do("SET", "report", res)
		redisCon.Do("EXPIRE", "report", 60)
		data = res
	}
	return data, nil
}

func redisAddress() string {
	addr := os.Getenv("REDIS_PORT_6379_TCP_ADDR")
	port := os.Getenv("REDIS_PORT_6379_TCP_PORT")
	return net.JoinHostPort(addr, port)
}
