package main

import (
	"crypto/md5"
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
	_ "github.com/mattn/go-sqlite3"
	"gopkg.in/gorp.v1"
)

var (
	serverPort = os.Getenv("PORT")

	AllSites []Site
	db       *gorp.DbMap
)

type Site struct {
	Id        string    `json:"id"`
	URL       string    `json:"url"`
	Email     string    `json:"email"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func (s *Site) HashId() string {
	if 0 == len(s.Id) {
		s.Id = fmt.Sprintf("%x", md5.Sum([]byte(s.URL)))
	}
	return s.Id
}

func main() {
	flag.Parse()

	db = setupDb()

	sites, err := loadSites()
	if err != nil {
		log.Fatalln("[ERROR] Problem loading all sites from storage:", err.Error())
	}

	log.Println(fmt.Sprintf("[INFO] %d sites found.", len(AllSites)))
	AllSites = sites

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
	var sites []Site
	_, err := db.Select(&sites, "SELECT * FROM sites ORDER BY CreatedAt DESC")
	return sites, err
}

func setupDb() *gorp.DbMap {
	// Open SQLlite db connection
	db, err := sql.Open("sqlite3", "./situation-room.bin")
	if err != nil {
		log.Fatalf("Failed to open database connection", err)
	}

	dbmap := &gorp.DbMap{Db: db, Dialect: gorp.SqliteDialect{}}

	dbmap.AddTableWithName(Site{}, "sites")

	err = dbmap.CreateTablesIfNotExists()
	if err != nil {
		log.Fatalf("Failed to create tables", err)
	}

	return dbmap
}
