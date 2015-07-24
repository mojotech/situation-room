package main

import (
	"crypto/md5"
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/hoisie/redis"
	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
	_ "github.com/mattn/go-sqlite3"
	"gopkg.in/gorp.v1"
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
	db          *gorp.DbMap
)

type Site struct {
	Key            string    `json:"key"`
	URL            string    `json:"url"`
	Status         string    `json:"status"`
	StatusCode     int       `json:"status_code"`
	LastCheck      time.Time `json:"last_checked_at"`
	PreviousStatus string    `json:"-"`
}

func (s *Site) HashKey() string {
	if 0 == len(s.Key) {
		s.Key = fmt.Sprintf("%x", md5.Sum([]byte(s.URL)))
	}

	return s.Key
}

func main() {
	flag.Parse()

	db = setupDb()

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
	e.Get("/sites/:key", siteHandler)
	e.Run(":" + serverPort)
}

func loadSites() ([]Site, error) {
	redisSites, err := redisClient.Smembers(redisScopedKey(sitesRedisKey))
	if err != nil {
		return AllSites, err
	}

	for _, s := range redisSites {
		site := Site{URL: string(s)}
		site.Key = site.HashKey()
		AllSites = append(AllSites, site)
	}

	return AllSites, nil
}

func redisScopedKey(key string) string {
	return fmt.Sprintf("%s:%s", *redisScope, key)
}

func setupDb() *gorp.DbMap {
	// Open SQLlite db connection
	db, err := sql.Open("sqlite3", "./situation-room.bin")
	if err != nil {
		log.Fatalf("Failed to open database connection", err)
	}

	dbmap := &gorp.DbMap{Db: db, Dialect: gorp.SqliteDialect{}}

	err = dbmap.CreateTablesIfNotExists()
	if err != nil {
		log.Fatalf("Failed to create tables", err)
	}

	return dbmap
}
