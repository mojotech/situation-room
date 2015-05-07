package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/hoisie/redis"
	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
)

const (
	sitesRedisKey  = "sites"
	emailsRedisKey = "site-emails"
)

var (
	serverPort = os.Getenv("PORT")
	redisScope = flag.String("redis-scope", "situation-room", "Redis namespace to use for storage")

	redisClient redis.Client
)

type Site struct {
	URL            string    `json:"url"`
	Status         string    `json:"status"`
	StatusCode     int       `json:"status_code"`
	PreviousStatus string    `json:"-"`
	LastCheck      time.Time `json:"last_checked_at"`
}

func main() {
	flag.Parse()

	err := startStatusCheckers()
	if err != nil {
		log.Fatalln("* Failed to start status checkers:", err.Error())
	}

	e := echo.New()
	e.Use(mw.Logger())
	e.Get("/status", statusHandler)
	e.Post("/status", createStatusHandler)
	e.Run(":" + serverPort)
}

func redisScopedKey(key string) string {
	return fmt.Sprintf("%s:%s", *redisScope, key)
}
