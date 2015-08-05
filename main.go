package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"

	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
	_ "github.com/mattn/go-sqlite3"
	"gopkg.in/gorp.v1"
)

var (
	serverPort = os.Getenv("PORT")

	AllSites map[string]Site
	db       *gorp.DbMap
)

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
	e.Get("/sites/:key/checks", checksHandler)
	e.Delete("/sites/:key", deleteSiteHandler)
	e.Run(":" + serverPort)
}

func loadSites() (map[string]Site, error) {
	var sites []Site
	sitesMap := make(map[string]Site)
	_, err := db.Select(&sites, "SELECT * FROM sites ORDER BY CreatedAt DESC")
	if err != nil {
		return sitesMap, err
	}

	for _, site := range sites {
		sitesMap[site.Id] = site
	}

	return sitesMap, err
}

func setupDb() *gorp.DbMap {
	// Open SQLlite db connection
	db, err := sql.Open("sqlite3", "./situation-room.bin")
	if err != nil {
		log.Fatalf("Failed to open database connection", err)
	}

	dbmap := &gorp.DbMap{Db: db, Dialect: gorp.SqliteDialect{}}

	dbmap.AddTableWithName(Site{}, "sites").SetKeys(false, "Id")
	dbmap.AddTableWithName(Check{}, "checks").SetKeys(true, "Id")

	err = dbmap.CreateTablesIfNotExists()
	if err != nil {
		log.Fatalf("Failed to create tables", err)
	}

	return dbmap
}
