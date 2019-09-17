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
	e.Use(mw.CORSWithConfig(mw.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept},
	}))
	e.GET("/sites", sitesHandler)
	e.POST("/sites", createSiteHandler)
	e.GET("/sites/:key", siteHandler)
	e.GET("/sites/:key/checks", checksHandler)
	e.DELETE("/sites/:key", deleteSiteHandler)

	StartDispatcher()

	// e.Run(":" + serverPort)
	e.Logger.Fatal(e.Start(":" + serverPort))
}

func setupDb() *gorp.DbMap {
	// Open SQLlite db connection
	db, err := sql.Open("sqlite3", "./situation-room.bin")
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
