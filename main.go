package main

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo/v4"
	mw "github.com/labstack/echo/v4/middleware"
	echoLog "github.com/labstack/gommon/log"
	_ "github.com/mattn/go-sqlite3"
	"gopkg.in/gorp.v1"
)

var (
	db         *gorp.DbMap
	debugLog   bool
	serverPort = "4567"
)

func main() {
	db = setupDb()

	// Set up ENV flags and overrides
	_, debugLog = os.LookupEnv("DEBUG")
	port, portOverride := os.LookupEnv("PORT")
	if portOverride {
		serverPort = port
	}

	e := echo.New()
	e.Use(mw.Logger())
	e.Use(mw.CORSWithConfig(mw.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept},
	}))
	e.GET("/sites", sitesHandler)
	e.POST("/sites", createSiteHandler)
	e.GET("/sites/:key", siteHandler)
	e.GET("/sites/:key/checks", checksHandler)
	e.DELETE("/sites/:key", deleteSiteHandler)

	if debugLog {
		e.Logger.SetLevel(echoLog.DEBUG)
	}

	err := StartDispatcher()
	if err != nil {
		log.Fatalf("Failed to start dispatcher: %s", err)
	}

	e.Logger.Fatal(e.Start(":" + serverPort))
}

func setupDb() *gorp.DbMap {
	// Open SQLlite db connection
	db, err := sql.Open("sqlite3", "./situation-room.db.bin")
	if err != nil {
		log.Fatalf("Failed to open database connection: %s", err)
	}

	dbmap := &gorp.DbMap{Db: db, Dialect: gorp.SqliteDialect{}}

	dbmap.AddTableWithName(Site{}, "sites").SetKeys(false, "Id")
	dbmap.AddTableWithName(Check{}, "checks").SetKeys(true, "Id")

	err = dbmap.CreateTablesIfNotExists()
	if err != nil {
		log.Fatalf("Failed to create tables: %s", err)
	}

	return dbmap
}
