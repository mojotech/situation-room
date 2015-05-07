package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/hoisie/redis"
	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
)

const (
	sitesRedisKey = "sites"
)

var (
	serverPort = os.Getenv("PORT")
	redisScope = flag.String("redis-scope", "situation-room", "Redis namespace to use for storage")

	redisClient redis.Client
)

func main() {
	flag.Parse()

	e := echo.New()
	e.Use(mw.Logger)
	e.Get("/status", statusHandler)
	e.Post("/status", createStatusHandler)
	e.Run(":" + serverPort)
}

func redisScopedKey(key string) string {
	return fmt.Sprintf("%s:%s", *redisScope, key)
}
