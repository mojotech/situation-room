package main

import (
	"crypto/md5"
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
	uptimeRedisKey = "uptime"
)

var (
	serverPort = os.Getenv("PORT")
	redisScope = flag.String("redis-scope", "situation-room", "Redis namespace to use for storage")

	AllSites    []Site
	redisClient redis.Client
)

type Site struct {
	URL            string    `json:"url"`
	Status         string    `json:"status"`
	StatusCode     int       `json:"status_code"`
	LastCheck      time.Time `json:"last_checked_at"`
	PreviousStatus string    `json:"-"`
	hashKey        string    `json:"-"`
}

func (s *Site) HashKey() string {
	if 0 == len(s.hashKey) {
		s.hashKey = fmt.Sprintf("%x", md5.Sum([]byte(s.URL)))
	}

	return s.hashKey
}

func main() {
	flag.Parse()

	AllSites, err := loadSites()
	if err != nil {
		log.Fatalln("[ERROR] Problem loading all sites from storage:", err.Error())
	}
	log.Println(fmt.Sprintf("[INFO] %d sites found.", len(AllSites)))

	err = startStatusCheckers(AllSites)
	if err != nil {
		log.Fatalln("[ERROR] Failed to start status checkers:", err.Error())
	}

	e := echo.New()
	e.Use(mw.Logger())
	e.Get("/sites", sitesHandler)
	e.Post("/sites", createSiteHandler)
	e.Run(":" + serverPort)
}

func loadSites() ([]Site, error) {
	redisSites, err := redisClient.Smembers(redisScopedKey(sitesRedisKey))
	if err != nil {
		return AllSites, err
	}

	for _, s := range redisSites {
		AllSites = append(AllSites, Site{URL: string(s)})
	}

	return AllSites, nil
}

func redisScopedKey(key string) string {
	return fmt.Sprintf("%s:%s", *redisScope, key)
}
