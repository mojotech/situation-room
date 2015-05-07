package main

import (
	"flag"
	"fmt"
	"net/http"
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

type Site struct {
	URL        string `json:"url"`
	Status     string `json:"status"`
	LastStatus string `json:"-"`
	LastCheck  string `json:"last_checked_at"`
}

type SitesResponse struct {
	Sites []Site `json:"sites"`
}

func main() {
	flag.Parse()

	e := echo.New()
	e.Use(mw.Logger)
	e.Get("/status", statusHandler)
	e.Post("/status", createStatusHandler)
	e.Run(":" + serverPort)
}

// GET /status
//
// response:
//   sites: <array> sites registered with the system
func statusHandler(c *echo.Context) *echo.HTTPError {
	redisSites, err := redisClient.Smembers(redisScopedKey(sitesRedisKey))
	if err != nil {
		e := &echo.HTTPError{
			Code:    http.StatusInternalServerError,
			Message: "Problem retrieving list of sites",
			Error:   err,
		}
		return e
	}

	sites := make([]Site, len(redisSites))
	for i, s := range redisSites {
		sites[i] = Site{URL: string(s)}
	}

	return c.JSON(http.StatusOK, &SitesResponse{Sites: sites})
}

// POST /status
//
// params:
//   url: <string, required> website url to check
//	 email: <string, options> email address to alert on status changes
//
// response:
//   site: <json> newly created site info
func createStatusHandler(c *echo.Context) *echo.HTTPError {
	return c.JSON(http.StatusOK, "OK")
}

func redisScopedKey(key string) string {
	return fmt.Sprintf("%s:%s", *redisScope, key)
}
