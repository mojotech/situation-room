package main

import (
	"database/sql"
	"flag"
	"log"
	"os"

	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo"
	mw "github.com/labstack/echo/middleware"
	_ "github.com/mattn/go-sqlite3"
	_ "github.com/lib/pq"
	_ "github.com/go-sql-driver/mysql"
	"github.com/kylelemons/go-gypsy/yaml"
	"gopkg.in/gorp.v1"
)

var (
	serverPort = os.Getenv("PORT")
	dbDriver = os.Getenv("DB")

	db *gorp.DbMap
)

func main() {
	flag.Parse()

	db = setupDb()

	e := echo.New()
	e.Use(mw.Logger())
	e.Get("/sites", sitesHandler)
	e.Post("/sites", createSiteHandler)
	e.Get("/sites/:key", siteHandler)
	e.Get("/sites/:key/checks", checksHandler)
	e.Delete("/sites/:key", deleteSiteHandler)

	StartDispatcher()

	e.Run(":" + serverPort)
}

func getDBUrl() (string, error) {
	file, err := yaml.ReadFile("dbconfig.yml")

	if err != nil {
		log.Fatalf("Failed to read db configuration", err)
	}

	url, err := file.Get(dbDriver + ".url")

	if err != nil {
		log.Fatalf("Failed to read url from configuration file", err)
	}

	return url, err
}

func setupDb() *gorp.DbMap {
	dbUrl, err := getDBUrl()

	if err != nil {
		log.Fatalf("Failed to retrieve database url", err)
	}

	// Open db connection
	db, err := sql.Open(dbDriver, dbUrl)
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
