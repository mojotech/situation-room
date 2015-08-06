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
	"gopkg.in/gorp.v1"
)

var (
	serverPort = os.Getenv("PORT")

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
